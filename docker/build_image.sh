#!/bin/bash

# create folder to add to Dockerfile
mkdir addfolder
cd addfolder

# clone repository
git clone https://gitlab.miracum.org/miracum-dqa/miRacumDQA.git
cd ..

docker build -f Dockerfile -t dqa-miracum .

# remove addfolder
rm -rf ./addfolder

docker-compose -f docker-compose.i2b2.yml up -d
