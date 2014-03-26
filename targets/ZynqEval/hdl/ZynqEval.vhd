-------------------------------------------------------------------------------
-- ZynqEval.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity ZynqEval is
   port (
      i2cSda     : inout sl;
      i2cScl     : inout sl
   );
end ZynqEval;

architecture STRUCTURE of ZynqEval is

   -- Local Signals
   signal ppiClk               : slv(3 downto 0);
   signal ppiOnline            : slv(3 downto 0);
   signal ppiReadToFifo        : PpiReadToFifoArray(3 downto 0);
   signal ppiReadFromFifo      : PpiReadFromFifoArray(3 downto 0);
   signal ppiWriteToFifo       : PpiWriteToFifoArray(3 downto 0);
   signal ppiWriteFromFifo     : PpiWriteFromFifoArray(3 downto 0);
   signal axiClk               : sl;
   signal axiClkRst            : sl;
   signal sysClk125            : sl;
   signal sysClk125Rst         : sl;
   signal sysClk200            : sl;
   signal sysClk200Rst         : sl;
   signal localAxiReadMaster   : AxiLiteReadMasterType;
   signal localAxiReadSlave    : AxiLiteReadSlaveType;
   signal localAxiWriteMaster  : AxiLiteWriteMasterType;
   signal localAxiWriteSlave   : AxiLiteWriteSlaveType;

begin

   -- Core
   U_EvalCore: entity work.EvalCore
      port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => sysClk125,
         sysClk125Rst        => sysClk125Rst,
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         localAxiReadMaster  => localAxiReadMaster,
         localAxiReadSlave   => localAxiReadSlave,
         localAxiWriteMaster => localAxiWriteMaster,
         localAxiWriteSlave  => localAxiWriteSlave,
         ppiClk              => ppiClk,
         ppiOnline           => ppiOnline,
         ppiReadToFifo       => ppiReadToFifo,
         ppiReadFromFifo     => ppiReadFromFifo,
         ppiWriteToFifo      => ppiWriteToFifo,
         ppiWriteFromFifo    => ppiWriteFromFifo
      );

   -- Empty AXI Slave
   U_AxiLiteEmpty: entity work.AxiLiteEmpty 
      port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         axiReadMaster   => localAxiReadMaster,
         axiReadSlave    => localAxiReadSlave,
         axiWriteMaster  => localAxiWriteMaster,
         axiWriteSlave   => localAxiWriteSlave
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   U_LoopGen : for i in 0 to 3 generate

      ppiClk(i) <= axiClk;

      ppiWriteToFifo(i).data    <= ppiReadFromFifo(i).data;
      ppiWriteToFifo(i).size    <= ppiReadFromFifo(i).size;
      ppiWriteToFifo(i).ftype   <= ppiReadFromFifo(i).ftype;
      ppiWriteToFifo(i).mgmt    <= ppiReadFromFifo(i).mgmt;
      ppiWriteToFifo(i).eoh     <= ppiReadFromFifo(i).eoh;
      ppiWriteToFifo(i).eof     <= ppiReadFromFifo(i).eof;
      ppiWriteToFifo(i).err     <= '0';

      ppiWriteToFifo(i).valid   <= ppiReadFromFifo(i).valid;

      ppiReadToFifo(i).read     <= ppiReadFromFifo(i).valid;

   end generate;

end architecture STRUCTURE;

