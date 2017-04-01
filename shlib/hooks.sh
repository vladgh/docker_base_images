#!/usr/bin/env bash

# VARs
GIT_TAG="$(git describe --always --tags)"

# Build hook
build_hook(){
  git_change_depth
  docker_build_image
}

# Post-Push hook
post_push_hook(){
  tag_semantic_versions
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
