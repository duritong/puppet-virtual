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
		"/etc/vservers/local-interfaces/":
			ensure => directory,
			mode => 0755, owner => root, group => root;
	}
	
}

define vs_create($in_domain) { 
	exec { "/usr/local/bin/build_vserver \"${name}\" \"${in_domain}\"":
		creates => "/etc/vservers/${name}",
		require => File["/usr/local/bin/build_vserver"],
		alias => "vs_create_${name}"
	}
}
		

# ensure: present, stopped, running
define vserver($ensure, $in_domain = $domain) {
	# TODO: wasn't there a syntax for using arrays as case selectors??
	case $ensure {
		present: { vs_create{$name: in_domain => $in_domain } }
		running: { vs_create{$name: in_domain => $in_domain } }
		stopped: { vs_create{$name: in_domain => $in_domain } }
		default: { err("${fqdn}: vserver(${name}): unknown ensure '${ensure}'") }
	}

	file { "/etc/vservers/${name}/interfaces/":
		ensure => directory, checksum => mtime,
	}

	case $ensure {
		stopped: {
			exec { "vserver ${name} stop":
				onlyif => "test -e \$(readlink -f /etc/vservers/$name/run)",
				require => Exec["vs_create_${name}"],
			}
		}
		running: {
			exec { "vserver ${name} start":
				unless => "test -e \$(readlink -f /etc/vservers/$name/run)",
				require => Exec["vs_create_${name}"],
			}

			exec { "vserver ${name} restart":
				refreshonly => true,
				require => Exec["vs_create_${name}"],
				alias => "vs_restart_${name}",
				subscribe => File["/etc/vservers/${name}/interfaces/"]
			}
		}
	}

}

define vs_interface($prefix = 24, $dev = '') {
	file {
		"/etc/vservers/local-interfaces/${name}/":
			ensure => directory,
			mode => 0755, owner => root, group => root;
		"/etc/vservers/local-interfaces/${name}/ip":
			content => "${name}\n",
			mode => 0644, owner => root, group => root;
		"/etc/vservers/local-interfaces/${name}/prefix":
			content => "${prefix}\n",
			mode => 0644, owner => root, group => root;
	}

	case $dev {
		'': {
			file { 
				"/etc/vservers/local-interfaces/${name}/nodev":
					ensure => present,
					mode => 0644, owner => root, group => root;
				"/etc/vservers/local-interfaces/${name}/dev":
					ensure => absent;
			}
		}
		default: {
			config_file { "/etc/vservers/local-interfaces/${name}/dev": content => $dev, }
			file { "/etc/vservers/local-interfaces/${name}/nodev": ensure => absent, }
		}
	}
}

define vs_ip($vserver, $ip, $ensure) {
	case $ensure {
		connected: {
			file { "/etc/vservers/${vserver}/interfaces/${name}":
				ensure => "/etc/vservers/local-interfaces/${ip}/",
				require => File["/etc/vservers/local-interfaces/${ip}/"], 
				notify => Exec["vs_restart_${vserver}"],
			}
		}
		disconnected: {
			file { "/etc/vservers/${vserver}/interfaces/${name}":
				ensure => absent,
				# TODO: fix message:
				# warning: //ic/vs_ip[mailman_00]/File[/etc/vservers/mailman/interfaces/mailman_00]: Exec[vserver mailman restart] still depend on me -- not deleting
				# notify => Exec["vs_restart_${vserver}"],
			}
		}
		default: {
			err( "${fqdn}: vs_ip: ${vserver} -> ${ip}: unknown ensure: '${ensure}'" )
		}
	}
}
