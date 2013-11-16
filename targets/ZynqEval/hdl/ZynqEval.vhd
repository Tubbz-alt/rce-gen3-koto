-------------------------------------------------------------------------------
-- ZynqEval.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqEval is
   port (
      i2cSda     : inout sl;
      i2cScl     : inout sl;
      psSrstB    : in     sl;
      psClk      : in     sl;
      psPorB     : in     sl
   );
end ZynqEval;

architecture STRUCTURE of ZynqEval is

   -- Local Signals
   signal obPpiClk       : slv(3 downto 0);
   signal obPpiToFifo    : ObPpiToFifoVector(3 downto 0);
   signal obPpiFromFifo  : ObPpiFromFifoVector(3 downto 0);
   signal ibPpiClk       : slv(3 downto 0);
   signal ibPpiToFifo    : IbPpiToFifoVector(3 downto 0);
   signal ibPpiFromFifo  : IbPpiFromFifoVector(3 downto 0);
   signal axiClk         : sl;
   signal axiClkRst      : sl;
   signal sysClk125      : sl;
   signal sysClk125Rst   : sl;
   signal sysClk200      : sl;
   signal sysClk200Rst   : sl;
   signal localBusMaster : LocalBusMasterVector(15 downto 8);
   signal localBusSlave  : LocalBusSlaveVector(15 downto 8);

begin

   -- Core
   U_EvalCore: entity work.EvalCore
      port map (
         i2cSda         => i2cSda,
         i2cScl         => i2cScl,
         axiClk         => axiClk,
         axiClkRst      => axiClkRst,
         sysClk125      => sysClk125,
         sysClk125Rst   => sysClk125Rst,
         sysClk200      => sysClk200,
         sysClk200Rst   => sysClk200Rst,
         localBusMaster => localBusMaster,
         localBusSlave  => localBusSlave,
         obPpiClk       => obPpiClk,
         obPpiToFifo    => obPpiToFifo,
         obPpiFromFifo  => obPpiFromFifo,
         ibPpiClk       => ibPpiClk,
         ibPpiToFifo    => ibPpiToFifo,
         ibPpiFromFifo  => ibPpiFromFifo,
         psSrstB        => psSrstB,
         psClk          => psClk,
         psPorB         => psPorB
      );

   localBusSlave <= (others=>LocalBusSlaveInit);

   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   U_LoopGen : for i in 0 to 3 generate

      ibPpiClk(i) <= axiClk;
      obPpiClk(i) <= axiClk;

      ibPpiToFifo(i).data    <= obPpiFromFifo(i).data;
      ibPpiToFifo(i).size    <= obPpiFromFifo(i).size;
      ibPpiToFifo(i).ftype   <= obPpiFromFifo(i).ftype;
      ibPpiToFifo(i).mgmt    <= obPpiFromFifo(i).mgmt;
      ibPpiToFifo(i).eoh     <= obPpiFromFifo(i).eoh;
      ibPpiToFifo(i).eof     <= obPpiFromFifo(i).eof;
      ibPpiToFifo(i).err     <= '0';
      ibPpiToFifo(i).id      <= (others=>'0');
      ibPpiToFifo(i).version <= (others=>'0');
      ibPpiToFifo(i).configA <= (others=>'0');
      ibPpiToFifo(i).configB <= (others=>'0');

      ibPpiToFifo(i).valid   <= obPpiFromFifo(i).valid;

      obPpiToFifo(i).read    <= obPpiFromFifo(i).valid;
      obPpiToFifo(i).id      <= (others=>'0');
      obPpiToFifo(i).version <= (others=>'0');
      obPpiToFifo(i).configA <= (others=>'0');
      obPpiToFifo(i).configB <= (others=>'0');

   end generate;

end architecture STRUCTURE;

