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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC000001"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10G: Vivado v2015.1 (x86_64) Built Wed Aug 26 15:20:46 PDT 2015 by bareese";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 11/10/2015 (0xDC000001): First Version
-------------------------------------------------------------------------------
