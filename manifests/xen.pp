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
    case $operatingsystem {
        debian: { include xen::domain::debian }
        centos: { include xen::domain::centos }
        default: { include xen::domain::base }
    }
}

class xen::domain::base {} 

class xen::domain::centos inherits xen::domain::base {
    package{ 'kernel-xen':
        ensure => present,
    }
} 

class xen::domain::debian inherits xen::domain::base {
	# This package is i386 only
	# See also http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=379444
	case $architecture {
		'i386': {
			package { libc6-xen:
				ensure => 'present',
			}
		}
	}

	config_file {
		"/etc/ld.so.conf.d/nosegneg.conf":
			ensure => $xen_ensure,
			content => "hwcap 0 nosegneg\n",
    }
}

class xen::dom0 inherits xen::domain { 
    case $operatingsystem {
        debian: { include xen::dom0::debian }
        centos: { include xen::dom0::centos }
        default: { include xen::dom0::base }
    }
}

class xen::dom0::base {}
class xen::dom0::centos inherits xen::dom0::base {
    package{ [ "xen", "xen-libs"]:
        ensure => present,
    }
}
class xen::dom0::debian inherits xen::dom0::base {
	# install the packages required for managing xen
	package { 
		[ "xen-hypervisor-3.0.3-1-$architecture",
		  "linux-image-xen-$architecture",
		  'libsysfs2' 
		]:
			ensure => present
	}
}
