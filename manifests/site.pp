include ntp
include sudo
package { lookup("default_settings::packages"):
    ensure => installed,
}

node puppet-server {
  # Gets ssh keys from GitHub and inserts them into data/common.yaml
  exec { "python3 /etc/puppetlabs/code/environments/${environment}/scripts/get_ssh_keys_from_github.py":
     cwd     => "/etc/puppetlabs/code/environments/${environment}/",
     path    => ['/usr/bin', '/usr/sbin',],
  }
}


node web-server-01 {
  $server_admins = lookup("default_settings::web_server_admins")
  $server_admins.each |$record| {
    $server_admin = $record[1]
    $admin_name = $server_admin[name]
    user { $admin_name:
      name => $admin_name,
      ensure => present,
      managehome => true,
      home => "/home/$admin_name",
      purge_ssh_keys => true,
      shell => '/bin/bash'
    }
    sudo::conf { $admin_name:
      content  => "$admin_name ALL=(ALL) NOPASSWD: ALL",
    }
    ssh_authorized_key { $admin_name:
      name     => $server_admin[name],
      ensure   => present,
      key      => $server_admin[ssh_key],
      type     => $server_admin[ssh_algorithm],
      user     => $server_admin[name],
    }
    if $server_admin[github_username] != undef {
      $github_username = $server_admin[github_username]
      $ssh_key = $server_admin[ssh_key]
      notify {"$admin_name has $github_username for github username and key is $ssh_key":}
    }
  }

  Firewall {
  before  => Class['default_firewall::post'],
  require => Class['default_firewall::pre'],
  }
  class { ['default_firewall::pre', 'default_firewall::post']: }
  firewallchain { 'INPUT:filter:IPv4':
    purge => true,
    ignore => [
      '-j fail2ban-ssh', # ignore the fail2ban jump rule
      '--comment "[^"]*(?i:ignore)[^"]*"', # ignore any rules with "ignore" (case insensitive) in the comment in the rule
    ],
  }
  $firewall_rules = lookup("default_settings::web_server_firewall")
  $firewall_rules.each |$record|{
    $firewall_rule = $record[1]
    firewall { $firewall_rule[comment]:
      proto => $firewall_rule[proto],
      dport => $firewall_rule[dport],
      source => $firewall_rule[source],
      action => $firewall_rule[action],
    }
  }
  host { 'app-server-01':
    name => 'app-server-01',
    ip => lookup("default_settings::app_server_address"),
  }

  include nginx
  nginx::resource::server { lookup("default_settings::web_server_address"):
    listen_port => 80,
    proxy      => 'http://app-server-01:8000',
    proxy_cache => 'STATIC',
  }

}

node app-server-01 {
  $server_admins = lookup(default_settings::app_server_admins)
  $server_admins.each |$record| {
    $server_admin = $record[1]
    $admin_name = $server_admin[name]
    user { $admin_name:
      name => $admin_name,
      ensure => present,
      managehome => true,
      home => "/home/$admin_name",
      purge_ssh_keys => true,
      shell => '/bin/bash'
    }
    sudo::conf { $admin_name:
      content  => "$admin_name ALL=(ALL) NOPASSWD: ALL",
    }
    ssh_authorized_key { $admin_name:
      name     => $server_admin[name],
      ensure   => present,
      key      => $server_admin[ssh_key],
      type     => $server_admin[ssh_algorithm],
      user     => $server_admin[name],
    }
    if $server_admin[github_username] != undef {
      $github_username = $server_admin[github_username]
      $ssh_key = $server_admin[ssh_key]
      notify {"$admin_name has $github_username for github username and key is $ssh_key":}
    }
  }

  Firewall {
    before  => Class['default_firewall::post'],
    require => Class['default_firewall::pre'],
  }
  class { ['default_firewall::pre', 'default_firewall::post']: }
  firewallchain { 'INPUT:filter:IPv4':
    purge => true,
    ignore => [
      '-j fail2ban-ssh', # ignore the fail2ban jump rule
      '--comment "[^"]*(?i:ignore)[^"]*"', # ignore any rules with "ignore" (case insensitive) in the comment in the rule
    ],
  }
  $firewall_rules = lookup(default_settings::app_server_firewall)
  $firewall_rules.each |$record|{
    $firewall_rule = $record[1]
    firewall { $firewall_rule[comment]:
      proto => $firewall_rule[proto],
      dport => $firewall_rule[dport],
      source => $firewall_rule[source],
      action => $firewall_rule[action],
    }
  }

  host { 'web-server-01':
    name => 'web-server-01',
    ip => lookup("default_settings::web_server_address"),
  }

  file { '/var/www':
    path => '/var/www',
    ensure => 'directory',
  }

  class { 'python':
    version    => 'system',
    pip        => 'present',
    dev        => 'present',
    }
  python::pyvenv { "/var/www/app-01":
    ensure => present,
    version => 'system',
    venv_dir => '/var/www/app-01',
    owner => 'root'
  }
  python::pip { ['django' ]:
    virtualenv => '/var/www/app-01',
  }

}
