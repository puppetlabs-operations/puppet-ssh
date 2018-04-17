# This class installs and manages an SSH server
class ssh::server (
  Variant[Boolean, Enum['without-password', 'forced-commands-only']] $permit_root_login = false,
  Boolean $permit_x11_forwarding = false,
  Boolean $print_motd = $::ssh::params::print_motd,
  Optional[Array[String[1], 1]] $accept_env = undef,
  Optional[String[1]] $kex_algorithm = undef,
) inherits ssh::params {
  include ssh

  if $ssh::params::kernel == 'Linux' and ! defined(Package[$ssh::params::server_package]) {
    package { $ssh::params::server_package:
      ensure => latest,
      notify => Service['sshd'],
    }
  }

  $permit_root_login_string = $ssh::params::permit_root_login ? {
    String[1] => $permit_root_login,
    true      => 'yes',
    false     => 'no',
  }

  concat { $ssh::params::sshd_config:
    mode    => '0640',
    require => $ssh::params::server_package,
    notify  => Service['sshd'],
  }
  concat::fragment { 'sshd_config-header':
    order   => '00',
    target  => $ssh::params::sshd_config,
    content => template('ssh/sshd_config.erb'),
  }

  service { 'sshd':
    ensure     => running,
    name       => $ssh::params::ssh_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => $ssh::params::hasrestart,
  }

  file { $ssh::params::ssh_dir:
    ensure => directory,
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  file { $ssh::params::known_hosts:
    ensure => file,
    owner  => 'root',
    group  => '0',
    mode   => '0644',
  }
}
