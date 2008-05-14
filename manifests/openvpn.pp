# openvpn.pp -- create a "virtual" OpenVPN Server within a vserver
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# configures the specified vserver for openvpn hosting
# see also http://oldwiki.linux-vserver.org/some_hints_from_john
# and http://linux-vserver.org/Frequently_Asked_Questions#Can_I_run_an_OpenVPN_Server_in_a_guest.3F

class virtual::openvpn::base {
	include openvpn
	modules_dir { "virtual/openvpn": }
}

class virtual::openvpn::host_base inherits virtual::openvpn::base {
	file {
		"/var/lib/puppet/modules/virtual/openvpn/create_interface":
			source => "puppet://$servername/virtual/create_openvpn_interface",
			mode => 0755, owner => root, group => 0;
		"/var/lib/puppet/modules/virtual/openvpn/destroy_interface":
			source => "puppet://$servername/virtual/destroy_openvpn_interface",
			mode => 0755, owner => root, group => 0;
	}
}

define virtual::openvpn::host() {
	include virtual::openvpn::host_base
	exec { "mktun for ${name}":
		command => "./MAKEDEV tun",
		cwd => "/etc/vservers/${name}/vdir/dev",
		creates => "/etc/vservers/${name}/vdir/dev/net/tun";
	}
}

# this configures a specific tun interface for the given subnet
define virtual::openvpn::interface($subnet) {
	# create and setup the interface if it doesn't exist already
	# this is a "bit" coarse grained but works for me
	ifupdown::manual {
		$name:
			up => "/var/lib/puppet/modules/virtual/openvpn/create_interface ${name} ${subnet}",
			down => "/var/lib/puppet/modules/virtual/openvpn/destroy_interface ${name} ${subnet}" 
	}
}

# actually setup the openvpn server within a vserver
define virtual::openvpn::server($ensure = 'running', $config) {
	include virtual::openvpn::base
	file {
		"/etc/openvpn/${name}.conf":
			ensure => present, content => $config,
			mode => 0644, owner => root, group => 0;
	}
	service { 'openvpn':
		ensure => $ensure,
		hasrestart => true
	}
}
