

# Overview
A control repository based on Puppetlabs control-repo template. It sets up a basic web-app per the diagram below. The git branches will translate into environments as /etc/puppetlabs/code/environments/$gitbranch for each branch
# Features
- Can use github as an ssh keyserver for local admin accounts. Configurable as github_username in $environment/data/common.yaml

# Notes
Logic and data are separated as much as possible, with data being stored in $environment/data/common.yaml and logic at $environment/manifests/site.pp


![control_repo](https://user-images.githubusercontent.com/21364725/175783269-c7800a32-bf00-4c01-9d72-4b883ba452c9.png)
