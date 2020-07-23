# Wiremock Service Virtualization example

## Basic explanation
This project explains how to create service virtualization using WireMock.
We have innumerable benefits using it, as:
* provide an endpoint for not completed APIs
* provide an API for the 3rd parties dependencies you can't control
* when needed to be consumed from different perspectives (backend, frontend, test)

The main purpose here is to create a Docker image with all the mappings (request and responses) you can share across your team/company and use it in any test level without duplication and consuming it in one centralized point. E.g: integration, functional API test, etc...

## What does this service virtualization do?
First of all: this is a didact example. I know that this domain might be complex but I ask you to follow the basic example logic. 

This simulates an account verification where we send two small deposits to an account. Later on, you need to add the amount of those two deposits to validate the process.

### Sending the deposits
You must use the endpoint `POST /api/v1/check` with a specific IBAN (account number in Europe). The mapping will respond only if we send the expected IBAN, that is _NL13ABNA8672131290_

You must pass it in the body as a JSON object, like this:
```json
{
  "iban": "NL13ABNA8672131290"
}
```

If you send a different, but valid IBAN format, the API will respond with a HTTP 404 and the following body
```json
{
    "message": "Account not found!"
}
```

### Verify the deposite
We are going to verify the accound filling in the deposits we have received to confirm the operation.
You must use the endpoint `POST /api/v1/verify` with the ID, account 1 and account 2 you have received when you sent the deposit

You must pass it in the body as a JSON object, like this:
```json
{
  "id": "b3e3541fd0577426d1d190cfc04d4d00",
  "deposits": {
        "first": 0.06,
        "second": 0.10
    }
}
```


## Steps to use this project

### Pre-condition
* You must have Docker installed in your machine

### Steps
1. Clone this project
2. Open your Terminal/Command Prompt
3. Go to the project folder
4. Execute the following docker command to build and start the container
```bash
docker-compose up --build
```

You will see something like this:
```
Building wiremock
Step 1/9 : FROM anapsix/alpine-java:8
 ---> 745575fbfe52
Step 2/9 : RUN apk add --update curl &&     rm -rf /var/cache/apk/*
 ---> Using cache
 ---> b54b1118f3ee
Step 3/9 : ENV WM_PACKAGE wiremock
 ---> Using cache
 ---> b7694d2dd801
Step 4/9 : ARG WM_VERSION=2.27.1
 ---> Using cache
 ---> 56d2a956525b
Step 5/9 : RUN mkdir /$WM_PACKAGE
 ---> Using cache
 ---> 5f3214602a0b
Step 6/9 : WORKDIR /$WM_PACKAGE
 ---> Using cache
 ---> e952c4744512
Step 7/9 : RUN curl -sSL -o $WM_PACKAGE.jar https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/2.27.1/wiremock-standalone-2.27.1.jar
 ---> Using cache
 ---> 5dd98cc7d6ab
Step 8/9 : EXPOSE 80
 ---> Using cache
 ---> b9f1c60c5d31
Step 9/9 : ENTRYPOINT ["java","-jar","wiremock.jar","--verbose", "--port", "80"]
 ---> Using cache
 ---> 7e00a72f527f

Successfully built 7e00a72f527f
Successfully tagged wiremock-custom:latest
Starting wiremock-payment-gateway ... done
Attaching to wiremock-payment-gateway
wiremock-payment-gateway | 2020-07-23 18:52:17.753 Verbose logging enabled
wiremock-payment-gateway | SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
wiremock-payment-gateway | SLF4J: Defaulting to no-operation (NOP) logger implementation
wiremock-payment-gateway | SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
wiremock-payment-gateway | 2020-07-23 18:52:18.813 Verbose logging enabled
wiremock-payment-gateway |  /$$      /$$ /$$                     /$$      /$$                     /$$      
wiremock-payment-gateway | | $$  /$ | $$|__/                    | $$$    /$$$                    | $$      
wiremock-payment-gateway | | $$ /$$$| $$ /$$  /$$$$$$   /$$$$$$ | $$$$  /$$$$  /$$$$$$   /$$$$$$$| $$   /$$
wiremock-payment-gateway | | $$/$$ $$ $$| $$ /$$__  $$ /$$__  $$| $$ $$/$$ $$ /$$__  $$ /$$_____/| $$  /$$/
wiremock-payment-gateway | | $$$$_  $$$$| $$| $$  \__/| $$$$$$$$| $$  $$$| $$| $$  \ $$| $$      | $$$$$$/ 
wiremock-payment-gateway | | $$$/ \  $$$| $$| $$      | $$_____/| $$\  $ | $$| $$  | $$| $$      | $$_  $$ 
wiremock-payment-gateway | | $$/   \  $$| $$| $$      |  $$$$$$$| $$ \/  | $$|  $$$$$$/|  $$$$$$$| $$ \  $$
wiremock-payment-gateway | |__/     \__/|__/|__/       \_______/|__/     |__/ \______/  \_______/|__/  \__/
wiremock-payment-gateway | 
wiremock-payment-gateway | port:                         80
wiremock-payment-gateway | enable-browser-proxying:      false
wiremock-payment-gateway | disable-banner:               false
wiremock-payment-gateway | no-request-journal:           false
wiremock-payment-gateway | verbose:                      true
wiremock-payment-gateway | 
```

## Testing

### Check the account
Send the following request
```bash
curl -d '{"iban":"NL13ABNA8672131290"}' -H "Content-Type: application/json" -X POST http://localhost/api/v1/check
```

Expected result
```json
{
    "id":"b3e3541fd0577426d1d190cfc04d4d00",
    "deposits":{
       "first":0.06,
       "second":0.10
    }
 }
```

### Verify the deposit
Send the following request
```bash
curl -d '{"id":"b3e3541fd0577426d1d190cfc04d4d00","deposits":{"first": 0.06,"second": 0.10}}' -H "Content-Type: application/json" -X POST http://localhost/api/v1/verify
```

Expected result
```json
{
    "message": "Account verification completed!"
}
```