# == Class: clustershell::params
#
# Handles OS-specific configuration of the clustershell module.
#
# === Authors:
#
# Geoff Johnson <geoff.jay@gmail.com>
#
# === Copyright:
#
# Copyright (C) 2014 Geoff Johnson, unless otherwise noted.
#

class clustershell::params {

  # If there is a top scope variable defined use it, otherwise use a
  # hard-code value.
  $groups = $::clustershell_groups ? {
    undef   => [
      'adm: example0',
      'oss: example4 example5',
      'mds: example6',
      'io: example[4-6]',
      'compute: example[32-159]',
      'gpu: example[156-159]',
      'all: example[4-6,32-159]',
    ],
    default => $::clustershell_groups,
  }

  $fanout = $::clustershell_fanout ? {
    undef   => 64,
    default => $clustershell_fanout,
  }

  $connect_timeout = $::clustershell_connect_timeout ? {
    undef   => 15,
    default => $clustershell_connect_timout,
  }

  $command_timeout = $::clustershell_command_timeout ? {
    undef   => 0,
    default => $clustershell_command_timeout,
  }

  $color = $::clustershell_color ? {
    undef   => 'auto',
    default => $clustershell_color,
  }

  $fd_max = $::clustershell_fd_max ? {
    undef   => 16384,
    default => $clustershell_fd_max,
  }

  $history_size = $::clustershell_history_size ? {
    undef   => 100,
    default => $clustershell_history_size,
  }

  $node_count = $::clustershell_node_count ? {
    undef   => 'yes',
    default => $clustershell_node_count,
  }

  $verbosity = $::clustershell_verbosity ? {
    undef   => '1',
    default => $clustershell_verbosity,
  }

  # if top scope variable is a string, might need to convert to boolean
  $ssh_enable = $::clustershell_ssh_enable ? {
    undef   => false,
    default => $::clustershell_ssh_enable,
  }
  if is_string($ssh_enable) {
    $safe_ssh_enable = str2bool($ssh_enable)
  } else {
    $safe_ssh_enable = $ssh_enable
  }

  $ssh_user = $::clustershell_ssh_user ? {
    undef   => 'root',
    default => $clustershell_ssh_user,
  }

  $ssh_path = $::clustershell_ssh_path ? {
    undef   => '/usr/bin/ssh',
    default => $clustershell_ssh_path,
  }

  $ssh_options = $::clustershell_ssh_options ? {
    undef   => '-oStrictHostKeyChecking=no',
    default => $clustershell_ssh_options,
  }

  # Following parameters should not be changed.
  $ensure = $::clustershell_ensure ? {
    undef   => 'present',
    default => $::clustershell_ensure,
  }

  # if top scope variable is a string, might need to convert to boolean
  $install_vim_syntax = $::clustershell_install_vim_syntax ? {
    undef   => false,
    default => $::clustershell_install_vim_syntax,
  }
  if is_string($install_vim_syntax) {
    $safe_install_vim_syntax = str2bool($install_vim_syntax)
  } else {
    $safe_install_vim_syntax = $install_vim_syntax
  }

  case $::osfamily {
    redhat: {
      $package_name         = 'clustershell'
      $vim_package_name     = 'vim-clustershell'

      $clush_conf           = '/etc/clustershell/clush.conf'
      $clush_conf_template  = 'clustershell/clush.conf.erb'

      $groups_config        = '/etc/clustershell/groups'
      $groups_template      = 'clustershell/groups.erb'

      $groups_conf          = '/etc/clustershell/groups.conf'
      $groups_conf_template = 'clustershell/groups.conf.erb'
    }
    default: {
      fail("Module ${module} is not support on ${::osfamily}")
    }
  }
}
