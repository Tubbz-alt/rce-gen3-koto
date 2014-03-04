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

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DB000220"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Built Tue Mar  4 10:54:46 PST 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 06/26/2013 (0xDA000000): Initial Version
-- 07/08/2013 (0xDA000003): Ethernet fix.
-- 07/08/2013 (0xDA000004): New FIFOs
-- 10/22/2013 (0xDA000005): New structures
-- 10/23/2013 (0xDA000006): Fixes.
-- 10/26/2013 (0xDA000007): New build structure
-- 11/05/2013 (0xDA000009): Changed outbound free list FIFOs
-- 11/05/2013 (0xDA00000A): Added common DPM block
-- 11/18/2013 (0xDA000200): Vivado Build
-- 12/11/2013 (0xDA000201): Added timing
-- 12/11/2013 (0xDA000202): Version Change
-- 12/11/2013 (0xDA000203): Reset change
-- 12/16/2013 (0xDA000204): Added LEDs
-- 12/16/2013 (0xDA000205): PGP local vc loop
-- 12/16/2013 (0xDA000206): PGP vc grame generate
-- 12/20/2013 (0xDA000207): 5.0G PGP
-- 12/26/2013 (0xDA000208): Seperate resets
-- 12/26/2013 (0xDA00020A): Low power mode, usage mode 2
-- 12/26/2013 (0xDA00020B): usage mode 2
-- 12/26/2013 (0xDA00020E): CDR Update
-- 12/26/2013 (0xDA00020F): 1.25 gbps
-- 12/26/2013 (0xDA000211): 1.25 gbps, CDR Update
-- 12/26/2013 (0xDA000213): 1.25 gbps, CDR Update, seperate resets
-- 12/26/2013 (0xDA000214): 5.00 gbps, CDR Update, seperate resets
-- 12/26/2013 (0xDA000215): 5.00 gbps, CDR Update, seperate resets, Higher drive
-- 12/26/2013 (0xDA000216): 1.25 gbps, CDR Update, seperate resets, Higher drive
-- 12/26/2013 (0xDA000217): 5.00 gbps, CDR Update, seperate resets, Higher drive
-- 12/26/2013 (0xDA000218): 5.00 gbps, CDR Update, seperate resets, Max drive
-- 12/26/2013 (0xDA000219): 5.00 gbps, CDR Update, seperate resets, drive 0100
-- 12/26/2013 (0xDA00021A): 5.00 gbps, CDR Update, seperate resets, standard drive
-- 12/26/2013 (0xDA00021B): 5.00 gbps, CDR Update, seperate resets, standard drive, tx inhibit
-- 12/26/2013 (0xDA00021C): 5.00 gbps, CDR Update, seperate resets, 300mv, tx inhibit
-- 12/26/2013 (0xDA00021D): 5.00 gbps, CDR Update, seperate resets, 1000mv, tx inhibit
-- 12/26/2013 (0xDA00021E): 5.00 gbps, CDR Update, seperate resets, standard drive, tx inhibit, no ethernet
-- 12/26/2013 (0xDA00021F): new build test
-- 12/26/2013 (0xDA000220): 5.00 gbps, standard drive
-------------------------------------------------------------------------------

