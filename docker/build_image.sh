#!/bin/bash

mkdir -p addfolder/
cp -R ../DQA_Tool/* addfolder/

docker build -f Dockerfile -t dqa-miracum .

rm -rf addfolder/

docker-compose up -d
