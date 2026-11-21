# Databasus verification image plus the PostGIS extensions it is missing
# (tiger geocoder, address standardizer), built per PG major.
#
# One stage per major so Renovate can parse and bump each pinned digest:
# a FROM built from an ARG cannot be tracked.
ARG PG_MAJOR=17

FROM docker.io/databasus/verification-postgres:12@sha256:039bb3a7acec997092236635ac2124db279ff8c899db8b131e82977f2ac3b3bb AS base-12
FROM docker.io/databasus/verification-postgres:13@sha256:f1eb6fea40ec949cb2cc57bc6b4fdefaa9400b92265a798ba187b0c046c6a810 AS base-13
FROM docker.io/databasus/verification-postgres:14@sha256:e985c363628c9019fff6f9d36c49a2210fe11c3f28e19a7a7a75ccedafc70991 AS base-14
FROM docker.io/databasus/verification-postgres:15@sha256:6f226b50199b825f95b75a8b11804542b1e3a6d605823493de7b40de75a01400 AS base-15
FROM docker.io/databasus/verification-postgres:16@sha256:12e1696de074287f10170f56816d6a6b5ac77fb6f6db3e2a630d1afcfb797909 AS base-16
FROM docker.io/databasus/verification-postgres:17@sha256:75d17e4f9d89b52342c85c65924efe006b2c15475eab2de951c942822cb9ab43 AS base-17
FROM docker.io/databasus/verification-postgres:18@sha256:18d025a0e3679b631b1e3acb47c8b031f4c6389aa214e0b70fed7a0f523daa41 AS base-18

FROM base-${PG_MAJOR}

# ARGs declared before FROM are not visible in the build stage.
ARG PG_MAJOR

LABEL org.opencontainers.image.source="https://github.com/jee-r/docker-verification-postgres" \
      org.opencontainers.image.description="Databasus verification-postgres image with the PostGIS tiger geocoder and address standardizer" \
      org.opencontainers.image.licenses="Apache-2.0"

# Apache-2.0 section 4: ship the license and the NOTICE (which reproduces the
# Databasus NOTICE and lists our changes) with the redistributed image.
COPY LICENSE NOTICE /usr/share/doc/verification-postgres/

# The scripts are bind-mounted, not copied, so nothing extra lands in the image.
RUN --mount=type=bind,source=scripts,target=/tmp/scripts \
    sh /tmp/scripts/install.sh "${PG_MAJOR}"
