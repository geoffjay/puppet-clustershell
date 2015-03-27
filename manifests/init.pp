# == Class: clustershell
#
# Handles installing the clustershell packages.
#
# ==== Parameters:
#
# [*fanout*]
#   ...
#   Default: 64
#
# [*connect_timeout*]
#   ...
#   Default: 15
#
# [*command_timeout*]
#   ...
#   Default: 0
#
# [*color*]
#   ...
#   Default: auto
#
# [*fd_max*]
#   ...
#   Default: 16384
#
# [*history_size*]
#   ...
#   Default: 100
#
# [*node_count*]
#   ...
#   Default: yes
#
# [*verbosity*]
#   ...
#   Default: 1
#
# [*ssh_enable*]
#   Controls whether or not clush uses SSH settings from the config.
#   Default: false
#
# [*ssh_user*]
#   The user to use with SSH.
#   Default: root
#
# [*ssh_path*]
#   The path to the SSH client.
#   Default: /usr/bin/ssh
#
# [*ssh_options*]
#   Command line options to pass to the SSH client.
#   Default: -oStrictHostKeyChecking=no
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*package_name*]
#   Name of the package.
#   Default: clustershell
#
# [*install_vim_syntax*]
#   Whether or not to install the VIM package for syntax highlighting.
#   Default: false
#
# [*vim_package_name*]
#   Name of the package for VIM syntax highlighting.
#   Default: vim-clustershell
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
  $fanout               = $clustershell::params::fanout,
  $connect_timeout      = $clustershell::params::connect_timeout,
  $command_timeout      = $clustershell::params::command_timeout,
  $color                = $clustershell::params::color,
  $fd_max               = $clustershell::params::fd_max,
  $history_size         = $clustershell::params::history_size,
  $node_count           = $clustershell::params::node_count,
  $verbosity            = $clustershell::params::verbosity,
  $ssh_enable           = $clustershell::params::ssh_enable,
  $ssh_user             = $clustershell::params::ssh_user,
  $ssh_path             = $clustershell::params::ssh_path,
  $ssh_options          = $clustershell::params::ssh_options,
  $ensure               = $clustershell::params::ensure,
  $package_name         = $clustershell::params::package_name,
  $install_vim_syntax   = $clustershell::params::install_vim_syntax,
  $vim_package_name     = $clustershell::params::vim_package_name,
  $clush_conf           = $clustershell::params::clush_conf,
  $clush_conf_template  = $clustershell::params::clush_conf_template,
  $groups_config        = $clustershell::params::groups_config,
  $groups_concat_dir    = $clustershell::params::groups_concat_dir,
  $groups_conf          = $clustershell::params::groups_conf,
  $groups_conf_template = $clustershell::params::groups_conf_template,
) inherits clustershell::params {

  # Validate booleans
  validate_bool($ssh_enable)
  validate_bool($install_vim_syntax)

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

  file { $clush_conf:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['clustershell'],
    content => $inline_template ? {
      undef   => template($clush_conf_template),
      ''      => template($clush_conf_template),
      default => inline_template("${inline_template}\n"),
    }
  }

  file { $groups_conf:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['clustershell'],
    content => $inline_template ? {
      undef   => template($groups_conf_template),
      ''      => template($groups_conf_template),
      default => inline_template("${inline_template}\n"),
    }
  }

  file { $groups_concat_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Package['clustershell'],
  }

  # Declare concat
  concat { $groups_config:
    ensure         => present,
    require        => File[$groups_concat_dir],
    ensure_newline => true,
  }
}
