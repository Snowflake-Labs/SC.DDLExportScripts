#!/bin/bash

if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script only works on Linux or macOS systems."
    exit 1
fi

echo "Checking prerequisites..."

install_package() {
    package_name=$1
    echo "Attempting to install $package_name..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y $package_name
        elif command -v yum &> /dev/null; then
            sudo yum install -y $package_name
        else
            echo "Warning: Could not determine package manager. Please install $package_name manually."
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install $package_name
        else
            echo "Warning: Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [ $? -eq 0 ]; then
                echo "Homebrew installed successfully. Installing $package_name..."
                brew install $package_name
            else
                echo "Warning: Failed to install Homebrew. Please install $package_name manually."
                return 1
            fi
        fi
    else
        return 1
    fi
    
    return 0
}

if ! command -v curl &> /dev/null; then
    echo "$package_name is not installed."
    install_package curl
    if ! command -v curl &> /dev/null; then
        echo "Error: Failed to install curl. Please install it manually and try again."
        exit 1
    fi
else
    echo "curl is already installed."
fi

if ! command -v tar &> /dev/null; then
    echo "tar is not installed."
    install_package tar
    if ! command -v tar &> /dev/null; then
        echo "Error: Failed to install tar. Please install it manually and try again."
        exit 1
    fi
else
    echo "tar is already installed."
fi

if ! command -v gzip &> /dev/null; then
    echo "gzip is not installed."
    install_package gzip
    if ! command -v gzip &> /dev/null; then
        echo "Error: Failed to install gzip. Please install it manually and try again."
        exit 1
    fi
else
    echo "gzip is already installed."
fi

echo "All prerequisites are installed or have been installed."
echo "Starting Vertica client driver installation..."

echo "Downloading Vertica client driver..."
curl https://www.vertica.com/client_drivers/9.1.x/9.1.1-0/vertica-client-9.1.1-0.x86_64.tar.gz --output vertica-client.tar.gz

echo "Extracting Vertica client driver..."
gzip -d vertica-client.tar.gz
tar -xvf vertica-client.tar

echo "Vertica client driver installation completed successfully."