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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC000005"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10GAxi: Vivado v2015.3 (x86_64) Built Fri Feb 19 00:08:49 PST 2016 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 02/18/2016 (0xDC000005): New read dma
-- 01/08/2016 (0xDC000004): User space hooks.
-- 12/06/2015 (0xDC000003): Included fixes from RCE debug.
-- 11/17/2015 (0xDC000002): Bug fixes.
-- 11/10/2015 (0xDC000001): First Version
-------------------------------------------------------------------------------
