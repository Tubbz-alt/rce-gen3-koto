#!/usr/bin/env python3
import rogue.hardware.rce
import pyrogue.utilities.prbs
import pyrogue.mesh
import pyrogue.epics
import surf
import rceg3
import atexit
import time
import logging

# Set base
dpmTest = pyrogue.Root('dpmTest','DPM Test Image')

# Create the AXI interfaces
rceMap = rogue.hardware.rce.MapMemory();
rceMap.addMap(0x80000000,0x10000)
rceMap.addMap(0x84000000,0x10000)

# Add Devices
dpmTest.add(rceg3.RceVersion(memBase=rceMap))

#logging.getLogger("pyre").setLevel(logging.DEBUG)
#logging.getLogger("pyrogue").setLevel(logging.DEBUG)

# Create mesh node
mNode = pyrogue.mesh.MeshNode('rce',iface='eth0',root=dpmTest)
mNode.start()

# Create epics node
epics = pyrogue.epics.EpicsCaServer('rce',dpmTest)
epics.start()

# Close window and stop polling
def stop():
    mNode.stop()
    epics.stop()
    dpmTest.stop()
    exit()

# Start with ipython -i scripts/evalBoard.py
print("Started rogue mesh and epics V3 server. To exit type stop()")

