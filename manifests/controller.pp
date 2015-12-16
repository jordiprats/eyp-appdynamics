define appdynamics::controller	(
					$basedir		= '/opt/appdynamics',
					$installdir		= 'controller',
					$ipaddr			= undef,
					$controllerconfig	= 'medium',
					$tenacymode		= 'single',
					$hatype			= 'notapplicable',
					$ha_mip			= undef,
					$ha_slave		= undef,
					$accountname		= undef,
					$accountkey		= undef,
					$rootpw			= undef,
					$adminuser		= 'admin',
					$adminpw		= undef,
					$mysqlrootpw		= undef,
					$enableudc		= false,
					$version		= '4.0.6.1',
					$controller_file	= undef,
				) {
	Exec {
		path => '/bin:/sbin:/usr/bin:/usr/sbin',
	}

	$current_mode = $::selinux? {
		'false' => 'disabled',
		false   => 'disabled',
		default => $::selinux_current_mode,
	}

	case $current_mode
	{
		'enforcing':
		{
			fail { "appdynamics does not work with SELinux::${current_mode}": }
		}
		'permissive':
		{
			fail { "Reboot required, appdynamics does not work with SELinux::${current_mode}": }
		}
		'disabled': {}
		default: { fail("i'm too lazy to implement this") }
	}

	#validate_re($version, [ '^4.0.6.1$', '^4.0.6.1$' ], "Not a valid version: $version")
	validate_re($controllerconfig, [ '^demo$', '^small$', '^medium$', '^large$', '^huge$' ], "Not a valid controllerconfig: $controllerconfig")
	validate_re($tenacymode, [ '^single$', '^multi$' ], "Not a valid tenacymode: $controllerconfig")
	validate_re($hatype, [ '^primary$', '^secondary$', '^notapplicable$' ], "Not a valid hatype: $controllerconfig")

	#4.0.6.1 d961b9c7f86dde9ea5b1af0f46c7635c

	validate_absolute_path($basedir)
	validate_string($ipaddr)

	validate_string($tenacymode)

	if $tenacymode == 'multi'
	{
		validate_string($accountname)
		validate_string($accountkey)
	}

	validate_string($hatype)

	if $hatype == 'secondary'
	{
	  validate_string($ha_mip)
	}

	validate_string( $ha_slave )

	validate_string($rootpw)
	validate_string($adminuser)
	validate_string($adminpw)

	validate_bool($enableudc)

	validate_string($mysqlrootpw)

	validate_absolute_path("$basedir/$installdir")


	validate_string($controller_file)

	file { "/root/.ssh/config":
		    ensure 	=> present,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0600,
		    content 	=> "UserKnownHostsFile=/dev/null\nStrictHostKeyChecking=no\n",
	}

	if ! defined(File['/root/.ssh'])
	{
		file {'/root/.ssh':
			ensure => directory,
			group  => 'root',
			owner  => 'root',
			mode   => '0700',
		}
	}

	#ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiUEYyaOfIQa/MCBmWySntzDjG0yucxWaY6QVfDoEvqYt96nCplKZVD2IDrTJL61ZEASwGIiQU/YpqxNqUuWKa7EiHjD7XqNVLiLwiowkbTgmEpAaGWU/E7+yeFStEy4sJb3wFBh5AcNV/+HxrpuoJHF7XDNjcSAUoWDA4M3Jz7lFz6ziBSmI/VXO8SS4pMC3DNh0Aha5+nAhrG3Cac/2Pj7MbJqx77DROFv2lQkU80gQxA3zth2zCTwzCaZ++aOtrb1K+K40zsLnNxSeBHNPtVRX8SqDAFuBVrG76ZB55/dkgKqJrN+GO5OrMVe8QZvHhPaurPVSQqpaRx7eqQcNz default@appdyn
	ssh_authorized_key { 'appDcont':
		user => 'root',
		type => 'ssh-rsa',
		key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCiUEYyaOfIQa/MCBmWySntzDjG0yucxWaY6QVfDoEvqYt96nCplKZVD2IDrTJL61ZEASwGIiQU/YpqxNqUuWKa7EiHjD7XqNVLiLwiowkbTgmEpAaGWU/E7+yeFStEy4sJb3wFBh5AcNV/+HxrpuoJHF7XDNjcSAUoWDA4M3Jz7lFz6ziBSmI/VXO8SS4pMC3DNh0Aha5+nAhrG3Cac/2Pj7MbJqx77DROFv2lQkU80gQxA3zth2zCTwzCaZ++aOtrb1K+K40zsLnNxSeBHNPtVRX8SqDAFuBVrG76ZB55/dkgKqJrN+GO5OrMVe8QZvHhPaurPVSQqpaRx7eqQcNz',
		require => File['/root/.ssh'],
	}

	file { "/root/.ssh/id_rsa":
		    ensure 	=> present,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0700,
		    source 	=> "puppet:///modules/appdynamics/id_rsa",
				require => File['/root/.ssh'],
	}

	if $hatype != 'secondary'
	{
	    file { [ '/opt', $basedir , "$basedir/$installdir" ]:
		    ensure 	=> directory,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0755,
		    require 	=>  [
				      Ssh_authorized_key['appDcont'],
				      File["/root/.ssh/id_rsa"],
				      File["/root/.ssh/config"],
				    ],
	    }

	if($controller_file==undef)
	{
		$controller_file="puppet:///appdynamics/controller-v$version.sh"
	}

	    file { "$basedir/.$installdir.sh":
		    ensure 	=> present,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0755,
		    require => File["$basedir/$installdir"],
		    source 	=> $controller_file,
	    }

	    file { "$basedir/.varfile":
		    ensure 	=> present,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0444,
		    require => File["$basedir/.$installdir.sh"],
		    content => template("appdynamics/controller-responsefile.erb"),
	    }

	    exec { "instalacio":
		    command 	=> "$basedir/.$installdir.sh -q -varfile $basedir/.varfile",
		    require 	=> File["$basedir/.$installdir.sh"],
		    timeout	=> 900,
		    creates	=> "$basedir/$installdir/bin/controller.sh"
	    }

	    file {  "$basedir/$installdir/HA":
		    ensure 	=> directory,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0755,
	    }

	    file { "$basedir/$installdir/HA/.HA.shar":
		    ensure 	=> present,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0755,
		    require 	=> File["$basedir/$installdir/HA"],
		    source 	=> 'puppet:///modules/appdynamics/HA.shar',
	    }


			#TODO: refer
	    if $ha_slave
	    {
				exec { "$basedir/$installdir/HA/.HA.shar":
					command 	=> "bash $basedir/$installdir/HA/.HA.shar",
					require 	=>  [ File["$basedir/$installdir/HA/.HA.shar"],
								Ssh_authorized_key['appDcont'],
								File["/root/.ssh/id_rsa"],
							],
					timeout	=> 900,
					creates	=> "$basedir/$installdir/HA/replicate.sh",
					cwd		=> "$basedir/$installdir/HA/",
					notify => Exec['slave_lock_file'],
				}

 		    exec { 'slave_lock_file':
 			    command 	=> "ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${ha_slave} touch /opt/appdynamics/.secondary_unlock >/tmp/touch.lock 2>&1",
					refreshonly=> true,
 			    require	=> Exec["${basedir}/${installdir}/HA/.HA.shar"],
 		    }
	    }
			else {
				exec { "$basedir/$installdir/HA/.HA.shar":
					command 	=> "bash $basedir/$installdir/HA/.HA.shar",
					require 	=>  [ File["$basedir/$installdir/HA/.HA.shar"],
								Ssh_authorized_key['appDcont'],
								File["/root/.ssh/id_rsa"],
							],
					timeout	=> 900,
					creates	=> "$basedir/$installdir/HA/replicate.sh",
					cwd		=> "$basedir/$installdir/HA/",
				}
			}
	}
	else
	{
	    file { [ '/opt', $basedir , "$basedir/$installdir" ]:
		    ensure 	=> directory,
		    owner 	=> "root",
		    group 	=> "root",
		    mode 	=> 0755,
		    require 	=>  [ Ssh_authorized_key['appDcont'],
				      File["/root/.ssh/id_rsa"],
				    ],
	    }

	    exec { "instalacio":
		    command	=> "echo confirm | ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@${ha_mip} /opt/appdynamics/controller/HA/replicate.sh -s ${ipaddr} -f -w -i ${ha_mip}",
		    creates	=> "$basedir/$installdir/bin/controller.sh",
		    require 	=> File["$basedir/$installdir"],
		    onlyif 	=> "test -f /opt/appdynamics/.secondary_unlock",
	    }
	}

	file { "/etc/init.d/appdynamics-controller":
		ensure 	=> 'link',
		target 	=> "$basedir/$installdir/bin/controller.sh",
		require => Exec['instalacio'],
	}

	file { "/etc/rc2.d/S99appdynamics-controller":
		ensure 	=> 'link',
		target 	=> "$basedir/$installdir/bin/controller.sh",
		require => Exec['instalacio'],
	}

	file { "/etc/rc3.d/S99appdynamics-controller":
		ensure 	=> 'link',
		target 	=> "$basedir/$installdir/bin/controller.sh",
		require => Exec['instalacio'],
	}

	service { "appdynamics-controller":
		ensure 	=> "running",
		require => Exec['instalacio'],
	}
}
