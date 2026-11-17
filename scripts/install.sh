#!/bin/sh
# Install the PGDG packages providing the PostGIS extensions missing from the
# upstream image, then fail if any extension listed by extensions.sh is still
# absent. A missing extension must break the build: the verification agent
# tolerates missing extensions at restore time and would otherwise report an
# incomplete restore as verified.
#
# Usage: install.sh <pg_major>
set -eu

major="${1:?usage: install.sh <pg_major>}"
script_dir="$(dirname "$0")"
ext_dir="/usr/share/postgresql/${major}/extension"

# Map an extension to the PGDG package that ships it (PostGIS >= 3.7 split).
package_for() {
    case "$1" in
        address_standardizer|address_standardizer_data_us)
            echo "postgresql-${major}-address-standardizer" ;;
        postgis_tiger_geocoder)
            echo "postgresql-${major}-postgis-tiger-geocoder" ;;
        *)
            # Part of the base postgis packages: nothing extra to install.
            ;;
    esac
}

required="$(sh "${script_dir}/extensions.sh" "${major}")"

# Only install what the upstream image lacks, so majors still on PostGIS 3.6
# (whose -scripts package bundles everything) are left untouched.
packages=""
for ext in ${required}; do
    if [ ! -f "${ext_dir}/${ext}.control" ]; then
        pkg="$(package_for "${ext}")"
        case " ${packages} " in
            *" ${pkg} "*) ;;
            *) packages="${packages} ${pkg}" ;;
        esac
    fi
done

if [ -n "${packages# }" ]; then
    apt-get update
    # shellcheck disable=SC2086
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${packages}
    rm -rf /var/lib/apt/lists/*
fi

missing=""
for ext in ${required}; do
    [ -f "${ext_dir}/${ext}.control" ] || missing="${missing} ${ext}"
done

if [ -n "${missing}" ]; then
    echo "ERROR: missing extensions for PG ${major}:${missing}" >&2
    exit 1
fi

echo "PG ${major}: all required extensions present:" ${required}
