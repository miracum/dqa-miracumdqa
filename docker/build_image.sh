#!/bin/bash

read -s -p "\nPlease enter your username to https://gitlab.miracum.org/:" gitusername
read -s -p "\nPlease enter your password to https://gitlab.miracum.org/: " gitpassword

echo $gitusername

docker build --build-arg $gitpassword  --build-arg $gitusername -f Dockerfile -t dqa-miracum .

docker-compose up -d
