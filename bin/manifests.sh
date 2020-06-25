#!/usr/bin/env bash
docker inspect --format='{{index .RepoDigests 0}}' python:3.8-alpine > manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "python --version" >> manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "pip -V" >> manifest.alpine
docker run --rm -it turbointegrations/base:alpine-build sh -c "pip freeze" >> manifest.alpine

docker inspect --format='{{index .RepoDigests 0}}' python:3.8-slim-buster > manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "python --version" >> manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "pip -V" >> manifest.slim-buster
docker run --rm -it turbointegrations/base:slim-buster-build sh -c "pip freeze" >> manifest.slim-buster

docker inspect --format='{{index .RepoDigests 0}}' registry.access.redhat.com/ubi8/python-38 > manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "python --version" >> manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "pip -V" >> manifest.rhel
docker run --rm -it turbointegrations/base:rhel-build sh -c "pip freeze" >> manifest.rhel
