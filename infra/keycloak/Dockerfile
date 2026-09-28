# Production Keycloak image (built in directory-app-infra; see ADR-0016)
ARG KEYCLOAK_VERSION=26.7.4

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder
ENV KC_DB=postgres \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true
# Keycloakify theme JAR from the directory-app-ui CI artifact, pinned by version.
# Comment this line out until the first theme release exists.
COPY themes/blackpages-keycloak-theme.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
# Runtime settings come from the ECS task definition:
#   KC_DB_URL, KC_DB_USERNAME, KC_DB_PASSWORD (from Secrets Manager)
#   KC_HOSTNAME=https://auth.blackpages.io
#   KC_PROXY_HEADERS=xforwarded
#   KC_HTTP_ENABLED=true            (TLS ends at the ALB)
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
