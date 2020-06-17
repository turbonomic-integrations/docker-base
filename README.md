# Turbonomic Integrations Base Docker Image
This is a base docker image for solutions created by the Turbonomic Integration team, and deployed in a Turbo 7 Kubernetes environment.

# Contents
* Python 3.8
* Public Python Modules
  * vmtconnect
  * vmtplan
  * umsg
  * dateutils
  * pyyaml
* Private Python Modules
  * turbo_api_creds

# Build

There are three flavors of this image, based on external canonical images.

1. turbointegrations/base:<version>-alpine
  * Based on [python:3.8-alpine](https://hub.docker.com/_/python)
2. turbointegrations/base:<version>-slim-buster
  * Based on [python:3.8-slim-buster](https://hub.docker.com/_/python)
3. turbointegrations/base:<version>-rhel
  * Based on [registry.access.redhat.com/ubi8/python-38](https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a)

## Manual steps

Given that there is one private module (turbo_api_creds), this must be downloaded manually by someone with permissions to the private BitBucket.

In order to fetch this (and then later add it and check it in to this git repository), you can simply set your `username:password` as an environment variable named `bbcreds` then run the included `fetchwhl.sh`.

```
$ export bbcreds=username:password
$ ./fetchwhl.sh
```

## Automated build

(Future state) When new commits are pushed to master, a Jenkins workflow will be executed.

(Current state) The Jenkins workflow must be manually triggered.

The Jenkins workflow will;
* Check out the master branch of the repository
* Build all three flavors of the image, per the instructions in the `Jenkinsfile`
* Push all three flavors of the image to the docker hub repository.
