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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC000003"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10GAxi: Vivado v2014.4 (x86_64) Built Sun Dec  6 18:40:57 PST 2015 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 12/06/2015 (0xDC000003): Included fixes from RCE debug.
-- 11/17/2015 (0xDC000002): Bug fixes.
-- 11/10/2015 (0xDC000001): First Version
-------------------------------------------------------------------------------
