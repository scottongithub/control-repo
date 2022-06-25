

# Overview
A control repository based on Puppetlabs control-repo template. It sets up a basic web-app per the diagram below. The git branches will translate into environments as /etc/puppetlabs/code/environments/$gitbranch for each branch
# Features
- Can use github as an ssh keyserver for local admin accounts. Configurable as github_username in $environment/data/common.yaml

# Notes
Logic and data are separated as much as practical, with data being stored in $environment/data/common.yaml and logic at $environment/manifests/site.pp





<img src="https://user-images.githubusercontent.com/21364725/175784240-5d9af1b3-7c00-479a-848e-3801eac4c668.png" width="500" />
