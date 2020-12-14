FROM anapsix/alpine-java:8

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

ENV WM_PACKAGE wiremock
ARG WM_VERSION=2.27.2

RUN mkdir /$WM_PACKAGE
WORKDIR /$WM_PACKAGE

RUN curl -sSL -o $WM_PACKAGE.jar https://repo1.maven.org/maven2/com/github/tomakehurst/$WM_PACKAGE-standalone/$WM_VERSION/$WM_PACKAGE-standalone-$WM_VERSION.jar
EXPOSE 80

ENTRYPOINT ["java","-jar","wiremock.jar","--verbose", "--port", "80"]