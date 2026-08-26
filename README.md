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

Deploy the site by tagging and pushing a commit:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Builds between releases use Git's descriptive form, such as
`v1.0.0-2-gb2544f5`.
