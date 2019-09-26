#!/bin/bash

# create folder to add to Dockerfile
mkdir addfolder
cd addfolder

# clone repositories
git clone -b v0.0.2 https://gitlab.miracum.org/miracum-dqa/dqastats.git
git clone -b v0.0.2 https://gitlab.miracum.org/miracum-dqa/dqagui.git
git clone -b v2.0.0 https://gitlab.miracum.org/miracum-dqa/miracumdqa.git
cd ..

docker build -f Dockerfile -t dqa-miracum .

# remove addfolder
rm -rf ./addfolder

docker-compose -f docker-compose.dqatool.yml up -d
