FROM node:alpine AS theme
RUN apk add --no-cache git openssh
RUN git clone https://github.com/lukin/keywind keywind
WORKDIR keywind
RUN yarn install && yarn build:jar

FROM quay.io/keycloak/keycloak:latest as builder
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres
COPY --from=theme keywind/out/keywind.jar /opt/keycloak/providers/keywind.jar
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]