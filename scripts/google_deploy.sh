#!/usr/bin/env bash
cd ..

rm -rf ./google_deploy && mkdir ./google_deploy && mkdir ./google_deploy/dags #&& mkdir ./google_deploy/plugins
cp -R ./airflow/dags/ ./google_deploy/ #&& cp -R ./plugins/ ./google_deploy/
find ./google_deploy | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
