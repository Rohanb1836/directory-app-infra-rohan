# Story 0.4 staging environment

This Terraform foundation provisions the Story 0.4 staging architecture: ECS Fargate for API, web, and Keycloak; private RDS; ALB; private S3 behind CloudFront; and weekday business-hours ECS scheduling.

Before applying, the sponsor must provide the AWS account and the repository must have an OIDC deploy role in `AWS_DEPLOY_ROLE_ARN`. The project documentation confirms that an AWS account does not yet exist. Do not run `terraform apply` locally against a shared account.

The RDS instance creates `blackpages`; the deployment bootstrap migration must create the separate restricted `keycloak` database and role before Keycloak is released.
