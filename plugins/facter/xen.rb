# xen.rb -- linux-vserver.org related facts
# Copyright (C) 2008 Puzzle ITC
# See LICENSE for the full license granted to you.

Facter.add("xen_domains") do
	confine :virtual => :xen0
	ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
	setcode do
        %x{xm list | egrep -v '(^Name|^Domain-0)' | wc -l}.chomp
	end
end

