---
name: run-tests
description: How to run merge-branch's tests locally and what the CI runs — the action image build, the rspec unit tests and the smoke tests of lib/index.rb, all from one script (script/test.sh) inside the same Docker image GitHub uses. Use when asked to "run the tests", "check this works", "why is CI red", before opening a PR, or when adding a new test or a new input.
---

# Running the tests

## One command, local and CI

```sh
sh script/test.sh
```

CI ([`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)) runs exactly this on every
pull request and on every push to `master`. If it passes locally, it passes in CI. The only
requirement is Docker; you don't need Ruby, a GitHub token or network access to GitHub's API.

## What it does, and why it runs inside Docker

GitHub runs this action by building [`Dockerfile`](../../../Dockerfile) (`ruby:2.6.3-alpine`)
on every user's run. The local Ruby (3.x) is **not** what users run, so tests run in that image.

| Step | Catches |
|---|---|
| `docker build` | Dockerfile or `Gemfile.lock` no longer builds, which breaks the action for everyone |
| `rspec` in the image | Logic errors in `MergeBrachService` (validation, `labeled` / `now` rule) |
| Smoke: label doesn't match | `lib/index.rb` wiring: env → inputs → skip with exit 0 |
| Smoke: invalid type | Validation fails the step with a non-zero exit |

`rspec` is installed on the fly (`gem install rspec`) and is not in the `Gemfile`, so it never
ends up in the image users run.

## What is NOT tested (be honest about it in reviews)

- **The real merge** (`client.compare` / `client.merge`). It needs a token and a repo. The smoke
  tests stop before any API call on purpose.
- `head_to_merge` / `from_branch` / `GITHUB_SHA` resolution, `disable_fastforwards`, `message`.
  All of these live in `lib/index.rb` as top-level code, which is hard to unit-test.

If a change touches those paths, test it for real before releasing: in a throwaway repo, with
a workflow that points to the branch, e.g. `uses: devmasx/merge-branch@<your-branch>`.

## Adding a test

- **Unit:** add it to [`spec/merge_brach_service_spec.rb`](../../../spec/merge_brach_service_spec.rb).
  Always use `raise_error(RuntimeError, /message/)`. A bare `raise_error()` also passes on an
  `ArgumentError` and hides the bug (this happened: the "invalid type" test passed for the
  wrong reason until it was fixed).
- **Smoke:** add a block to [`script/test.sh`](../../../script/test.sh) using `run_action`
  with the `INPUT_*` env vars. Only for paths that end before the API is called.
- **New event fixture:** put the payload in [`fixtures/`](../../../fixtures) and point
  `GITHUB_EVENT_PATH` to it.

## When it fails

| Symptom | Likely cause |
|---|---|
| `docker build` fails at `bundle install` | `Gemfile.lock` changed in a way that doesn't work with Ruby 2.6 / Bundler 1.17 |
| `Cannot connect to the Docker daemon` | Docker isn't running locally |
| rspec `0 examples` | Ran from the wrong directory; the script mounts the repo root at `/src` |
| Smoke `FAIL:` with the output | A log message in `lib/index.rb` changed. The smoke tests grep for `Neutral: skip merge` and `Error: Invalid type`. If the change is intended, update both the script and [`docs/permissions-and-failures.md`](../../../docs/permissions-and-failures.md) |
