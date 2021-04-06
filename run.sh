#!/bin/bash

aws sso login --profile PowerUserAccess-043802220583-SSO

# docker build -t terratrain:latest .
docker run --rm -it -v ~/.aws:/terraTrain/.aws terratrain
