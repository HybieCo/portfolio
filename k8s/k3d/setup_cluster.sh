#!/usr/bin/env bash
set -euo pipefail

cluster_name="mycluster"

# Set kubeconfig
set_kubeconfig(){
    local cluster_name=$cluster_name

    cluster_status=$(k3d node list | grep -i "k3d-$cluster_name-server-0" | awk '{print $4}')
    kubeconfig_status=$(k3d kubeconfig get $cluster_name | grep -i "cluster: k3d-$cluster_name" | awk '{print $2}')
    if [[ "$cluster_status" != "running" ]]; then
        echo "Please run start.sh to start cluster"
    # elif [[ "$kubeconfig_status" == "k3d-$cluster_name" ]]; then
    #     echo "Current cluster is $cluster_name"
    else
        echo "Setting kubeconfig to use cluster named $cluster_name"
        export KUBECONFIG=$(k3d kubeconfig merge $cluster_name --kubeconfig-switch-context --overwrite)
    fi
}

# Install Tekton
check_tekton_pipelines(){
    tekton_status=$(kubectl get pods -n tekton-pipelines) # > /dev/null 2>&1 | grep -i tekton-pipelines-controller | awk '{print $3}')
    if [[ "$tekton_status" != "Running" ]]; then
        kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

        # Wait for the Tekton to be in a ready state
        echo "Waiting for Tekton to be ready..."
        while true; do
            tekton_status=$(kubectl get pods -n tekton-pipelines | grep -i tekton-pipelines-controller | awk '{print $3}')
            if [[ "$tekton_status" == "Running" ]]; then
                break
            fi
            sleep 5
        done

        echo "Tekton is installed and ready."
    else
        echo "Tekton is already installed and ready."
    fi
}

# Install Tekton
check_tekton_dashboard(){
    tekton_dashboard_status=$(kubectl get pods -n tekton-pipelines) # | grep -i tekton-dashboard | awk '{print $3}')
    if [[ "$tekton_dashboard_status" != "Running" ]]; then
        kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml

        # Wait for the Tekton Dashboard to be in a ready state
        echo "Waiting for Tekton Dashboard to be ready..."
        while true; do
            tekton_dashboard_status=$(kubectl get pods -n tekton-pipelines | grep -i tekton-dashboard | awk '{print $3}')
            if [[ "$tekton_dashboard_status" == "Running" ]]; then
                break
            fi
            sleep 5
        done

        echo "Tekton Dashboard is installed and ready."
        echo "Run command is separate terminal to expose Tekton Dashboard on localhost
        kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097& "
    else
        echo "Tekton Dashboard is already installed and ready."
        echo "Run command is separate terminal to expose Tekton Dashboard on localhost
        kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097& "
    fi
}

# Main function
main() {
    # Check if cluster is running and set kubconfig
    set_kubeconfig

    # Check for Tekton and install
    check_tekton_pipelines

    # Check Tekton dashboard and install
    check_tekton_dashboard
}

# Call the main function
main