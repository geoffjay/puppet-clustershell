# == Class: clustershell
#
# Handles installing the clustershell packages.
#
# ==== Parameters:
#
# TODO
#
# === Actions:
#
# Installs the clustershell package and configuration.
# Installs the vim-clustershell package.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#  # Install the vim syntax package and configure groups:
#  class { 'clustershell':
#    install_vim_syntax => true,
#    groups             => [
#      'hpc: node[00-99]',
#      'nfs: nfs1 nfs2 nfs3',
#    ],
#  }
#
# === Authors:
#
# Geoff Johnson <geoff.jay@gmail.com>
#
# === Copyright:
#
# Copyright (C) 2014 Geoff Johnson, unless otherwise noted.
#

class clustershell (
  $ensure             = $clustershell::params::ensure,
  $package_name       = $clustershell::params::package_name,
  $install_vim_syntax = $clustershell::params::install_vim_syntax,
  $vim_package_name   = $clustershell::params::vim_package_name,
  $clush_config       = $clustershell::params::clush_config,
  $clush_template     = $clustershell::params::clush_template,
  $groups             = $clustershell::params::groups,
  $groups_config      = $clustershell::params::groups_config,
  $groups_template    = $clustershell::params::groups_template,
) inherits clustershell::params {

  # Validate booleans
  validate_bool($install_vim_syntax)

  # Validate arrays
  validate_array($groups)

  case $ensure {
    /(present)/: {
      $package_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { 'clustershell':
    ensure => $package_ensure,
    name   => $package_name,
  }

  # Might need to convert to class
  if $install_vim_syntax {
    package { 'vim-clustershell':
      name => $vim_package_name,
    }
  }

  file { $clush_config:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['clustershell'],
    content => $inline_template ? {
      '' => template($clush_template),
      default => inline_template("${inline_template}\n"),
    }
  }

  file { $groups_config:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['clustershell'],
    content => $inline_template ? {
      '' => template($groups_template),
      default => inline_template("${inline_template}\n"),
    }
  }
}
