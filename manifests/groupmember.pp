# Juste a simple concat files to manage groups
define clustershell::groupmember (
  $member = $title,
  $group,
) {
  $group_concat_file = "${clustershell::groups_concat_dir}/${group}"

  concat::fragment { "groupmember-${member}":
    ensure  => present,
    order   => 02,
    target  => $group_concat_file,
    content => "${member} ",
  }
}
