#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f yaml/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml -n readme
kubectl apply -f yaml/task_readme.yaml -n readme
kubectl apply -f yaml/secret_github.yaml -n readme
kubectl apply -f yaml/pipeline.yaml -n readme
kubectl create -f yaml/pipeline_run.yaml -n readme