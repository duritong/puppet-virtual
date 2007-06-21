# vserver.rb -- linux-vserver.org related facts
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Based on abnormaliti's "virtual" fact from
# http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe

# This defines the fact "vserver" with the possible values of "none", "guest",
# or "host"

Facter.add("vserver") do
	confine :kernel => :linux
	
	ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
	
	result = "none"
	
	setcode do
		if FileTest.directory?('/proc/virtual')
	 		result = "host"
		elsif ! FileTest.directory?('/proc/2')
				  # gross hack: PID 2 is usually a
				  # kernel thread, which doesn't existin vserver
				  result = "guest"
		end
	
		result
	end
end

