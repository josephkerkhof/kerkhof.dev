# kerkhof.dev

My personal website, built with Hugo and deployed by GitHub Actions to
Cloudflare.

Made with [Hugo](https://gohugo.io/).

The site uses first-party layouts and CSS in `layouts/` and `assets/css/`; it has no external theme dependency.

## Architecture

Production releases follow this path:

```text
Git tag -> GitHub Actions -> Hugo -> Workers Static Assets -> kerkhof.dev
                            |
Git LFS content media ------+-> Cloudflare R2 -> media.kerkhof.dev
```

`wrangler.jsonc` defines the assets-only `kerkhof-dev` Worker and its
`kerkhof.dev` custom domain. There is no Worker application code. The
`kerkhof-dev-media` R2 bucket stores article photos, animations, and video;
its `media.kerkhof.dev` custom domain is configured in Cloudflare because R2
bucket domains are not part of the Worker configuration.

HTML, XML, CSS, fonts, the profile image, and other structural files are
Workers Static Assets. Content media tracked by Git LFS is delivered from R2.
Cloudflare's `r2.dev` public URL is not enabled.

## Local Development

```bash
# Start the development server
make server

# Build the website
make build

# Build and serve through the local Workers runtime
make worker-dev
```

The Makefile sets the footer revision from the local Git state. Direct Hugo
commands fall back to `UNRELEASED` unless `HUGO_PARAMS_RELEASE` is set.
The Hugo and Workers development servers use local page-bundle media, so local
work does not depend on R2. Production builds use `params.mediaBaseURL` and
the `media-url.html` partial to generate R2 URLs.

## Cloudflare Deployment

Wrangler is configured to upload Hugo's `public/` directory as static assets.
Useful local checks are:

```bash
make media-check
HUGO_ENVIRONMENT=production HUGO_ENV=production make build HUGO_ARGS=--minify
make media-verify
make media-prune
wrangler deploy --dry-run
```

`make media-sync` uploads Git LFS content media to `kerkhof-dev-media`. It
stores a SHA-256 and metadata manifest in R2, uploads only missing or changed
objects, sets the MIME type and `Cache-Control: public, max-age=86400`, and
never deletes remote objects. Reaction objects also receive attachment
metadata so their cross-origin download links remain downloads.
`make media-verify` checks that production R2 URLs exactly match the LFS media
set. `make media-prune` removes R2-managed duplicates from the
generated `public/` directory before Worker deployment. A full authenticated
local deployment is `make worker-deploy`, equivalent to:

```bash
make media-sync
HUGO_ENVIRONMENT=production HUGO_ENV=production make build HUGO_ARGS=--minify
make media-verify
make media-prune
wrangler deploy
```

The Worker custom domain, asset behavior, and baseline response headers are
declarative in `wrangler.jsonc` and `static/_headers`. The R2 bucket, its
custom domain, generated DNS records/certificates, and optional Web Analytics
site live in Cloudflare. The one-time R2 setup commands are:

```bash
wrangler r2 bucket create kerkhof-dev-media
wrangler r2 bucket domain add kerkhof-dev-media \
  --domain media.kerkhof.dev \
  --zone-id "$CLOUDFLARE_ZONE_ID" \
  --min-tls 1.2
```

Find the zone ID in the Cloudflare dashboard and provide it through the local
`CLOUDFLARE_ZONE_ID` environment variable. Do not commit account or zone IDs.

## Analytics

Cloudflare Web Analytics uses manual setup. Automatic edge injection does not
reach HTML that Workers Static Assets serves, so the beacon is rendered by
`layouts/partials/footer.html` in production builds only.

Add `kerkhof.dev` under account **Analytics > Web analytics**, open **Manage
site**, and select **Enable with JS Snippet installation**. Copy the site token
from the shown snippet into `params.cloudflareAnalyticsToken` in `config.toml`.
The token is public page data, not a secret. Leaving the param empty omits the
beacon.

## Media

Keep small theme and structural assets under `static/` or `assets/`. Put
content photos, animated GIFs, and video in the relevant Hugo leaf bundle
under `content/`. Large content media should remain Git LFS tracked in
`.gitattributes` and be marked for R2 in the bundle front matter:

```yaml
resources:
  - src: "*.mp4"
    params:
      r2: true
```

The source file must stay in the page bundle: Hugo uses it for resource
discovery and local development. R2 object keys match the published Hugo path,
for example `content/posts/example/demo.mp4` becomes
`https://media.kerkhof.dev/posts/example/demo.mp4`. Run `make media-check`
after adding media. Then run a production build and `make media-verify` to
catch missing `r2 = true` metadata before `make media-sync` uploads it.

## GitHub Actions

The deployment workflow requires these repository secrets:

- `CLOUDFLARE_ACCOUNT_ID`: the account ID shown in the Cloudflare dashboard
- `CLOUDFLARE_API_TOKEN`: a scoped Cloudflare API token

The token needs these permissions, limited to Joseph@kerkhof.dev's account
and the `kerkhof.dev` zone:

- Account: Workers Scripts Write
- Account: Workers R2 Storage Write
- Account: Account Settings Read
- Zone (`kerkhof.dev` only): Workers Routes Write
- Zone (`kerkhof.dev` only): Zone Read

R2 bucket and custom-domain provisioning is performed once locally, so CI
does not need DNS Write, SSL certificate, or broader zone permissions. R2's
bucket-scoped Object Read & Write credentials apply only to the S3-compatible
API; this workflow deliberately uses Wrangler's REST API and its single
Cloudflare token instead of adding S3 credentials.

## Releases

Add notable changes to the `Unreleased` section of `CHANGELOG.md`. Cut a
release and deploy it with:

```bash
make release VERSION=1.0.2
git push origin HEAD v1.0.2
```

The release command requires a clean working tree. It dates the `Unreleased`
section, commits the changelog, and creates an annotated tag. Pushing that
commit and tag triggers the deployment workflow, which checks out Git LFS,
syncs R2 media, builds Hugo, and deploys the Worker. Ordinary branch pushes do
not deploy production. Manual workflow dispatch remains available.

Builds between releases use Git's descriptive form, such as
`v1.0.0-2-gb2544f5`.
