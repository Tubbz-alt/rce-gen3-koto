------------------------------------------------------------------------------
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- ZyboEval.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity ZyboEval is
   port (
      i2cSda     : inout sl;
      i2cScl     : inout sl
   );
end ZyboEval;

architecture STRUCTURE of ZyboEval is
   signal sysClk125               : sl;
   signal sysClk125Rst            : sl;
   signal sysClk200               : sl;
   signal sysClk200Rst            : sl;
   signal axiClk                  : sl;
   signal axiClkRst               : sl;
   signal extAxilReadMaster       : AxiLiteReadMasterType;
   signal extAxilReadSlave        : AxiLiteReadSlaveType;
   signal extAxilWriteMaster      : AxiLiteWriteMasterType;
   signal extAxilWriteSlave       : AxiLiteWriteSlaveType;
   signal dmaClk                  : slv(2 downto 0);
   signal dmaClkRst               : slv(2 downto 0);
   signal dmaState                : RceDmaStateArray(2 downto 0);
   signal dmaObMaster             : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave              : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster             : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave              : AxiStreamSlaveArray(2 downto 0);
   signal writeRegister           : Slv32Array(0 downto 0);
   signal readRegister            : Slv32Array(0 downto 0);

   constant TPD_C : time := 1 ns;

begin

   -- Core
   U_EvalCore: entity work.EvalCore
      generic map (
         TPD_G          => TPD_C,
         RCE_DMA_MODE_G => RCE_DMA_AXIS_C
      )
      port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         sysClk125                => sysClk125,
         sysClk125Rst             => sysClk125Rst,
         sysClk200                => sysClk200,
         sysClk200Rst             => sysClk200Rst,
         axiClk                   => axiClk,
         axiClkRst                => axiClkRst,
         extAxilReadMaster        => extAxilReadMaster,
         extAxilReadSlave         => extAxilReadSlave,
         extAxilWriteMaster       => extAxilWriteMaster,
         extAxilWriteSlave        => extAxilWriteSlave,
         dmaClk                   => dmaClk,
         dmaClkRst                => dmaClkRst,
         dmaState                 => dmaState,
         dmaObMaster              => dmaObMaster,
         dmaObSlave               => dmaObSlave,
         dmaIbMaster              => dmaIbMaster,
         dmaIbSlave               => dmaIbSlave,
         userInterrupt            => (others=>'0')
      );

   -- Empty AXI Slave
   U_AxiLiteEmpty: entity work.AxiLiteEmpty 
      port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         axiReadMaster   => extAxilReadMaster,
         axiReadSlave    => extAxilReadSlave,
         axiWriteMaster  => extAxilWriteMaster,
         axiWriteSlave   => extAxilWriteSlave,
         writeRegister   => writeRegister,
         readRegister    => readRegister
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk      <= (others=>sysClk125);
   dmaClkRst   <= (others=>sysClk125Rst);
   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;

end architecture STRUCTURE;

