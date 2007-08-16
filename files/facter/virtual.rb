# Copied from http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe?version=6
# Authored by abnormaliti with contributions by daniel@nsp.co.nz and mwr
	
# This defines the fact "virtual" with the possible values of "physical",
# "vmware", "vmware_server", "xenu", or "xen0"
	
Facter.add("virtual") do
	confine :kernel => :linux
	
	ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
	
	result = "physical"
	
	setcode do
	
		lspciexists = system "which lspci >&/dev/null"
		if $?.exitstatus == 0
			output = %x{lspci}
			output.each {|p|
				# --- look for the vmware video card to determine if it is virtual => vmware.
				# ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
				result = "vmware" if p =~ /VMware/
			}
		end
		
		# VMware server 1.0.3 rpm places vmware-vmx in this place, other versions or platforms may not.
		if FileTest.exists?("/usr/lib/vmware/bin/vmware-vmx")
			result = "vmware_server"
		end
		
		if FileTest.exists?("/proc/xen/capabilities") and File.read("/proc/xen/capabilities") =~ /control_d/i
			result = "xen0"
		elsif FileTest.exists?("/proc/sys/xen/independent_wallclock")
			result = "xenu"
		end
		result
	end
end
	
