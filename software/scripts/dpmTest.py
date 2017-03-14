#!/usr/bin/env python3
import rogue.hardware.rce
import pyrogue.utilities.prbs
import pyrogue.mesh
import pyrogue.epics
import pyrogue.utilities.prbs
import surf
import surf.SsiPrbsTx
import rceg3
import atexit
import time
import logging
import sys
import rogue

logging.getLogger("pyre").setLevel(logging.INFO)
logging.getLogger("pyrogue").setLevel(logging.INFO)
#rogue.Logging.setLevel(logging.DEBUG)
#logging.getLogger("pyrogue.rce").setLevel(logging.DEBUG)

# Set base
dpmTest = pyrogue.Root('dpmTest','DPM Test Image')

# Create the AXI interfaces
rceMap = rogue.hardware.rce.MapMemory();
rceMap.addMap(0x80000000,0x10000)
rceMap.addMap(0x84000000,0x10000)
rceMap.addMap(0xA0000000,0x100000)

axisChan = []
prbsRx   = []
prbsTx   = []

for i in range (0,8):
    axisChan.insert(i,rogue.hardware.rce.AxiStream("/dev/axi_stream_dma_0",i))
    prbsRx.insert(i,pyrogue.utilities.prbs.PrbsRx("prbsRx[%i]"%(i)))
    pyrogue.streamConnect(axisChan[i],prbsRx[i])
    prbsTx.insert(i,surf.SsiPrbsTx.create("SsiPrbsTx[%i]"%(i),offset=0xA0020000+(0x10000*i),memBase=rceMap))

# Add Devices
dpmTest.add(rceg3.RceVersion(memBase=rceMap))
dpmTest.add(prbsTx)
dpmTest.add(prbsRx)

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

f = open('none_log.txt','w')
cnt = 0

while True:
    time.sleep(1)
#    cnt += 1
#    tot = 0
#    for i in range(0,8):
#       tot += dpmTest.prbsRx[i].rxCount.get()
#
#    msg = "%i %i %i" % (cnt,tot,sys.getrefcount(None))
#    print(msg)
#    f.write(msg + "\n")
#    f.flush()

