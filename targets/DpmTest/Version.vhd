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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DA100303"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DpmTest: Built Mon Jul  7 17:35:18 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2013 (0xDA100300): Initial Version
-- 06/26/2013 (0xDA100301): PPI
-- 06/26/2013 (0xDA100302): PPi Fix, added piplines.
-- 07/07/2013 (0xDA100303): 1Gbps PGP test
-------------------------------------------------------------------------------

