define appdynamics::ma_nginxmodule (
					$basedir='/opt/appdynamics',
					$machineagentname,
					$nginxmodulefile,
					$nodename,
				){

	exec { "$basedir/$machineagentname/monitors/NGinXMonitor":
		command => "mkdir -p $basedir/$machineagentname/monitors/NGinXMonitor",
		path => '/sbin:/bin:/usr/sbin:/usr/bin',
		creates => "$basedir/$machineagentname/monitors/NGinXMonitor",
	}

	file { "$basedir/$machineagentname/monitors/NGinXMonitor/nginx-monitoring-extension.jar":
		ensure => present,
		owner => 'root',
		group => 'root',
		mode => '0444',
		require => Exec["$basedir/$machineagentname/monitors/NGinXMonitor"],
		source => $nginxmodulefile,
	}

	file { "$basedir/$machineagentname/monitors/NGinXMonitor/monitor.xml":
		ensure => present,
		owner => 'root',
		group => 'root',
		mode => '0644',
		require => File["$basedir/$machineagentname/monitors/NGinXMonitor/nginx-monitoring-extension.jar"],
		content => template("appdynamics/machineagent-nginxmodule.erb"),
		notify => Service["$machineagentname"],
	}

}
