terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}
variable "project" {
  type    = string
  default = "blackpages"
}
variable "environment" {
  type    = string
  default = "staging"
}
variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}
variable "api_image" {
  type    = string
  default = "ghcr.io/blackpages-io/directory-app-svc:main"
}
variable "web_image" {
  type    = string
  default = "ghcr.io/blackpages-io/directory-app-ui:main"
}
variable "keycloak_image" {
  type    = string
  default = "quay.io/keycloak/keycloak:26.7.4"
}

locals {
  name = "${var.project}-${var.environment}"
  tags = { Project = var.project, Environment = var.environment, ManagedBy = "terraform" }
  services = {
    api      = { image = var.api_image, port = 8080, cpu = 1024, memory = 2048, command = [] }
    web      = { image = var.web_image, port = 3000, cpu = 512, memory = 1024, command = [] }
    keycloak = { image = var.keycloak_image, port = 8080, cpu = 1024, memory = 2048, command = ["start", "--optimized"] }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.tags }
}

# ADR-0014: public ALB/ECS tasks, private RDS, and no NAT gateway.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}
resource "aws_internet_gateway" "this" { vpc_id = aws_vpc.this.id }
resource "aws_subnet" "public" {
  for_each                = toset(var.availability_zones)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, index(var.availability_zones, each.value))
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, index(var.availability_zones, each.value) + 8)
}
resource "aws_route_table" "public" { vpc_id = aws_vpc.this.id }
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_security_group" "alb" {
  name   = "${local.name}-alb"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ecs" {
  name   = "${local.name}-ecs"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "rds" {
  name   = "${local.name}-rds"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
}

# RDS creates blackpages. Deployment bootstrap creates the restricted keycloak database and role.
resource "random_password" "db" {
  length  = 32
  special = true
}
resource "aws_db_instance" "this" {
  identifier              = local.name
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = "db.t4g.small"
  db_name                 = "blackpages"
  username                = "blackpages_admin"
  password                = random_password.db.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true
}
resource "aws_secretsmanager_secret" "database" {
  name_prefix             = "${local.name}/database-"
  recovery_window_in_days = 7
}
resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    host     = aws_db_instance.this.address, port = 5432, username = "blackpages_admin",
    password = random_password.db.result, database = "blackpages"
  })
}

resource "aws_s3_bucket" "media" { bucket_prefix = "${local.name}-media-" }
resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_cloudfront_origin_access_control" "media" {
  name                              = "${local.name}-media"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "media" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id                = "media"
    origin_access_control_id = aws_cloudfront_origin_access_control.media.id
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "media"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate { cloudfront_default_certificate = true }
}
data "aws_iam_policy_document" "media" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.media.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.media.arn]
    }
  }
}
resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id
  policy = data.aws_iam_policy_document.media.json
}

resource "aws_ecs_cluster" "this" { name = local.name }
resource "aws_cloudwatch_log_group" "service" {
  for_each          = local.services
  name              = "/ecs/${local.name}/${each.key}"
  retention_in_days = 14
}
data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "execution" {
  name               = "${local.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}
resource "aws_iam_role" "task" {
  name               = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}
resource "aws_lb_target_group" "service" {
  for_each    = local.services
  name        = "${local.name}-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check {
    path    = each.key == "keycloak" ? "/health/ready" : "/_internal/health"
    matcher = "200-399"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service["web"].arn
  }
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service["api"].arn
  }
  condition {
    path_pattern { values = ["/api/*"] }
  }
}
resource "aws_lb_listener_rule" "keycloak" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service["keycloak"].arn
  }
  condition {
    host_header { values = ["auth.staging.blackpages.io"] }
  }
}
resource "aws_ecs_task_definition" "service" {
  for_each                 = local.services
  family                   = "${local.name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name         = each.key, image = each.value.image, essential = true, command = each.value.command
    portMappings = [{ containerPort = each.value.port, protocol = "tcp" }]
    logConfiguration = { logDriver = "awslogs", options = {
      awslogs-group         = aws_cloudwatch_log_group.service[each.key].name
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "ecs"
    } }
  }])
}
resource "aws_ecs_service" "service" {
  for_each        = local.services
  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = 0
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.service[each.key].arn
    container_name   = each.key
    container_port   = each.value.port
  }
  deployment_minimum_healthy_percent = 0
}

# Weekdays 6 AM--8 PM Phoenix time. Arizona is UTC-7 year round.
resource "aws_appautoscaling_target" "service" {
  for_each           = local.services
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.service[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_scheduled_action" "open" {
  for_each           = local.services
  name               = "${local.name}-${each.key}-open"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.service[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(0 13 ? * MON-FRI *)"
  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}
resource "aws_appautoscaling_scheduled_action" "close" {
  for_each           = local.services
  name               = "${local.name}-${each.key}-close"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.service[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(0 3 ? * MON-FRI *)"
  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

output "staging_alb_dns_name" { value = aws_lb.this.dns_name }
output "media_cdn_domain" { value = aws_cloudfront_distribution.media.domain_name }
output "database_secret_arn" {
  value     = aws_secretsmanager_secret.database.arn
  sensitive = true
}
