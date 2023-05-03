# DevOps NEORIS Technical Test

## Introduction

This is a technical test for DevOps NEORIS position. The test is divided in two parts:

1. [API Rest Microservice](#api-rest-microservice)
2. [CI/CD](#cicd)

## API Rest Microservice

Microservice based in nodejs -nestjs whit two endpoints:

1. /generate-token

a simulated endpoint to generate a token, this endpoint is not protected by any authentication method.

2. /DevOps

endpoint protected by a token, that received body whit json format and return a message: 

```
{
  "message": "Hello Juan Perez your message will be send"
}
```

## CI/CD

The goal of this part is to create a CI/CD pipeline using GitHub Actions. The pipeline should be triggered when a pull request is created and should be executed in environment AWS. The pipeline should run the following steps:

1. Unit test

- Run unit test for the microservice with jest showint result in console.

2. Build

- Build the docker image for the microservice and push it to a docker registry AWS ECR.

3. Deploy

- Deploy the microservice in AWS using terraform.