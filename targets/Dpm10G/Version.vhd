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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DB000028"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10G: Vivado v2015.1 (x86_64) Built Wed Aug 26 15:20:46 PDT 2015 by bareese";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 08/25/2015 (0xDB000028): Rebuilt with updated AxiStreamMux
-- 08/05/2015 (0xDB000027): Adjusted inbound thresholds
-- 05/15/2015 (0xDB000026): Added PPI PGP Array
-- 03/07/2015 (0xDB000025): Size check
-- 03/07/2015 (0xDB000024): PPI Flow Control Bug
-- 02/17/2015 (0xDB000023): PPI Core fix
-- 02/08/2015 (0xDB000022): Added counters.
-- 02/08/2015 (0xDB000021): Added counters.
-- 01/20/2015 (0xDB000020): Removed shifters.
-- 01/20/2015 (0xDB00001F): Fixed pause frame generation.
-- 01/20/2015 (0xDB00001E): Added shift enables to fix first frame bug.
-- 01/13/2015 (0xDB00001D): Register Fix.
-- 01/13/2015 (0xDB00001C): Export shift added.
-- 01/13/2015 (0xDB00001B): Import shift added.
-- 01/13/2015 (0xDB00001A): Removed shifters.
-- 01/13/2015 (0xDB000019): Pause RX FIX.
-- 01/09/2015 (0xDB000018): Fix.
-- 01/09/2015 (0xDB000017): Added pause counters
-- 01/09/2015 (0xDB000016): Enabled inter-frame gap after pause frames
-- 01/09/2015 (0xDB000015): Buffer size increase
-- 01/06/2015 (0xDB000014): Full library update.
-- 01/06/2015 (0xDB000013): AXI Stream FIFO fix.
-- 11/03/2014 (0xDB000012): RCE Updates, removed PPI crossbar, added debug.
-- 09/24/2014 (0xDB000011): New RCE, new clocking.
-- 08/31/2014 (0xDB000010): PPI Bug Fix.
-- 08/19/2014 (0xDB00000f): state count fix.
-- 08/19/2014 (0xDB00000e): Export fixes. Proper simulation.
-- 08/19/2014 (0xDB00000d): Fifo and threshold fix.
-- 08/19/2014 (0xDB00000C): Valid threshold change.
-- 08/19/2014 (0xDB00000B): Valid threshold change.
-- 08/19/2014 (0xDB00000A): Added clock constraints
-- 08/19/2014 (0xDB000009): Added clock constraints
-- 08/19/2014 (0xDB000008): CRC Fix. #3
-- 08/19/2014 (0xDB000007): CRC Fix. #2
-- 08/19/2014 (0xDB000006): CRC Fix.
-- 08/19/2014 (0xDB000005): BSI Change.
-- 08/18/2014 (0xDB000004): PPI Register Changes.
-- 08/17/2014 (0xDB000003): FIXED PPI
-- 08/05/2014 (0xDB000002): Second Version
-- 06/26/2014 (0xDB000001): First Version
-------------------------------------------------------------------------------
