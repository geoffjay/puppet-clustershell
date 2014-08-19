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

  # Following parameters should not be changed.
  $ensure = $::clustershell_ensure ? {
    undef   => 'present',
    default => $::clustershell_ensure,
  }

  # The top scope variable could be a string, might need to convert to boolean.
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
      $package_name     = 'clustershell'
      $vim_package_name = 'vim-clustershell'

      $clush_config     = '/etc/clustershell/clush.conf'
      $clush_template   = 'clustershell/clush.conf.erb'

      $groups_config    = '/etc/clustershell/groups.conf'
      $groups_template  = 'clustershell/groups.conf.erb'
    }
    default: {
      fail("Module ${module} is not support on ${::osfamily}")
    }
  }
}
