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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC00000A"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10GAxi: Vivado v2016.2 (x86_64) Built Wed Oct  5 08:34:17 PDT 2016 by ruckman";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 10/05/2016 (0xDC00000A): Overhauled the AxiStreamDmaRead and added pending AXI read support
-- 09/28/2016 (0xDC000009): Fix a bug where the TX CSUM wasn't caching non-IPv4/UDP/TCP frames
-- 09/28/2016 (0xDC000008): Pause bug fix for latest EthMac
-- 09/22/2016 (0xDC000007): Added Hardware Checksum checking/generating in the EthMac
-- 04/22/2016 (0xDC000006): Latest modules.
-- 02/18/2016 (0xDC000005): New read dma
-- 01/08/2016 (0xDC000004): User space hooks.
-- 12/06/2015 (0xDC000003): Included fixes from RCE debug.
-- 11/17/2015 (0xDC000002): Bug fixes.
-- 11/10/2015 (0xDC000001): First Version
-------------------------------------------------------------------------------
