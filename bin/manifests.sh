#!/usr/bin/env bash

# Provided the suffix of a manifest file, this will return which version component
# if any needs to be incremented for semantic versioning
#
# Return values are 3==Major 2==Minor 1==Patch 0==No Change
determine_increment () {
  manifest_suffix=$1
  prev_len=$(wc -l < previous-manifest.$manifest_suffix)
  cur_len=$(wc -l < manifest.$manifest_suffix)
  diff_out=$(diff previous-manifest.$manifest_suffix manifest.$manifest_suffix)

  echo "$diff_out"

  if [[ "$prev_len" -gt "$cur_len" ]]
  then
    return 3
  fi

  if [[ "$prev_len" -lt "$cur_len" ]]
  then
    return 2
  fi

  if [[ ! -z "$diff_out" ]]
  then
    return 1
  fi

  return 0
}

source VERSION

ls manifest.* 1> /dev/null 2>&1
FIRST_RUN=$?

if [[ "$FIRST_RUN" -eq "0" ]]
then
  for i in `ls manifest.*`
  do
    mv $i previous-$i
  done
else
  echo "No previous manifests found. Building manifests for the first time, and using the version numer already in ./VERSION"
fi

docker inspect --format='{{index .RepoDigests 0}}' python:3.8-alpine > manifest.alpine
docker run --rm -i turbointegrations/base:alpine-build sh -c "python --version" >> manifest.alpine
docker run --rm -i turbointegrations/base:alpine-build sh -c "pip -V" >> manifest.alpine
docker run --rm -i turbointegrations/base:alpine-build sh -c "pip freeze" >> manifest.alpine

docker inspect --format='{{index .RepoDigests 0}}' python:3.8-slim-buster > manifest.slim-buster
docker run --rm -i turbointegrations/base:slim-buster-build sh -c "python --version" >> manifest.slim-buster
docker run --rm -i turbointegrations/base:slim-buster-build sh -c "pip -V" >> manifest.slim-buster
docker run --rm -i turbointegrations/base:slim-buster-build sh -c "pip freeze" >> manifest.slim-buster

docker inspect --format='{{index .RepoDigests 0}}' registry.access.redhat.com/ubi8/python-38 > manifest.rhel
docker run --rm -i turbointegrations/base:rhel-build sh -c "python --version" >> manifest.rhel
docker run --rm -i turbointegrations/base:rhel-build sh -c "pip -V" >> manifest.rhel
docker run --rm -i turbointegrations/base:rhel-build sh -c "pip freeze" >> manifest.rhel

if [[ "$FIRST_RUN" -ne "0" ]]
then
  exit 0
fi

echo "Alpine Manifest Changes..."
determine_increment "alpine"
alpine_increment=$?

echo "Slim Buster Manifest Changes..."
determine_increment "slim-buster"
slim_buster_increment=$?

echo "RHEL Manifest Changes..."
determine_increment "rhel"
rhel_increment=$?

# All three should be incremented the same, in theory, but if they aren't we should bail.
if [[ "$alpine_increment" -eq "$slim_buster_increment" && "$slim_buster_increment" -eq "$rhel_increment" ]]
then
  case $alpine_increment in
    3)
      MAJOR=$((MAJOR+1))
      MINOR=0
      PATCH=0
      echo "Major version increment detected. Manual intervention required"
      exit 1
      ;;
    2)
      MINOR=$((MINOR+1))
      PATCH=0
      ;;
    1)
      PATCH=$((PATCH+1))
      ;;
  esac

  cat << EOF > VERSION
MAJOR=$MAJOR
MINOR=$MINOR
PATCH=$PATCH
EOF

else
  echo "Detected different versioning increments for one or more images. This suggests that one of them is out of sync. Manual intervention required"
  echo "Alpine Incremented: $alpine_increment"
  echo "Slim Buster Incremented: $slim_buster_increment"
  echo "RHEL Incremented: $rhel_increment"
  exit 1
fi
