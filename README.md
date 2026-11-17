# docker-verification-postgres

The [Databasus](https://github.com/databasus/databasus) restore-verification image
(`docker.io/databasus/verification-postgres:<major>`) **plus** the PostGIS extensions it
is missing: `postgis_tiger_geocoder`, `address_standardizer` and
`address_standardizer_data_us`.

Since PostGIS 3.7, PGDG ships the tiger geocoder and the address standardizer as
separate packages that the upstream image does not install. Restoring a dump that uses
them (for example from the `postgis/postgis` image, which enables the tiger geocoder by
default) fails verification with:

```
ERROR: extension "postgis_tiger_geocoder" is not available
```

This repository is a stopgap until upstream installs these packages. Once it does,
switch back to the default image and archive this repository.

## Images

| Registry | Image |
|---|---|
| GitHub Container Registry | `ghcr.io/jee-r/verification-postgres` |

Platforms: `linux/amd64`, `linux/arm64`.

### Tags

| Tag | Description |
|---|---|
| `12` … `18` | Latest build for that PostgreSQL major (what the agent pulls) |
| `<major>-<short-sha>` | Immutable build reference |

### Extensions per major

| Major | PostGIS | `address_standardizer` | `postgis_tiger_geocoder` |
|---|---|---|---|
| 12, 13 | 3.6 | ✅ (upstream) | ✅ (upstream) |
| 14, 15 | 3.7 | ✅ (added) | ❌ not packaged by PGDG |
| 16, 17, 18 | 3.7 | ✅ (added) | ✅ (added) |

[`scripts/extensions.sh`](scripts/extensions.sh) is the single source of truth for this
list. The build fails if any listed extension is missing, and CI starts every image and
runs `CREATE EXTENSION` for each of them.

## Usage

The Databasus verification agent appends `:<major>` to its image repository. Point it at
this one:

```
verificationPgImageRepo = ghcr.io/jee-r/verification-postgres
```

## Following upstream

- Each upstream major is a separate `FROM …@sha256:… AS base-<major>` stage in the
  [`Dockerfile`](Dockerfile), so Renovate can track every digest.
- Renovate groups all digest bumps into one PR and enables GitHub native auto-merge on
  it: GitHub merges as soon as the required `Build_Test result` check passes, without
  waiting for the next Renovate run. The merge to `main` triggers `Deploy`.
- `Deploy` also runs weekly to pick up PGDG package updates.

One-time repository setup for auto-merge:

1. Settings → General → enable **Allow auto-merge**.
2. Settings → Rules → add a ruleset on `main` with **Require status checks to pass**,
   requiring `Build_Test result` (add yourself to the bypass list to keep pushing
   directly to `main`).

When upstream adds a new PG major, add a `base-<major>` stage and the major to both
workflow matrices.

## Build locally

```sh
docker build --network host --build-arg PG_MAJOR=17 -t verification-postgres:17 .
sh scripts/test.sh verification-postgres:17 17
```

With Podman, set `CONTAINER_ENGINE=podman` for the test script.

## License

[Apache-2.0](LICENSE), like Databasus. See [NOTICE](NOTICE), which reproduces the
Databasus NOTICE (including its trademark terms) and lists the changes made to the
upstream image. Both files ship in the image under `/usr/share/doc/verification-postgres/`.

Third-party software in the image keeps its own license (PostgreSQL License for
PostgreSQL, GPL-2.0-or-later for PostGIS and its extensions); see
`/usr/share/doc/<package>/copyright` in the image.

This project is not affiliated with or endorsed by Databasus.
