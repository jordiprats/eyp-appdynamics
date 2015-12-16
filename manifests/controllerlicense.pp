define appdynamics::controllerlicense	(
						$basedir		= '/opt/appdynamics',
						$installdir		= 'controller',
						$licensefile		= "puppet:///appdynamics/${::macaddress}.lic",
					) {


	validate_absolute_path($basedir)
	validate_absolute_path("$basedir/$installdir")

	validate_string($licensefile)

	file { "$basedir/$installdir/license.lic":
		ensure 	=> present,
		owner 	=> "root",
		group 	=> "root",
		mode 	=> 0644,
		source => $licensefile
	}

}
