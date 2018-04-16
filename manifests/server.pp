# This class installs and manages an SSH server
class ssh::server (
  Variant[Boolean, Enum['without-password', 'forced-commands-only']] $permit_root_login = false,
  Boolean $permit_x11_forwarding = false,
  Boolean $print_motd = $::ssh::params::print_motd,
  Optional[Array[String[1], 1]] $accept_env = undef,
  Optional[String[1]] $kex_algorithm = undef,
) inherits ::ssh::params {
  include ::ssh

  if $::kernel == 'Linux' and ! defined(Package[$server_package]) {
    package { $server_package:
      ensure => latest,
      notify => Service['sshd'],
    }
  }

  $permit_root_login_string = $permit_root_login ? {
    String[1] => $permit_root_login,
    true      => 'yes',
    false     => 'no',
  }

  concat { $sshd_config:
    mode    => '0640',
    require => $::kernel ? {
      'Linux'   => Package[$server_package],
      default   => undef,
    },
    notify  => Service['sshd'],
  }
  concat::fragment { 'sshd_config-header':
    order   => '00',
    target  => $sshd_config,
    content => template('ssh/sshd_config.erb'),
  }

  service { 'sshd':
    ensure     => running,
    name       => $ssh_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => $::kernel ? {
      'Darwin' => false,
      default  => true,
    },
  }

  file { $ssh_dir:
    ensure => directory,
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  file { $known_hosts:
    ensure => file,
    owner  => 'root',
    group  => '0',
    mode   => '0644',
  }
}
