#!/bin/bash


# Update the package list and install necessary tools
sudo apt-get update -y
sudo apt-get install -y git curl

# Clone the repository and change to the React directory
git clone https://github.com/helly2910/React.git
cd React

# Print the current working directory
pwd

# Install Node.js using NodeSource LTS setup script
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install project dependencies and start the application
npm install
npm run start

