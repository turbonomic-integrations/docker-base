#!/usr/bin/env bash

determine_version () {
  manifest_suffix=$1
  prev_len=$(wc -l previous-manifest.$manifest_suffx)
  cur_len=$(wc -l manifest.$manifest_suffix)

  if [$prev_len -gt $cur_len]
  then
    MAJOR=$(MAJOR+1)
    MINOR=0
    PATCH=0
    echo "$MAJOR.$MINOR.$PATCH"
    return
  fi

  if [$prev_len -lt $cur_len]
  then
    MINOR=$(MINOR+1)
    PATCH=0
    echo "$MAJOR.$MINOR.$PATCH"
    return
  fi


}

source VERSION

for i in `ls manifest.*`
do
  mv $i previous-$i
done

docker inspect --format='{{index .RepoDigests 0}}' python:3.8-alpine > manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "python --version" >> manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "pip -V" >> manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "pip freeze" >> manifest.alpine

determine_version "alpline"

docker inspect --format='{{index .RepoDigests 0}}' python:3.8-slim-buster > manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "python --version" >> manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "pip -V" >> manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "pip freeze" >> manifest.slim-buster

determine_version "slim-buster"

docker inspect --format='{{index .RepoDigests 0}}' registry.access.redhat.com/ubi8/python-38 > manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "python --version" >> manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "pip -V" >> manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "pip freeze" >> manifest.rhel

determine_version "rhel"
