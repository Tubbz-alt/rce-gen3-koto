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
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DB000066"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10G: Vivado v2016.2 (x86_64) Built Wed Oct  5 08:34:32 PDT 2016 by ruckman";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 10/05/2016 (0xDB000066): Overhauled the AxiStreamDmaRead and added pending AXI read support
-- 09/29/2016 (0xDB000065): Fix a bug for PPI support in ZynqEthernet10G.vhd
-- 09/28/2016 (0xDB000064): Fix a bug where the TX CSUM wasn't caching non-IPv4/UDP/TCP frames
-- 09/28/2016 (0xDB000063): Pause bug fix for latest EthMac
-- 09/23/2016 (0xDB000062): Added Hardware Checksum checking/generating in the EthMac
-- 03/08/2016 (0xDB000061): Pause detect.
-- 03/08/2016 (0xDB000060): Threshold change.
-- 03/08/2016 (0xDB00005F): Change PPI frame size.
-- 03/08/2016 (0xDB00005E): Stable Fix.
-- 03/08/2016 (0xDB00005B): PGP - PPI Bridge Fix.
-- 03/08/2016 (0xDB00005A): PGP - PPI Bridge Fix.
-- 03/03/2016 (0xDB000057): Frame error detect.
-- 01/29/2016 (0xDB000056): Added debug.
-- 01/14/2016 (0xDB000055): SOF in MAC, variable header size.
-- 01/04/2016 (0xDB000054): User ethernet
-- 12/08/2015 (0xDB000053): Inbound header engine.
-- 12/08/2015 (0xDB000052): Debug on mux/dma header in 3
-- 12/08/2015 (0xDB000051): New arb, debug on pause tx
-- 12/08/2015 (0xDB000050): ar/aw size fix
-- 12/08/2015 (0xDB00004D): Test drop fix.
-- 12/07/2015 (0xDB00004C): Vivado 2015.3
-- 11/30/2015 (0xDB00004B): restored cache settings.
-- 11/30/2015 (0xDB00004A): CRC Fix
-- 11/30/2015 (0xDB000047): Debug.
-- 11/30/2015 (0xDB000046): Fix multicast.
-- 11/30/2015 (0xDB000043): Mac Swap.
-- 11/09/2015 (0xDB000042): Fix.
-- 11/09/2015 (0xDB000041): Fix.
-- 11/09/2015 (0xDB000040): New MAC
-- 10/23/2015 (0xDB000030): Test user memory interface
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
