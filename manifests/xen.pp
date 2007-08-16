# virtual/xen.pp -- XEN specifica
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::plugins::xen {
	munin::remoteplugin {
		xen_mem:	
			source => "puppet://$servername/virtual/munin/xen_mem",
			config => "user root";
		xen_vm:
			source => "puppet://$servername/virtual/munin/xen_vm",
			config => "user root";
	}
}

