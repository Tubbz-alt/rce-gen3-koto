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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC000304"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DtmEmpty: Built Fri Sep 26 13:08:00 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 05/14/2014 (0xDC000300): New Structure
-- 05/14/2014 (0xDC000301): Removed BSI FIFO
-- 05/14/2014 (0xDC000302): PPI
-- 09/26/2014 (0xDC000304): New Timing.
-------------------------------------------------------------------------------

