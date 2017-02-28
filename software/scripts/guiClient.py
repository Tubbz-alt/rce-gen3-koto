#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# Title      : GUI Client
#-----------------------------------------------------------------------------
# File       : guiClient.py
# Author     : Ryan Herbst, rherbst@slac.stanford.edu
# Created    : 2016-09-29
# Last update: 2016-09-29
#-----------------------------------------------------------------------------
# Description:
# Generic GUI client for rogue
#-----------------------------------------------------------------------------
# This file is part of the rogue_example software. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue_example software, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue.mesh
import pyrogue.gui
import PyQt4.QtGui
import getopt
import sys
import logging

group = 'rce'
iface = 'eth3'

try:
    opts, args = getopt.getopt(sys.argv[1:],"hi:g:")
except getopt.GetoptError:
    print('guiClient.py -i <interface> -g <group>')
    sys.exit(2)

for opt, arg in opts:
    if opt == '-h':
        print('test.py -i <inputfile> -o <outputfile>')
        sys.exit()
    elif opt in ("-i"):
        iface = arg
    elif opt in ("-g"):
        group = arg

print("Using interface {} for group {}".format(iface,group))

#logging.getLogger("pyrogue").setLevel(logging.DEBUG)
#logging.getLogger("pyre").setLevel(logging.DEBUG)

# Create mesh node
node = pyrogue.mesh.MeshNode(group,iface=iface)

# Create GUI
appTop = PyQt4.QtGui.QApplication(sys.argv)
guiTop = pyrogue.gui.GuiTop(group)
node.setNewTreeCb(guiTop.addTree)

# Start mesh
node.start()

# Run gui
appTop.exec_()

# Stop mesh after gui exits
print("Waiting on node")
node.stop()

