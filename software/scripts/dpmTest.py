#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : Eval board instance
#-----------------------------------------------------------------------------
# File       : evalBoard.py
# Author     : Ryan Herbst, rherbst@slac.stanford.edu
# Created    : 2016-09-29
# Last update: 2016-09-29
#-----------------------------------------------------------------------------
# Description:
# Rogue interface to eval board
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import rogue.hardware.rce.*
import pyrogue.utilities.prbs
import pyrogue.mesh
import pyrogue.epics
import surf.*
import rceg3.*
import atexit
import time

# Set base
dpmTest = pyrogue.Root('dpmTest','DPM Test Image')

# Create the AXI interfaces
rceMap = rogue.hardware.rce.MapMemory();
rce.Map.addMap(0x80000000,0x10000)
rce.Map.addMap(0x84000000,0x10000)

# Add Devices
dpmTest.add(rceg3.RceVersion(memBase=rceMap))

# Create mesh node
mNode = pyrogue.mesh.MeshNode('rce',iface='eth0',root=dpmTest)
mNode.start()

# Create epics node
epics = pyrogue.epics.EpicsCaServer('rce',dmpTest)
epics.start()

# Close window and stop polling
def stop():
    mNode.stop()
    epics.stop()
    dpmTest.stop()
    exit()

# Start with ipython -i scripts/evalBoard.py
print("Started rogue mesh and epics V3 server. To exit type stop()")

