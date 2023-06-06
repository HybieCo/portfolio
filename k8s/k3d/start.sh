#!/usr/bin/env bash
set -euo pipefail

# Setup variables
# input_dir="/path/to/input"
# output_dir="/path/to/output"
# file_extension=".txt"
cluster_name="mycluster"

# Function to check if Docker is running
check_docker() {
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon is running."
    else
        echo "Docker daemon is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if kubectl is installed and install if necessary
check_kubectl() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not found. Installing..."

        # Install kubectl based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install kubectl
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/amd64/kubectl.exe"
            mv kubectl.exe /usr/local/bin/kubectl
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi

        echo "kubectl installed successfully."
    fi
}

# Function to check if k3d is installed and install if necessary
check_k3d() {
    if ! command -v k3d >/dev/null 2>&1; then
        echo "k3d not found. Installing..."

        # Install k3d based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install k3d
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            choco install k3d
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi

        echo "k3d installed successfully."
    fi
}

# Function to check if tekton CLI is installed and install if necessary
check_tekton_cli() {
    if ! command -v tkn >/dev/null 2>&1; then
        echo "Tekton CLI (tkn) not found. Installing..."

        # Install tekton CLI based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            curl -LO "https://github.com/tektoncd/cli/releases/latest/download/tkn-linux-amd64"
            sudo install -o root -g root -m 0755 tkn-linux-amd64 /usr/local/bin/tkn
            rm tkn-linux-amd64
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install tektoncd-cli
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            curl -LO "https://github.com/tektoncd/cli/releases/latest/download/tkn-windows-amd64.exe"
            mv tkn-windows-amd64.exe /usr/local/bin/tkn.exe
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi

        echo "Tekton CLI (tkn) installed successfully."
    fi
}


# Function to create a k3d cluster and wait for it to be ready
create_k3d_cluster() {
    local cluster_name=$cluster_name

    # Check if cluster already exists
    if k3d cluster list | grep -q "$cluster_name"; then
        echo "k3d cluster '$cluster_name' already exists."
    else
        echo "Creating k3d cluster '$cluster_name'..."

        # Create k3d cluster
        k3d cluster create $cluster_name # --registry-create $cluster_name-registry:5001

        # Wait for the cluster to be ready
        echo "Waiting for cluster '$cluster_name' to be ready..."
        while true; do
            cluster_status=$(k3d cluster list | grep "$cluster_name" | awk '{print $2}')
            if [[ $cluster_status ]]; then
                break
            fi
            sleep 5
        done

        echo "k3d cluster '$cluster_name' is ready."
    fi
}

# Start the cluster if it's not running
start_cluster(){
    cluster_status=$(k3d node list | grep -i "k3d-$cluster_name-server-0" | awk '{print $4}')
    if [[ "$cluster_status" != "running" ]]; then
        echo "Starting k3d cluster '$cluster_name'..."
        k3d cluster start "$cluster_name"

        # Wait for the cluster to be in a ready state
        echo "Waiting for cluster '$cluster_name' to be ready..."
        while true; do
            cluster_status=$(k3d node list | grep -i "k3d-$cluster_name-server-0" | awk '{print $4}')
            if [[ "$cluster_status" == "running" ]]; then
                break
            fi
            sleep 5
        done

        echo "k3d cluster '$cluster_name' is ready."
    else
        echo "k3d cluster '$cluster_name' is already running."
    fi
}


# Main function
main() {
    # Check if Docker is running
    check_docker

    # Check if kubectl is installed
    check_kubectl

    # Check if K3D is installed
    check_k3d

    # Check if tkn is installed
    check_tekton_cli

    # Check if K3D cluster is Created
    create_k3d_cluster

    # Start Cluster if it is not Running
    start_cluster

}

# Call the main function
main
