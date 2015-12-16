define appdynamics::dbagent(
                              $basedir='/opt/appdynamics',
                              $dbagentname=$name,
                              $controllerpath='/opt/appdynamics/controller',
                              $dbagent_file,
                              $controllerhost,
                              $controllerport=80,
                              $enablessl=false,
                              $accountname='customer1',
                              $accountkey='SJ5b2m7d1$354',
                              ) {

  validate_absolute_path($basedir)
  validate_absolute_path($controllerpath)

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { "check java $dbagentname":
		command => "update-alternatives --display java",
	}

  if ! defined(File["$basedir"])
  {
    file { "$basedir":
      ensure => directory,
      owner => "root",
      group => "root",
      mode => 0755,
      require => Exec["check java $dbagentname"],
    }
  }

  if ! defined(Package['unzip'])
  {
    package { 'unzip':
      ensure => 'installed',
    }
  }

  file { "$basedir/$dbagentname":
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 0755,
    require => File["$basedir"],
  }

  file { "$basedir/.$dbagentname.tgz":
    ensure => present,
    owner => "root",
    group => "root",
    mode => 0444,
    require => File["$basedir/$dbagentname"],
    source => $dbagent_file,
  }

  exec { "unzip $dbagentname":
    command => "unzip $basedir/.$dbagentname.tgz -d $basedir/$dbagentname",
    creates => "$basedir/$dbagentname/db-agent.jar",
    require => [ File["$basedir/.$dbagentname.tgz"], Package['unzip'] ],
  }

  file { "$basedir/$dbagentname/conf/controller-info.xml":
    ensure => present,
    owner => "root",
    group => "root",
    mode => 0644,
    require => Exec["unzip $dbagentname"],
    content => template("appdynamics/machineagent-controllerinfo.erb"),
    notify => Service["$dbagentname"],
  }

  file { "/etc/init.d/$dbagentname":
    ensure => present,
    owner => "root",
    group => "root",
    mode => 0755,
    require => File["$basedir/$dbagentname/conf/controller-info.xml"],
    content => template("appdynamics/dbagent-init.erb"),
    notify => Service["$dbagentname"],
  }

  service { "$dbagentname":
    enable => true,
    ensure => "running",
    require => File["/etc/init.d/$dbagentname"],
  }

}
