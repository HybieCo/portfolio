#!/usr/bin/env bash
set -euo pipefail

cluster_name="mycluster"

k3d cluster stop $cluster_name
k3d cluster delete $cluster_name