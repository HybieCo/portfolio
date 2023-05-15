#!/usr/bin/env bash
set -euo pipefail

# Setup variables
# input_dir="/path/to/input"
# output_dir="/path/to/output"
# file_extension=".txt"
export LOCALSTACK_API_KEY="${LOCALSTACK_API_KEY}"

# Function to check if Docker is running
check_docker() {
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon is running."
    else
        echo "Docker daemon is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if AWS CLI is installed and install if necessary
check_aws_cli() {
    if ! command -v aws >/dev/null 2>&1; then
        echo "AWS CLI not found. Installing..."
        
        # Install AWS CLI based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install awscli
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"
            msiexec /i AWSCLIV2.msi
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi
        
        echo "AWS CLI installed successfully."
    fi
}

# Function to check if Terraform is installed and install if necessary
check_terraform() {
    if ! command -v terraform >/dev/null 2>&1; then
        echo "Terraform not found. Installing..."
        
        # Install Terraform based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            curl "https://releases.hashicorp.com/terraform/1.0.4/terraform_1.0.4_linux_amd64.zip" -o "terraform.zip"
            unzip terraform.zip
            sudo mv terraform /usr/local/bin/
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install terraform
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            curl -LO "https://releases.hashicorp.com/terraform/1.0.4/terraform_1.0.4_windows_amd64.zip"
            unzip terraform_1.0.4_windows_amd64.zip
            mv terraform.exe /usr/local/bin/
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi

        echo "Terraform installed successfully."
    fi
}

# Function to check if localstack CLI is installed and install if necessary
check_localstack_cli() {
    if ! command -v localstack >/dev/null 2>&1; then
        echo "localstack CLI not found. Installing..."
        
        # Install localstack CLI based on the current operating system
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            pip install localstack
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            brew install localstack
        elif [[ "$OSTYPE" == "msys"* ]]; then
            # Windows installation (assuming using Git Bash or similar)
            pip install localstack
        else
            echo "Unsupported operating system: $OSTYPE"
            exit 1
        fi
        
        echo "localstack CLI installed successfully."
    fi
}

# Function to process files
process_files() {
    local input_dir="$1"
    local output_dir="$2"
    local file_extension="$3"
    
    for file in "$input_dir"/*"$file_extension"; do
        if [ -f "$file" ]; then
            echo "Processing file: $file"

            # Perform some operations on the file
            # ...

            # Move the processed file to the output directory
            mv "$file" "$output_dir"

            echo "File processed and moved to: $output_dir"
        fi
    done
}

# Function to launch localstack
launch_localstack() {
    # echo "Logging in to localstack"
    # localstack login -u patrickbfogarty@gmail.com
    localstack update all
    localstack start -d
    localstack wait -t 3600
    localstack status services
}

# Main function
main() {
    # Check if Docker is running
    check_docker
    
    # Check if localstack CLI is installed
    check_localstack_cli

    # Launch localstack
    launch_localstack
    
    # Process files in the input directory
    # process_files "$input_dir" "$output_dir" "$file_extension"
}

# Call the main function
main
