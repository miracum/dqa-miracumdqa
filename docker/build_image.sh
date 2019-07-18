#!/bin/bash

read -s -p "Please enter your username to https://gitlab.miracum.org/: " gitusername
read -s -p "Please enter your password to https://gitlab.miracum.org/: " gitpassword

docker build --build-arg gitpassword  --build-arg gitusername -f Dockerfile -t dqa-miracum .

docker-compose up -d
