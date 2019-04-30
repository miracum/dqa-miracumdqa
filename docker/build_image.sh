#!/bin/bash

mkdir -p addfolder/
cp -R ../shiny_app/* addfolder/

docker build -f Dockerfile -t dqa-shiny-web-app .

rm -rf addfolder/
