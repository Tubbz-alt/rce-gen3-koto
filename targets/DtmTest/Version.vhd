-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : COB Zynq DTM
-------------------------------------------------------------------------------
-- File          : Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/07/2013
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- Copyright (c) 2012 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC200300"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DtmTest: Built Fri May 16 16:23:16 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 05/14/2014 (0xDC200300): New Structure
-------------------------------------------------------------------------------
