#!/usr/bin/python3

import syslog, yaml, requests

def get_ssh_keys( _github_username ):
    res = requests.get('https://github.com/' + _github_username + '.keys')
    res_text = res.text
    _ssh_algorithm = res_text.split(" ")[0]
    _ssh_key = res_text.split(" ")[1]
    return _ssh_algorithm.rstrip(), _ssh_key.rstrip()

with open("/etc/puppetlabs/code/environments/production/data/common.yaml") as f:
    y = yaml.safe_load(f)

    # Web server admins
    records = y['default_settings::web_server_admins']
    for record in records:
        admin = records[record]
        github_username = admin['github_username']
        if github_username != None:
            ssh_algorithm, ssh_key = get_ssh_keys(github_username)
            y['default_settings::web_server_admins'][record]['ssh_algorithm'] = ssh_algorithm
            y['default_settings::web_server_admins'][record]['ssh_key'] = ssh_key

    #App server admins
    records = y['default_settings::app_server_admins']
    for record in records:
        admin = records[record]
        github_username = admin['github_username']
        if github_username != None:
            ssh_algorithm, ssh_key = get_ssh_keys(github_username)
            y['default_settings::app_server_admins'][record]['ssh_algorithm'] = ssh_algorithm
            y['default_settings::app_server_admins'][record]['ssh_key'] = ssh_key

    with open("/etc/puppetlabs/code/environments/production/data/common.yaml", "w") as file1:
        file1.write(yaml.dump(y, default_flow_style=False, sort_keys=False))
