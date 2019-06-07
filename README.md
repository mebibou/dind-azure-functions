# dind-azure-functions
Docker image containing Azure Functions Core Tools, to use as dind

[![Docker Build Status](https://img.shields.io/docker/build/mebibou/dind-azure-functions.svg)](https://hub.docker.com/r/mebibou/dind-azure-functions/)

This docker is build from `docker:latest` and can be used in a `.gitlab-ci.yml` to publish functions apps for example:

```yaml
image: mebibou/dind-azure-functions:latest

services:
  - docker:dind

build:
  script:
    - func azure functionapp publish <func-name> --build-native-deps
```

