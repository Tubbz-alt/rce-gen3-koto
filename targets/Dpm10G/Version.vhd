-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : COB Zynq DTM 10G Test
-------------------------------------------------------------------------------
-- File          : Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 06/26/2014
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- Copyright (c) 2012 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DB000015"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10G: Built Fri Jan  9 14:34:13 PST 2015 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2014 (0xDB000001): First Version
-- 08/05/2014 (0xDB000002): Second Version
-- 08/17/2014 (0xDB000003): FIXED PPI
-- 08/18/2014 (0xDB000004): PPI Register Changes.
-- 08/19/2014 (0xDB000005): BSI Change.
-- 08/19/2014 (0xDB000006): CRC Fix.
-- 08/19/2014 (0xDB000007): CRC Fix. #2
-- 08/19/2014 (0xDB000008): CRC Fix. #3
-- 08/19/2014 (0xDB000009): Added clock constraints
-- 08/19/2014 (0xDB00000A): Added clock constraints
-- 08/19/2014 (0xDB00000B): Valid threshold change.
-- 08/19/2014 (0xDB00000C): Valid threshold change.
-- 08/19/2014 (0xDB00000d): Fifo and threshold fix.
-- 08/19/2014 (0xDB00000e): Export fixes. Proper simulation.
-- 08/19/2014 (0xDB00000f): state count fix.
-- 08/31/2014 (0xDB000010): PPI Bug Fix.
-- 09/24/2014 (0xDB000011): New RCE, new clocking.
-- 11/03/2014 (0xDB000012): RCE Updates, removed PPI crossbar, added debug.
-- 01/06/2015 (0xDB000013): AXI Stream FIFO fix.
-- 01/06/2015 (0xDB000014): Full library update.
-- 01/09/2015 (0xDB000015): Buffer size increase
-------------------------------------------------------------------------------

