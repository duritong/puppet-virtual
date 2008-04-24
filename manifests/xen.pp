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
