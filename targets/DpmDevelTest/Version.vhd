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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DA000404"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DpmDevelTest: Vivado v2015.4 (x86_64) Built Wed Apr 20 17:13:34 PDT 2016 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2014 (0xDA000300): Initial Version
-- 06/26/2014 (0xDA000301): PPI
-- 07/01/2014 (0xDA000302): Interrupt controller fix
-- 09/23/2014 (0xDA000303): New RCE and timing.
-- 09/23/2014 (0xDA000400): regression test.
-------------------------------------------------------------------------------

