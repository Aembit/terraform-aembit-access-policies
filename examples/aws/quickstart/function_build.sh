#! /bin/bash

rm -rf build
rm -rf artifacts
mkdir -p build
mkdir -p artifacts


curl -o build/rootCA.pem https://cf88d6.aembit.io/api/v1/root-ca
(cd src && zip ../artifacts/lambda.zip handler.py)
pip3 install --platform manylinux2014_x86_64 --only-binary=:all: -r src/requirements.txt -t build/python/lib/python3.9/site-packages/
(cd build && zip -r ../artifacts/requirements.zip .)

rm -rf build
