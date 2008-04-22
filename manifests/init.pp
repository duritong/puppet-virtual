# virtual/init.pp -- miscellaneous stuff for virtual hosts and guests
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Based on the work of abnormaliti on http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe

#modules_dir{ "virtual": }

import "vserver.pp"
import "openvpn.pp"
import "xen.pp"
