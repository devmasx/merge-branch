#!/usr/bin/env sh
# Builds the action image and runs, inside it, the unit tests and an end-to-end
# smoke test of lib/index.rb. Same script locally and in CI.
# No GitHub token or network needed: the smoke tests only hit paths that end
# before any API call.
set -eu

IMAGE="${IMAGE:-merge-branch:test}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Building $IMAGE (same Dockerfile GitHub uses)"
docker build -q -t "$IMAGE" "$ROOT" >/dev/null

echo "==> Unit tests (rspec)"
docker run --rm -v "$ROOT":/src -w /src "$IMAGE" \
  sh -c "gem install rspec -v '~> 3.13' --no-document >/dev/null && rspec"

run_action() {
  docker run --rm -v "$ROOT/fixtures":/fixtures \
    -e GITHUB_EVENT_PATH=/fixtures/event_pull_requet_labeled.json \
    -e GITHUB_REPOSITORY=devmasx/test \
    -e INPUT_GITHUB_TOKEN=dummy \
    -e INPUT_TARGET_BRANCH=develop \
    "$@" "$IMAGE" 2>&1
}

echo "==> Smoke: label does not match -> skip, exit 0"
out="$(run_action -e INPUT_TYPE=labeled -e INPUT_LABEL_NAME='other label')"
echo "$out" | grep -q "Neutral: skip merge" || { echo "FAIL: $out"; exit 1; }

echo "==> Smoke: invalid type -> fails"
if out="$(run_action -e INPUT_TYPE=bogus)"; then
  echo "FAIL: expected non-zero exit, got: $out"; exit 1
fi
echo "$out" | grep -q "Error: Invalid type" || { echo "FAIL: $out"; exit 1; }

echo "==> All good"
