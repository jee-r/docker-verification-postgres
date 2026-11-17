#!/bin/sh
# Print the PostGIS-family extensions this image guarantees for a PG major,
# one per line. Single source of truth for the build-time check and the CI test.
#
# Usage: extensions.sh <pg_major>
set -eu

major="${1:?usage: extensions.sh <pg_major>}"

echo postgis
echo postgis_topology
echo fuzzystrmatch
echo address_standardizer
echo address_standardizer_data_us

# Since PostGIS 3.7, PGDG ships the tiger geocoder as a separate package, and
# only for majors 16+. Majors 12 and 13 still run PostGIS 3.6, whose -scripts
# package bundles it. Majors 14 and 15 are on 3.7 with no tiger package at all.
case "${major}" in
    14|15) ;;
    *) echo postgis_tiger_geocoder ;;
esac
