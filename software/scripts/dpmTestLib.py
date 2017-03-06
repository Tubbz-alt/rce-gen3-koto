#!/usr/bin/env python3
import rogue.hardware.rce
import pyrogue.mesh
import surf
import rceg3

class rce(object):
    def __init__(self):

        # Set base
        self.dpmTest = pyrogue.Root('dpmTest','DPM Test Image')

        # Create the AXI interfaces
        self.rceMap = rogue.hardware.rce.MapMemory();
        self.rceMap.addMap(0x80000000,0x10000)
        self.rceMap.addMap(0x84000000,0x10000)

        # Add Devices
        self.dpmTest.add(rceg3.RceVersion(memBase=self.rceMap))

        # Create mesh node
        self.mNode = pyrogue.mesh.MeshNode('rce',iface='eth0',root=self.dpmTest)
        self.mNode.start()

