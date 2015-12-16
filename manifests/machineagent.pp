define appdynamics::machineagent (
					$basedir='/opt/appdynamics',
					$machineagentname=$name,
					$controllerhost,
					$controllerport=80,
					$enablessl=false,
					$appname='',
					$tiername='',
					$nodename='',
					$accountname='customer1',
					$accountkey='SJ5b2m7d1$354',
					$uniquehostid=undef,
					$ma_file,
					$orchestration=false,
				){

	Exec {
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}

	validate_absolute_path($basedir)

	validate_string($controllerhost)

	validate_string($appname)
	validate_string($tiername)
	validate_string($nodename)

	if($uniquehostid)
	{
		validate_string($uniquehostid)
	}

	exec { "check java $machineagentname":
		command => "update-alternatives --display java",
	}

	if ! defined(File["$basedir"])
	{
		file { "$basedir":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => 0755,
			require => Exec["check java $machineagentname"],
		}
	}

	file { "$basedir/$machineagentname":
		ensure => directory,
		owner => "root",
		group => "root",
		mode => 0755,
		require => File["$basedir"],
	}

	file { "$basedir/.$machineagentname.tgz":
		ensure => present,
		owner => "root",
		group => "root",
		mode => 0444,
		require => File["$basedir/$machineagentname"],
		source => $ma_file,
	}

	exec { "untar $machineagentname":
		command => "tar --no-same-owner -xzf $basedir/.$machineagentname.tgz -C $basedir/$machineagentname",
		creates => "$basedir/$machineagentname/machineagent.jar",
		require => File["$basedir/.$machineagentname.tgz"],
	}

	file { "$basedir/$machineagentname/conf/controller-info.xml":
		ensure => present,
		owner => "root",
		group => "root",
		mode => 0644,
		require => Exec["untar $machineagentname"],
		content => template("appdynamics/machineagent-controllerinfo.erb"),
		notify => Service["$machineagentname"],
	}

	file { "/etc/init.d/$machineagentname":
		ensure => present,
		owner => "root",
		group => "root",
		mode => 0755,
		require => File["$basedir/$machineagentname/conf/controller-info.xml"],
		content => template("appdynamics/machineagent-init.erb"),
		notify => Service["$machineagentname"],
	}

	service { "$machineagentname":
		enable => true,
		ensure => "running",
		require => File["/etc/init.d/$machineagentname"],
	}

}
