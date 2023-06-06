#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f yaml/namespace.yaml
kubectl apply -f yaml/secret-sa.yaml  -n pfdemo
kubectl apply -f yaml/role.yaml  -n pfdemo
kubectl apply -f yaml/secret_registry.yaml -n pfdemo
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.6/git-clone.yaml -n pfdemo
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildah/0.3/buildah.yaml -n pfdemo
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kubernetes-actions/0.2/kubernetes-actions.yaml -n pfdemo
kubectl apply -f yaml/pipeline.yaml -n pfdemo
kubectl create -f yaml/pipeline_run.yaml -n pfdemo

kubectl apply -f yaml/pipeline_deploy.yaml -n pfdemo
kubectl create -f yaml/pipeline_deploy_run.yaml -n pfdemo
# kubectl -n pfdemo port-forward svc/pfdemo-service 8081:8080