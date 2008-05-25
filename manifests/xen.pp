# virtual/xen.pp -- XEN specifica
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::plugins::xen {
	munin::remoteplugin {
		xen_mem:	
			source => "puppet://$server/virtual/munin/xen_mem",
			config => "user root";
		xen_vm:
			source => "puppet://$server/virtual/munin/xen_vm",
			config => "user root";
	}
}

class xen::domain {
	# install the special libc and parameters to enable it
	$xen_ensure = $virtual ? {
		'xen0' => present,
		'xenu' => present,
		default => 'absent'
	}

	case $ensure {
		'absent': { err("xen::domain configured, but not detected") }
	# This package is i386 only
	# See also http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=379444
    }
	case $architecture {
		'i386': {
			package { libc6-xen:
				ensure => $xen_ensure,
			}
		}
	}

	case $operatingsystem {
		debian: { package { libc6-xen:
				ensure => $xen_ensure,
			  }
			
			  config_file {
				"/etc/ld.so.conf.d/nosegneg.conf":
				ensure => $xen_ensure,
				content => "hwcap 0 nosegneg\n",
			  }
        }
    }
}

# always check whether xen stuff should be installed!
include xen::domain

class xen::dom0 inherits xen::domain {
	# install the packages required for managing xen
	# TODO: this should be followed by a reboot
	package { 
		[ "xen-hypervisor-3.0.3-1-$architecture",
		  "linux-image-xen-$architecture",
		  'libsysfs2' 
		]:
			ensure => present
	}

	case $virtual {
		'xen0': {}
		default: {
			err("dom0 support requested, but not detected. Perhaps you need to reboot ${fqdn}?")
		}
	}
}
