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

The goal of this part is to create a CI/CD pipeline using Jenkins. The pipeline should be triggered when a pull request is created and should be executed in a temporary environment. The pipeline should run the following steps:

1. Terraform plan
2. Terraform apply
3. Terraform destroy
