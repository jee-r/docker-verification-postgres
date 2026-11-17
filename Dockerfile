# Databasus verification image plus the PostGIS extensions it is missing
# (tiger geocoder, address standardizer), built per PG major.
#
# One stage per major so Renovate can parse and bump each pinned digest:
# a FROM built from an ARG cannot be tracked.
ARG PG_MAJOR=17

FROM docker.io/databasus/verification-postgres:12@sha256:caf4ff12780368e80c609ffa783328bb02b8bc85766646b20e95d2ca497669fb AS base-12
FROM docker.io/databasus/verification-postgres:13@sha256:97e59fe28db4758e0fccdf5c44720c98a8582100e23c582d90765e087ca8a4a1 AS base-13
FROM docker.io/databasus/verification-postgres:14@sha256:7bd756d3c7eba46738950ede1a2cbfa332f3737fbf832537d714888bc119efa9 AS base-14
FROM docker.io/databasus/verification-postgres:15@sha256:ce62fc68e11c226503e4276adff2ffd19a22aa553e2b897f207d3d2c10a6cefc AS base-15
FROM docker.io/databasus/verification-postgres:16@sha256:43aae63d0880271ded0880ed980d6935c1c346cb3460107196fbf7b32e914379 AS base-16
FROM docker.io/databasus/verification-postgres:17@sha256:878262fff20f585570b402594f6e2473aebf83a8bd0a11e92aaf044f45462ec7 AS base-17
FROM docker.io/databasus/verification-postgres:18@sha256:575f0f8bb60a6c72ddf7c298f3b4861af70021062395534ff84ebd78993d43b2 AS base-18

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
