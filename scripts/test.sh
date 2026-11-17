#!/bin/sh
# Start the image and run CREATE EXTENSION for every extension it guarantees.
#
# Usage: test.sh <image> <pg_major>
# Env:   CONTAINER_ENGINE (default: docker), TIMEOUT seconds (default: 120)
set -eu

image="${1:?usage: test.sh <image> <pg_major>}"
major="${2:?usage: test.sh <image> <pg_major>}"
engine="${CONTAINER_ENGINE:-docker}"
timeout="${TIMEOUT:-120}"
script_dir="$(dirname "$0")"
name="verification-postgres-test-${major}-$$"

cleanup() {
    "${engine}" rm -f "${name}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

"${engine}" run -d --name "${name}" -e POSTGRES_PASSWORD=test "${image}" >/dev/null

# Probe over TCP: the entrypoint's temporary init server only listens on the
# unix socket, so a TCP answer means the final server is up.
elapsed=0
until "${engine}" exec "${name}" pg_isready -q -h 127.0.0.1 -U postgres; do
    elapsed=$((elapsed + 1))
    if [ "${elapsed}" -ge "${timeout}" ]; then
        echo "ERROR: PostgreSQL did not start within ${timeout}s" >&2
        "${engine}" logs "${name}" >&2
        exit 1
    fi
    sleep 1
done

sql=""
for ext in $(sh "${script_dir}/extensions.sh" "${major}"); do
    sql="${sql}CREATE EXTENSION IF NOT EXISTS ${ext} CASCADE;"
done
sql="${sql}SELECT extname, extversion FROM pg_extension ORDER BY extname;"

"${engine}" exec "${name}" psql -h 127.0.0.1 -U postgres -v ON_ERROR_STOP=1 -c "${sql}"
echo "PG ${major}: OK"
