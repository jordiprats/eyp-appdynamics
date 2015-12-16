define appdynamics::ma_urlmonitor (
                                    $basedir='/opt/appdynamics',
                                    $srcdir='/usr/local/src',
                                    $machineagentname,
                                  ){
  #
  file { "${srcdir}/urlmonitor.${machineagentname}.zip":
    ensure   => 'present',
    owner    => 'root',
    group    => 'root',
    mode     => '0600',
    source 	 => "puppet:///modules/${module_name}/UrlMonitor.zip",
  }

  exec { "unzip ${srcdir}/urlmonitor.${machineagentname}.zip":
    command => "unzip ${srcdir}/urlmonitor.${machineagentname}.zip -d ${basedir}/${machineagentname}/monitors",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    creates => "${basedir}/${machineagentname}/monitors/UrlMonitor",
    require => File["${srcdir}/urlmonitor.${machineagentname}.zip"],
  }

  file { "${basedir}/${machineagentname}/monitors/UrlMonitor/config.yml":
    owner   => 'root',
    group   => 'nttdata',
    mode    => '0664',
    require => Exec["unzip ${srcdir}/urlmonitor.${machineagentname}.zip"],
  }
}
