# Databasus verification image plus the PostGIS extensions it is missing
# (tiger geocoder, address standardizer), built per PG major.
#
# One stage per major so Renovate can parse and bump each pinned digest:
# a FROM built from an ARG cannot be tracked.
ARG PG_MAJOR=17

FROM docker.io/databasus/verification-postgres:12@sha256:8d9ea4cdb288133bfdeea8d324e5c943e4fa664534467ba99e98499a0f2d88aa AS base-12
FROM docker.io/databasus/verification-postgres:13@sha256:8c6f3b4c1624891dc667f5a2f18180eefd8af09136e67d212c5d150a15e0d260 AS base-13
FROM docker.io/databasus/verification-postgres:14@sha256:eba709b356e0e25184941d9fb50f553220c4f4a637f952de4ed92392f3157aeb AS base-14
FROM docker.io/databasus/verification-postgres:15@sha256:3d70e676d08e289abfa3f28486d04aa9d043fa581ca9bbcdd75cedf905687ed5 AS base-15
FROM docker.io/databasus/verification-postgres:16@sha256:b4944239121acf33763b93154e20c5993830db43a852915908b13b4d86793037 AS base-16
FROM docker.io/databasus/verification-postgres:17@sha256:b53779ee2b51719d7cc71000e6739e2f9a68581075fb0921b0545db21d81b5d5 AS base-17
FROM docker.io/databasus/verification-postgres:18@sha256:e336594d54cb1d7d760ec8b8e575f5ffb0c37dbb295f80df1058e16804273507 AS base-18

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
