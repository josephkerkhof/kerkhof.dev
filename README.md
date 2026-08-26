# kerkhof.dev

My personal website automatically built and deployed using GitHub Actions.

Made with [Hugo](https://gohugo.io/).

The site uses first-party layouts and CSS in `layouts/` and `assets/css/`; it has no external theme dependency.

## Commands

```bash
# Start the development server
make server

# Build the website
make build
```

The Makefile sets the footer revision from the local Git state. Direct Hugo
commands fall back to `UNRELEASED` unless `HUGO_PARAMS_RELEASE` is set.

## Releases

Add notable changes to the `Unreleased` section of `CHANGELOG.md`. Cut a
release and deploy it with:

```bash
make release VERSION=1.0.2
git push origin HEAD v1.0.2
```

The release command requires a clean working tree. It dates the `Unreleased`
section, commits the changelog, and creates an annotated tag. Pushing that
commit and tag triggers the deployment workflow.

Builds between releases use Git's descriptive form, such as
`v1.0.0-2-gb2544f5`.
