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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DA100309"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DpmTest: Vivado v2014.4 (x86_64) Built Mon Dec  7 10:17:31 PST 2015 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2013 (0xDA100300): Initial Version
-- 06/26/2013 (0xDA100301): PPI
-- 06/26/2013 (0xDA100302): PPi Fix, added piplines.
-- 07/07/2013 (0xDA100303): 1Gbps PGP test
-- 07/09/2013 (0xDA100304): Flow control fix, 1Gbps
-- 08/19/2014 (0xDA100305): 5Gbps PGP test
-- 08/19/2014 (0xDA100306): 1Gbps, PPI and new BSI
-- 09/23/2014 (0xDA100307): Updates, 5Gbps
-- 10/21/2014 (0xDA100308): Tweak cdr settings and cell size for hps test.
-- 12/06/2015 (0xDA100309): Compile test.
-------------------------------------------------------------------------------

