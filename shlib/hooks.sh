#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
GIT_TAG="$(git describe --always --tags)"

# Build hook
run_build_hook(){
  deepen_git_repo
  docker_build_image
}

# Post-Push hook
run_post_push_hook(){
  tag_semantic_versions
  notify_webhook "${@:-}"
}

# Deepen repository history
# By default Docker HUB clones the repository with `--depth=1`. You should
# deepen the history of the original shallow repository (git describe needs the
# latest tags to work). Setting this to '50' should incorporate the latest tags,
# while still keeping the size rather small.
deepen_git_repo(){
  echo 'Deepen repository history'
  git pull --depth=50
}

# Build the image with the specified arguments
docker_build_image(){
  echo 'Build the image with the specified arguments'
  docker build \
    --build-arg VERSION="${GIT_TAG}" \
    --build-arg VCS_URL="$(git config --get remote.origin.url)" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    -t "$IMAGE_NAME" .
}

tag_semantic_versions(){
  local IFS=$' ' # required by the version components below

  # If tag matches semantic version
  if [[ "$GIT_TAG" != v* ]]; then
    echo "Version (${GIT_TAG}) does not match semantic version; Skipping..."
    return
  fi

  # Break the version into components
  semver="${GIT_TAG#v}"
  semver="${semver%%-*}"
  semver=( ${semver//./ } )

  major="${semver[0]}"
  minor="${semver[1]}"
  patch="${semver[2]}"

  # Publish patch version
  echo "Pushing patch version (${DOCKER_REPO}:${major}.${minor}.${patch})"
  docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${major}.${minor}.${patch}"
  docker push "${DOCKER_REPO}:${major}.${minor}.${patch}"

  # Publish minor version
  echo "Pushing minor version (${DOCKER_REPO}:${major}.${minor})"
  docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${major}.${minor}"
  docker push "${DOCKER_REPO}:${major}.${minor}"

  # Publish major version
  echo "Pushing major version (${DOCKER_REPO}:${major})"
  docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${major}"
  docker push "${DOCKER_REPO}:${major}"
}

notify_webhook(){
  local webhook="${1:-}"
  if [[ -n "${webhook:-}" ]]; then
    echo 'Notify webhook'
    curl -X POST "$webhook"
  fi
}
