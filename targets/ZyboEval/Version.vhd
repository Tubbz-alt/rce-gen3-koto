-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : COB DPM
-------------------------------------------------------------------------------
-- File          : Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/03/2013
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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"F2000001"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "ZyboEval: Vivado v2015.4 (x86_64) Built Tue May 31 14:35:45 PDT 2016 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 04/03/2013 (0xF2000001): Initial Version
-------------------------------------------------------------------------------

