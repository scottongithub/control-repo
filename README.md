

# Overview
A control repository based on Puppetlabs' control-repo template. This project sets up a basic web-app per the diagram below. Per r10k defaults, the git branches will translate into environments as /etc/puppetlabs/code/environments/$gitbranch for each branch

# Usage
The three nodes can be bootstrapped and run using the commands listed in docs/bootstrap.txt

# Notes
- Data is stored in $environment/data/common.yaml (managed by Hiera) and logic is in $environment/manifests/site.pp

- Can use github as an ssh keyserver for local admin accounts. Configurable as github_username in $environment/data/common.yaml

- There is no automation (e.g. cron job) for r10k deploy - it is done manually (via `r10k deploy environment`) 


<p align="center">
<img src="https://user-images.githubusercontent.com/21364725/175784240-5d9af1b3-7c00-479a-848e-3801eac4c668.png" width="500" />
</p>
