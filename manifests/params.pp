# Class: ssh::params
#
# Sets varables for the SSH class
#
class ssh::params {
  $hasrestart        = true
  $server_package    = undef
  $ssh_dir           = '/etc/ssh'
  $sshd_config       = "${ssh_dir}/sshd_config"
  $ssh_config        = "${ssh_dir}/ssh_config"
  $ssh_config_req    = Package[$client_package]
  $known_hosts       = "${ssh_dir}/ssh_known_hosts"

  case $::operatingsystem {
# If we ever need to add an OpenBSD box, please set $ssh_config_req  = undef
    'CentOS', 'RedHat', 'Fedora': {
      $client_package  = 'openssh-clients'
      $server_package  = 'openssh-server'
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'SLES': {
      $client_package  = 'openssh'
      $server_package  = 'openssh'
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'CumulusLinux', 'Debian', 'Ubuntu': {
      $client_package  = 'openssh-client'
      $server_package  = 'openssh-server'
      $ssh_service     = 'ssh'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = false
    }
    'Darwin': {
      $hasrestart      = false
      $ssh_config_req  = undef
      $ssh_service     = 'com.openssh.sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'FreeBSD': {
      $ssh_config_req  = undef
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'Solaris','SunOS': {
      case $::kernelrelease {
        '5.10': {
          $client_package  = 'openssh'
          $server_package  = 'openssh'
          $ssh_service     = 'svc:/network/cswopenssh:default'
          $syslog_facility = 'AUTH'
        }
        '5.11': {
          $client_package  = 'service/network/ssh'
          $server_package  = 'service/network/ssh'
          $ssh_service     = 'network/ssh'
          $syslog_facility = 'AUTH'
        }
        default: {
          $client_package  = 'service/network/ssh'
          $server_package  = 'service/network/ssh'
          $ssh_config_req  = undef
          $ssh_service     = 'network/ssh'
          $syslog_facility = 'AUTH'
        }
      }

      $print_motd = false
    }
    default: {
      fail("module ssh does not support operatingsystem ${::operatingsystem}")
    }
  }
}
