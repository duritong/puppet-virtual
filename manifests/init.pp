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
