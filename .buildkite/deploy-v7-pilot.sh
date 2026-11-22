#!/usr/bin/env bash
set -euo pipefail

STACK_PATH="buildkite/buildkite-agent-v7-pilot.yaml"

echo "Validating ${STACK_PATH}"
docker compose run --rm sceptre validate "${STACK_PATH}"

echo "Launching ${STACK_PATH} without pruning any other stacks"
docker compose run --rm sceptre launch -y "${STACK_PATH}"
