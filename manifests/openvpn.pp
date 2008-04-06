# openvpn.pp -- create a "virtual" OpenVPN Server within a vserver
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# configures the specified vserver for openvpn hosting
# see also http://oldwiki.linux-vserver.org/some_hints_from_john

class virtual::openvpn::host_base {
	package { "openvpn": ensure => installed }
}
define virtual::openvpn::host() {
	include virtual::openvpn::host_base
	exec { "mktun for ${name}":
		command => "./MAKEDEV tun",
		cwd =< "/etc/vservers/${name}/vdir/dev",
		creates => "/etc/vservers/${name}/vdir/dev/net/tun";
	}
}
