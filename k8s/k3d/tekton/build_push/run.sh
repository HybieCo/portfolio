#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f yaml/namespace.yaml
kubectl apply -f yaml/secret_registry.yaml -n build-push
kubectl apply -f yaml/pipeline.yaml -n build-push 
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml -n build-push
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml -n build-push
kubectl create -f yaml/pipeline_run.yaml -n build-push