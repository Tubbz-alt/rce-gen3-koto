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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DB000003"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Dpm10G: Built Sun Aug 17 19:31:20 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2014 (0xDB000001): First Version
-- 08/05/2014 (0xDB000002): Second Version
-- 08/17/2014 (0xDB000003): FIXED PPI
-------------------------------------------------------------------------------

