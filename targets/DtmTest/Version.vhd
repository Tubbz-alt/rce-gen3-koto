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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DC200308"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DtmTest: Built Thu Aug 21 10:37:08 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 05/14/2014 (0xDC200300): New Structure
-- 05/14/2014 (0xDC200301): Added ID register.
-- 05/14/2014 (0xDC200302): Increase Speed
-- 05/14/2014 (0xDC200303): Shift testing
-- 05/14/2014 (0xDC200304): PPI Test.
-- 05/14/2014 (0xDC200305): PPI Fix, pineline addition.
-- 07/07/2014 (0xDC200306): 1Gbps PGP Test
-- 07/08/2014 (0xDC200307): 1Gbps PGP Test
-- 07/08/2014 (0xDC200308): Updated BSI. Back to 5G test.
-------------------------------------------------------------------------------

