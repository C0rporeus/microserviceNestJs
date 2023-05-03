# DevOps NEORIS Technical Test

## Introduction

This is a technical test for DevOps NEORIS position. The test is divided in two parts:

1. [API Rest Microservice](#api-rest-microservice)
2. [CI/CD](#cicd)
3. [IaC](#iac)

## API Rest Microservice

Microservice based in nodejs -nestjs whit two endpoints:

1. /generate-token

a simulated endpoint to generate a token (verb GET), this endpoint is not protected by any authentication method.

request curl example:

```
curl --location --request GET 'http://nestjs-alb-543552772.us-east-1.elb.amazonaws.com/generate-token'
```

2. /DevOps

endpoint protected by a token (verb POST), that received body whit json format and return a message: 

```
{
  "message": "Hello Juan Perez your message will be send"
}
```
request curl example:

```
curl --location 'http://nestjs-alb-543552772.us-east-1.elb.amazonaws.com/DevOps' \
--header 'X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c' \
--header 'X-JWT-KWY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImV4YW1wbGVfdXNlciIsInN1YiI6MSwiaWF0IjoxNjgzMDk3MDQzLCJleHAiOjE2ODMwOTcxMDN9.tAyYbetvK7_cYTuo8Y7FMN5t7szL4Zu1hO9qyZWTzKE' \
--header 'Content-Type: application/json' \
--data '{ 
    "message" : "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec" : 45 
}'
```

## CI/CD

The goal of this part is to create a CI/CD pipeline using GitHub Actions. The pipeline should be triggered when a pull request or merge whit main branch and should be executed in environment AWS. The pipeline should run the following steps:

1. Unit test

- Run unit test for the microservice with jest showint result in console.

2. Build

- Build the docker image for the microservice and push it to a docker registry AWS ECR.

3. Deploy

- Deploy the microservice in AWS using terraform.

## IaC

- Define backend for terraform in S3 and DynamoDB.
- Create VPC in AWS whit two subnets private and public.
- Security group for the microservice and services ECS and ECR.
- Create NAT Gateway EIP and VPC Endpoints.
- Define roles and policies for the microservice and services ECS and ECR.
- Create ECS cluster and service.
- Create ALB and target group.
- Create profile logs for VPC, ECS and ECR.


## How to run

### API Rest Microservice

1. Clone the repository

```
git clone
```

2. Install dependencies

```
yarn install
```
3. Building the app

```
yarn run build
```

4. Running the app

```
yarn run start:dev
```
