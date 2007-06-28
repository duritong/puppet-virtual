# virtual/init.pp -- miscellaneous stuff for virtual hosts and guests
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Based on the work of abnormaliti on http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe
# For the NTP stuff see ntp.pp

file {
	"$rubysitedir/facter/virtual.rb":
		source => "puppet://$servername/virtual/facter/virtual.rb",
		mode => 0755, owner => root, group => root;
	"$rubysitedir/facter/vserver.rb":
		source => "puppet://$servername/virtual/facter/vserver.rb",
		mode => 0755, owner => root, group => root;
}

class vserver_host {

	package { [ 'util-vserver', debootstrap ]: ensure => installed, }

	file {
		"/usr/local/bin/build_vserver":
			source => "puppet://$servername/virtual/build_vserver",
			mode => 0755, owner => root, group => root,
			require => [ Package['util-vserver'], Package[debootstrap] ];
	}
	
}

# ensure: present, stopped, running
define vserver($ensure, $in_domain = $domain) {
	case $ensure {
		present: {
			exec { "/usr/local/bin/build_vserver \"${name}\" \"${in_domain}\"":
				creates => "/etc/vservers/${name}",
				require => File["/usr/local/bin/build_vserver"],
			}
		}
	}

	case $ensure {
		stopped: {
			exec { "vserver ${name} stop":
				onlyif => "test -e \$(readlink -f /etc/vservers/$name/run)",
			}
		}
		running: {
			exec { "vserver ${name} start":
				unless => "test -e \$(readlink -f /etc/vservers/$name/run)",
			}
		}
	}


}
