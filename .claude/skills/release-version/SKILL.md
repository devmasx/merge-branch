---
name: release-version
description: Decide whether merged PRs on merge-branch need a new version and, if so, which one (major/minor/patch), and cut the release — CHANGELOG, git tag, moving major tag and GitHub Release (which is what updates the Marketplace). Use after a PR is merged to master, when asked "does this need a release", "bump the version", "release", "what's unreleased", or when someone reports that a feature on master is missing for them.
---

# Releasing merge-branch

## How "deploying" works for a Docker action

There is no build or publish step. GitHub builds the `Dockerfile` **from whatever ref the
user's workflow names**, on every run:

| The user writes | Gets changes | Risk |
|---|---|---|
| `devmasx/merge-branch@master` | **the moment** a PR is merged to `master` | a bad merge breaks everyone using `@master` at once |
| `devmasx/merge-branch@v1.4.0` | never, until they change it | none, but they miss fixes |
| `devmasx/merge-branch@v1` (moving major tag) | on every release you move `v1` to | breaks them only if you release something broken |

So **pushing to `master` is already a deploy** for `@master` users. A version (tag) is what
everyone else gets. Releasing = tag + GitHub Release. The Marketplace listing only updates
from a GitHub Release.

## Step 1 — what's unreleased

```sh
git fetch --tags
LAST=$(git tag --list 'v*' --sort=-v:refname | head -1)
git log --oneline "$LAST"..origin/master
gh pr list --state merged --search "merged:>$(git log -1 --format=%cs "$LAST")" \
  --json number,title,files --jq '.[] | "#\(.number) \(.title) — \([.files[].path] | join(", "))"'
```

Tag history is inconsistent: both `1.4.0` (no `v`, marked Latest) and `v1.4.0` exist on the same
release. Use `v*` tags from now on.

## Step 2 — does it need a version, and which one

Classify each PR by **what a user of the action sees**. The highest wins.

| Change | Bump | Examples from this repo |
|---|---|---|
| Removes or renames an input, changes a default, changes what gets merged, a merge that used to happen no longer does, `type` values change | **major** | (none yet) changing the default `type: labeled` would be one |
| New optional input, new `type`, new behaviour behind an opt-in | **minor** | #20 `message`, #28 `disable_fastforwards`, #15 GitHub Enterprise |
| Bug fix that keeps inputs and defaults; dependency bump that changes the image | **patch** | #9 empty-string inputs, #14 `addressable` bump |
| Only `README.md`, `docs/`, `spec/`, `script/`, `.github/`, `.claude/`, `screenshots/` | **no release** | #38, #41 |

Files that ship to users: `action.yml`, `Dockerfile`, `Gemfile`, `Gemfile.lock`, `lib/**`. If no
merged PR touches them, **no release is needed**. Say so and stop.

Watch out for:
- **Log messages are an interface.** People grep the step logs (`Neutral: skip merge`). Changing
  them is at least minor. Say so in the CHANGELOG.
- **`Dockerfile` base image changes** (e.g. Ruby 2.6 → 3.x) can break things silently. Treat
  them as minor at least, and test with a real workflow before tagging.
- `action.yml` `description` changes alone don't need a release, but they show up on the
  Marketplace only after one.

Output of this step: the list of PRs, the classification of each with its reason, and the
proposed version. **Show it to the user and wait for confirmation** before step 3.

## Step 3 — cut the release (only after confirmation)

Tags and releases are public and are pulled by other people's workflows. Confirm the version
first, and never move or delete an existing `vX.Y.Z` tag.

1. CI is green on `master` (`gh run list --branch master --limit 1`). If it isn't, stop.
2. Add a section to [`CHANGELOG.md`](../../../CHANGELOG.md) in the existing style:
   `## vX.Y.Z` then `- Description [#N](https://github.com/devmasx/merge-branch/pull/N)`.
   Commit it to `master` through a PR, like any other change.
3. Tag the merge commit and push it:
   ```sh
   git tag -a vX.Y.Z -m "vX.Y.Z" origin/master && git push origin vX.Y.Z
   ```
4. Move the major tag (this one *is* meant to move):
   ```sh
   git tag -fa vX -m "vX" vX.Y.Z && git push origin vX --force
   ```
   `v1` doesn't exist yet. Creating it is a one-off decision; ask before doing it the first time.
5. GitHub Release, which updates the Marketplace:
   ```sh
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "<the CHANGELOG section>" --latest
   ```

## Known state (2026-10-18)

The last release is v1.4.0 (2021-08-29). Unreleased on `master` and shipped to `@master` users
only: #20 `message`, #22 action logs, #28 `disable_fastforwards`. That makes the next release
**v1.5.0** (minor: new optional inputs, nothing removed). Re-check with step 1 before you rely
on this.
