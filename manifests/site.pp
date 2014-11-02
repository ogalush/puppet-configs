# group add
group { "ogalush":
gid => 1001,
ensure => present
}

group { "tendo":
gid => 1002,
ensure => present
}

# user add
user { "ogalush":
ensure => present,
home => "/home/ogalush",
managehome => true,
uid => 1001,
gid => 1001,
shell => "/bin/bash",
comment => "Takehiko Ogasawara",
password => '$6$testtest$5txpZMim8XzgmQ8V0DPQvomReE6CJRHfSQ1gSkhAlsWTqRGY.MqHAVNkW8dc6LbPAZLsiXxl4Ju59YUvCrBen1'
}

user { "tendo":
ensure => present,
home => "/home/tendo",
managehome => true,
uid => 1002,
gid => 1002,
shell => "/bin/bash",
comment => "Tadashi Endo",
password => '$6$testtest$ZhkCNjAyGvDSaqAuzScAS5EWblP.MikFo1hoGHPbRmMujFTu6o1LT3MezAnb.BP4TXl11qUaKKkYeWT671lQq0'
}

# ssh directory
file { "/home/ogalush/.ssh":
ensure => directory,
owner => "ogalush",
group => "ogalush",
mode => "0700"
}

file { "/home/tendo/.ssh":
ensure => directory,
owner => "tendo",
group => "tendo",
mode => "0700"
}

# authorized_keys
file { "/home/ogalush/.ssh/authorized_keys":
ensure => present,
source => [
    "puppet:///modules/authorized_keys/ogalush_keys"
  ],
owner => "ogalush",
group => "ogalush",
mode => "0600"
}

file { "/home/tendo/.ssh/authorized_keys":
ensure => present,
source => [
    "puppet:///modules/authorized_keys/tendo_keys"
  ],
owner => "tendo",
group => "tendo",
mode => "0600"
}

# sudo
file { "/etc/sudoers.d/ogalush":
mode => "0600",
owner => "root",
group => "root",
content => "ogalush ALL=(ALL) ALL",
}

file { "/etc/sudoers.d/tendo":
mode => "0600",
owner => "root",
group => "root",
content => "tendo ALL=(ALL) ALL",
}

# source.list
file {'/etc/apt/sources.list.d/sensu.list':
mode => "0600",
owner => "root",
group => "root",
content => "deb     http://repos.sensuapp.org/apt sensu main",
}

# sensu client
exec { 'sudo apt-get update':
path => ['/usr/bin']
}

exec { 'sudo apt-get -y install sensu --force-yes':
path => ['/usr/bin']
}

file { "/etc/sensu/conf.d/client.json":
mode => "0644",
owner => "root",
group => "root",
content => "{
  \"client\": {
    \"name\": \"$fqdn\",
    \"address\": \"sensu.localdomain\",
    \"subscriptions\": [ \"all\",\"webservers\" ]
  }
}"
}

exec { 'sudo update-rc.d sensu-client defaults && sudo /etc/init.d/sensu-client start':
path => ['/usr/bin', '/usr/sbin'],
}
