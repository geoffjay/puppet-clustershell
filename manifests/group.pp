# Juste a simple concat files to manage groups
define clustershell::group (
  $group = $title,
) {

  $group_concat_file = "${clustershell::groups_concat_dir}/${group}"

  # Declare own concat params
  concat { $group_concat_file:
    ensure         => present,
    ensure_newline => false,
  }

  # The init
  concat::fragment { "group-{$group}-init":
    ensure  => present,
    order   => 01,
    target  => $group_concat_file,
    content => "${group}: ",
  }

  
  concat::fragment{ "group-${group}":
    ensure  => present,
    target  => $clustershell::groups_config,
    source  => $group_concat_file,
    require => File[$group_concat_file],
  }
}
