# openvpn.pp -- create a "virtual" OpenVPN Server within a vserver
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# configures the specified vserver for openvpn hosting
# see also http://oldwiki.linux-vserver.org/some_hints_from_john
# and http://linux-vserver.org/Frequently_Asked_Questions#Can_I_run_an_OpenVPN_Server_in_a_guest.3F

class virtual::openvpn::host_base {
	package { "openvpn": ensure => installed }
}
define virtual::openvpn::host() {
	include virtual::openvpn::host_base
	exec { "mktun for ${name}":
		command => "./MAKEDEV tun",
		cwd => "/etc/vservers/${name}/vdir/dev",
		creates => "/etc/vservers/${name}/vdir/dev/net/tun";
	}
}
