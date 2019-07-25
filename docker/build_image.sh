#!/bin/bash

read -p "\nPlease enter your username to https://gitlab.miracum.org/: " gitusername
read -s -p "\nPlease enter your password to https://gitlab.miracum.org/: " gitpassword

docker build --build-arg gitpassword=$gitpassword  --build-arg gitusername=$gitusername -f Dockerfile -t dqa-miracum .

docker-compose -f docker-compose.i2b2.yml up -d
