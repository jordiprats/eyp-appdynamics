# appdynamics

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with appdynamics](#setup)
    * [What appdynamics affects](#what-appdynamics-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with appdynamics](#beginning-with-appdynamics)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What appdynamics affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with appdynamics

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

### appdynamics controller

```puppet
$dependencies=[ 'screen','strace','libaio','dos2unix','rsync']
package { $dependencies: ensure => installed, }

appdynamics::controller { 'evx0301743':
ipaddr              => '10.10.30.41',
hatype              => 'notapplicable',
ha_slave            => '10.10.30.42',
rootpw              => 'd8e8fca2dc0f896fd7cb4cb0031ba249',
adminpw             => '291e1d9f5fd48e36862ffa30d699af4e',
mysqlrootpw         => 'f7b13a2ada8060a9cb81af0464c73f3f',
controllerconfig    => 'medium',
controller_file => 'puppet:///appdynamics/controller-v4.0.6.1.sh',

}

host { 'evx0301743':
  ensure        => present,
  ip            => '10.10.30.41',
}

host { 'evx0301744':
  ensure        => present,
  ip            => '10.10.30.42',
}

appdynamics::controllerlicense { 'llicencia': }
```
### appdynamics controller secondary


```puppet
$dependencies=[ 'screen','strace','libaio','dos2unix','rsync']
package { $dependencies: ensure => installed, }

appdynamics::controller { 'evx0301744':
hatype              => 'secondary',
ha_mip              => '10.10.30.41',
ipaddr              => '10.10.30.42',
controller_file => 'puppet:///appdynamics/controller-v4.0.6.1.sh',

}

host { 'evx0301743':
  ensure        => present,
  ip            => '10.10.30.41',
}

host { 'evx0301744':
  ensure        => present,
  ip            => '10.10.30.42',
}

appdynamics::controllerlicense { 'llicencia':
        basedir => '/opt/appdynamics',
        installdir => 'controller'
}
```


### machineagent

```ruby
$machineagents = hiera('machineagents', {})
create_resources(appdynamics::machineagent, $machineagents)

$ma_nginxmodules = hiera('ma_nginxmodules', {})
create_resources(appdynamics::ma_nginxmodule, $ma_nginxmodules)

$ma_urlmonitors= hiera('ma_urlmonitors', {})
create_resources(appdynamics::ma_urlmonitor, $ma_urlmonitors)
```


```yaml
machineagents:
  machineagent1:
    controllerhost: 192.168.89.253
    uniquehostid: %{::hostname}
    ma_file: puppet:///appdynamics/machineagent-v4.0.7.0.tgz
    orchestration: true
  machineagent2:
    controllerhost: 192.168.89.253
    appname: Approval MBB (CCC)
    tiername: VirtualMachine
    nodename: %{::hostname}
    uniquehostid: %{::ntteam_ipaddress_dev_dfgw}
    ma_file: puppet:///appdynamics/machineagent-v4.0.7.0.tgz
ma_nginxmodules:
  nginxmachineagent2:
    machineagentname: machineagent2
    nginxmodulefile: puppet:///appdynamics/nginx-monitoring-extension.jar
    nodename: %{::hostname}
ma_urlmonitors:
  urlmonitor:
    machineagentname: machineagent1
```


## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
