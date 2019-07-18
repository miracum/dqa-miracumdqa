#!/bin/bash

docker build -f Dockerfile -t dqa-miracum .

docker-compose up -d
