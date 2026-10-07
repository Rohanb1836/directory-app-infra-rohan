# ADR-0014: Hosting on AWS, with ECS Fargate, RDS, and CloudFront

- **Status:** Proposed (the cloud provider needs to be confirmed) **2026-10-06 (Q13):** there's no AWS account yet. Someone needs to create and own it before Sprint 0 ends.
- **Date:** 2026-09-27 (updated to include Keycloak)

## Decision
- **Compute:** ECS Fargate on ARM (Graviton) runs three services: `api` (Spring Boot), `web` (Next.js), and `keycloak`.
- **Database:** one RDS PostgreSQL instance (db.t4g.small) with two logical databases (ADR-0016).
- **Load balancer:** one ALB with host and path routing:
  - `blackpages.io/api/*` goes to `api`.
  - `blackpages.io/*` goes to `web`.
  - `auth.blackpages.io/*` goes to `keycloak`, with `/admin/*` restricted by source IP.
- **Images and caching:** S3 and CloudFront.
- **Secrets:** Secrets Manager.
- **Infrastructure as code:** Terraform in `directory-app-infra`.
- **Networking in the MVP:** no NAT gateway. Tasks run in public subnets, with security groups that accept inbound traffic only from the ALB.

## Estimated monthly cost (us-east-1, on-demand, MVP traffic)

| Setup | Previous estimate | With Keycloak |
|---|---|---|
| Minimal production (one task per service, single-AZ database) | ~$110–130 | **~$140–160** |
| Staging (scheduled to run in business hours) | ~$30–45 | **~$40–55** |
| Production with high availability (two tasks per service, Multi-AZ database, WAF, one NAT gateway) | ~$250–300 | **~$310–360** |

Keycloak adds about $29 a month for one task with 1 vCPU and 2 GB on ARM. There's no extra database instance or load balancer.

## Consequences
- Managed services keep operations work low. Costs can be cut 30–40% with Savings Plans or reserved instances once usage is steady.
