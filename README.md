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

# Build

There are three flavors of this image, based on external canonical images.

1. turbointegrations/base:`<version>`-alpine - Based on [python:3.8-alpine](https://hub.docker.com/_/python)
2. turbointegrations/base:`<version>`-slim-buster - Based on [python:3.8-slim-buster](https://hub.docker.com/_/python)
3. turbointegrations/base:`<version>`-rhel - Based on [registry.access.redhat.com/ubi8/python-38](https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a)

## Automated build

The Jenkins workflow will be triggered nightly to build new images. A new image, with an automatically incremented semantic version number will be created if any changes are detected.

The Jenkins workflow will;
* Check out the master branch of the repository
* Build all three flavors of the image, per the instructions in the `Jenkinsfile`
* Push all three flavors of the image to the docker hub repository.
