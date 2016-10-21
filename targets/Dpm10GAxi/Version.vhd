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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC000012"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10GAxi: Vivado v2016.2 (x86_64) Built Thu Oct 20 22:51:17 PDT 2016 by ruckman";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 10/19/2016 (0xDC000012): Added ZynqUserEthRouter.vhd to separate CPU/USER UDP (non-VLAN) traffic
--                          Changed all 8-bit status registers to 32-bit in ZynqEthernet10GReg.vhd
--                          Added IP address register to ZynqEthernet10GReg.vhd (need to user ETH interface)
-- 10/17/2016 (0xDC000011): Adding EthRxFifoDrop to EthMacCore (not implemented in ZynqEthernet10GReg yet)
--                          EthMacRxPause bug fix
--                          Increased ETH MAC RX FIFO size from 32kB to 64kB (maybe we should make this smaller in the future)
--                          Fixed a bug in SsiFifo for terminating AXIS when overflow detected (refer to SVN# 12764)
-- 10/14/2016 (0xDC000010): Overhauled the AxiStreamDmaWrite
-- 10/14/2016 (0xDC00000F): Tuning the RX FIFO thresholds 
--                          and brought our the RX FIFO configuration to the top level of EthMacTop.vhd
-- 10/12/2016 (0xDC00000E): Fixed bug in the SSI FIFO filtering and adjusted the RX FIFO pause threshold 
-- 10/09/2016 (0xDC00000D): Fixed bug in "U_Reg : entity work.ZynqEthernet10GReg" port mapping
-- 10/07/2016 (0xDC00000C): Setting (USER_ETH_EN_G to false) & tUser bug fix for PPI
-- 10/06/2016 (0xDC00000B): Moved the TX/RX AxisStreamShift modules outside of the EthMac
-- 10/05/2016 (0xDC00000A): Overhauled the AxiStreamDmaRead and added pending AXI read support
-- 09/28/2016 (0xDC000009): Fix a bug where the TX CSUM wasn't caching non-IPv4/UDP/TCP frames
-- 09/28/2016 (0xDC000008): Pause bug fix for latest EthMac
-- 09/22/2016 (0xDC000007): Added Hardware Checksum checking/generating in the EthMac
-- 04/22/2016 (0xDC000006): Latest modules.
-- 02/18/2016 (0xDC000005): New read DMA
-- 01/08/2016 (0xDC000004): User space hooks.
-- 12/06/2015 (0xDC000003): Included fixes from RCE debug.
-- 11/17/2015 (0xDC000002): Bug fixes.
-- 11/10/2015 (0xDC000001): First Version
-------------------------------------------------------------------------------
