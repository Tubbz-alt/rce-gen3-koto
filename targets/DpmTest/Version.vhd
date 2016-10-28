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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DA10030E"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "DpmTest: Vivado v2016.2 (x86_64) Built Fri Oct 28 09:16:33 PDT 2016 by ruckman";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 10/28/2016 (0xDA10030E): Rebuilding with new AxiStreamDmaWrite AXIS cache support (SVN Revision# 12930)
-- 10/21/2016 (0xDA10030D): Enabling BURST_MODE in inbound AXI stream FIFOs
-- 10/14/2016 (0xDA10030C): Overhauled the AxiStreamDmaWrite
-- 10/07/2016 (0xDA10030B): tUser bug fix for PPI
-- 10/05/2016 (0xDA10030A): Overhauled the AxiStreamDmaRead and added pending AXI read support
-- 12/06/2015 (0xDA100309): Compile test.
-- 10/21/2014 (0xDA100308): Tweak cdr settings and cell size for hps test.
-- 09/23/2014 (0xDA100307): Updates, 5Gbps
-- 08/19/2014 (0xDA100306): 1Gbps, PPI and new BSI
-- 08/19/2014 (0xDA100305): 5Gbps PGP test
-- 07/09/2013 (0xDA100304): Flow control fix, 1Gbps
-- 07/07/2013 (0xDA100303): 1Gbps PGP test
-- 06/26/2013 (0xDA100302): PPi Fix, added piplines.
-- 06/26/2013 (0xDA100301): PPI
-- 06/26/2013 (0xDA100300): Initial Version
-------------------------------------------------------------------------------

