-------------------------------------------------------------------------------
-- ZynqDtm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqDtm is
   port (

      -- Debug
      led          : out   slv(1 downto 0);

      -- I2C
      i2cSda       : inout sl;
      i2cScl       : inout sl;

      -- PCI Exress
      pciRefClkP   : in    sl;
      pciRefClkM   : in    sl;
      pciRxP       : in    sl;
      pciRxM       : in    sl;
      pciTxP       : out   sl;
      pciTxM       : out   sl;
      pciResetL    : out   sl;

      -- COB Ethernet
      ethRxP      : in    sl;
      ethRxM      : in    sl;
      ethTxP      : out   sl;
      ethTxM      : out   sl;

      -- Reference Clock
      locRefClkP  : in    sl;
      locRefClkM  : in    sl;

      -- Clock Select
      clkSelA     : out   sl;
      clkSelB     : out   sl;

      -- Base Ethernet
      ethRxCtrl   : in    slv(1 downto 0);
      ethRxClk    : in    slv(1 downto 0);
      ethRxDataA  : in    Slv(1 downto 0);
      ethRxDataB  : in    Slv(1 downto 0);
      ethRxDataC  : in    Slv(1 downto 0);
      ethRxDataD  : in    Slv(1 downto 0);
      ethTxCtrl   : out   slv(1 downto 0);
      ethTxClk    : out   slv(1 downto 0);
      ethTxDataA  : out   Slv(1 downto 0);
      ethTxDataB  : out   Slv(1 downto 0);
      ethTxDataC  : out   Slv(1 downto 0);
      ethTxDataD  : out   Slv(1 downto 0);
      ethMdc      : out   Slv(1 downto 0);
      ethMio      : inout Slv(1 downto 0);
      ethResetL   : out   Slv(1 downto 0);

      -- RTM High Speed
      --dtmToRtmHsP : out   slv(1 downto 0);
      --dtmToRtmHsM : out   slv(1 downto 0);
      --rtmToDtmHsP : in    slv(1 downto 0);
      --rtmToDtmHsM : in    slv(1 downto 0);

      -- RTM Low Speed
      dtmToRtmLsP  : inout slv(5 downto 0);
      dtmToRtmLsM  : inout slv(5 downto 0);

      -- DPM Signals
      dpmClkP      : out   slv(2  downto 0);
      dpmClkM      : out   slv(2  downto 0);
      dpmFbP       : in    slv(7  downto 0);
      dpmFbM       : in    slv(7  downto 0);

      -- Backplane Clocks
      bpClkIn      : in    slv(5 downto 0);
      bpClkOut     : out   slv(5 downto 0);

      -- IPMI
      dtmToIpmiP   : out   slv(1 downto 0);
      dtmToIpmiM   : out   slv(1 downto 0);

      -- Spare Signals
      plSpareP     : inout slv(4 downto 0);
      plSpareM     : inout slv(4 downto 0)

   );
end ZynqDtm;

architecture STRUCTURE of ZynqDtm is

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
   signal localBusMaster : LocalBusMasterVector(14 downto 8);
   signal localBusSlave  : LocalBusSlaveVector(14 downto 8);
   signal locRefClk      : sl;
   signal dpmFb          : slv(7 downto 0);
   signal dpmClk         : slv(2 downto 0);
   signal plSpareDis     : slv(4 downto 0);
   signal plSpareIn      : slv(4 downto 0);
   signal plSpareOut     : slv(4 downto 0);
   signal timingCode     : slv(7 downto 0);
   signal timingCodeEn   : sl;
   signal fbCode         : Slv8Array(7 downto 0);
   signal fbCodeEn       : slv(7 downto 0);

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DtmCore: entity work.DtmCore 
      port map (
         i2cSda          => i2cSda,
         i2cScl          => i2cScl,
         pciRefClkP      => pciRefClkP,
         pciRefClkM      => pciRefClkM,
         pciRxP          => pciRxP,
         pciRxM          => pciRxM,
         pciTxP          => pciTxP,
         pciTxM          => pciTxM,
         pciResetL       => pciResetL,
         ethRxP          => ethRxP,
         ethRxM          => ethRxM,
         ethTxP          => ethTxP,
         ethTxM          => ethTxM,
         locRefClkP      => locRefClkP,
         locRefClkM      => locRefClkM,
         locRefClk       => locRefClk,
         clkSelA         => clkSelA,
         clkSelB         => clkSelB,
         ethRxCtrl       => ethRxCtrl,
         ethRxClk        => ethRxClk,
         ethRxDataA      => ethRxDataA,
         ethRxDataB      => ethRxDataB,
         ethRxDataC      => ethRxDataC,
         ethRxDataD      => ethRxDataD,
         ethTxCtrl       => ethTxCtrl,
         ethTxClk        => ethTxClk,
         ethTxDataA      => ethTxDataA,
         ethTxDataB      => ethTxDataB,
         ethTxDataC      => ethTxDataC,
         ethTxDataD      => ethTxDataD,
         ethMdc          => ethMdc,
         ethMio          => ethMio,
         ethResetL       => ethResetL,
         dpmClkP         => dpmClkP,
         dpmClkM         => dpmClkM,
         dpmClk          => dpmClk,
         dpmFbP          => dpmFbP,
         dpmFbM          => dpmFbM,
         dpmFb           => dpmFb,
         dtmToIpmiP      => dtmToIpmiP,
         dtmToIpmiM      => dtmToIpmiM,
         plSpareP        => plSpareP,
         plSpareM        => plSpareM,
         plSpareDis      => plSpareDis,
         plSpareIn       => plSpareIn,
         plSpareOut      => plSpareOut,
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         sysClk125       => sysClk125,
         sysClk125Rst    => sysClk125Rst,
         sysClk200       => sysClk200,
         sysClk200Rst    => sysClk200Rst,
         localBusMaster  => localBusMaster,
         localBusSlave   => localBusSlave,
         obPpiClk        => obPpiClk,
         obPpiToFifo     => obPpiToFifo,
         obPpiFromFifo   => obPpiFromFifo,
         ibPpiClk        => ibPpiClk,
         ibPpiToFifo     => ibPpiToFifo,
         ibPpiFromFifo   => ibPpiFromFifo
      );


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

      ibPpiToFifo(i).valid   <= obPpiFromFifo(i).valid;

      obPpiToFifo(i).read    <= obPpiFromFifo(i).valid;

   end generate;


   --------------------------------------------------
   -- Timing Signals
   --------------------------------------------------
   U_DtmTiming : entity work.DtmTimingSource 
      generic map (
         TPD_G => 1 ns
      ) port map (
         axiClk                    => axiClk,
         axiClkRst                 => axiClkRst,
         localBusMaster            => localBusMaster(14),
         localBusSlave             => localBusSlave(14),
         sysClk200                 => sysClk200,
         sysClk200Rst              => sysClk200Rst,
         sysClk                    => sysClk200,
         sysClkRst                 => sysClk200Rst,
         timingCode                => timingCode,
         timingCodeEn              => timingCodeEn,
         fbCode                    => fbCode,
         fbCodeEn                  => fbCodeEn,
         dpmClk                    => dpmClk,
         dpmFb                     => dpmFb,
         led                       => led
      );

   timingCode   <= (others=>'0');
   timingCodeEn <= '0';
   --signal fbCode         : Slv8(7 downto 0);
   --signal fbCodeEn       : slv(7 downto 0);




   --------------------------------------------------
   -- Unused Signals
   --------------------------------------------------

   --led <= "11";

   -- Reference
   --signal locRefClk      : sl;

   -- RTM
   dtmToRtmLsP    <= (others=>'Z');
   dtmToRtmLsM    <= (others=>'Z');

   -- Spares
   plSpareDis   <= (others=>'1');
   plSpareOut   <= (others=>'0');
   --signal plSpareIn      : slv(4 downto 0);

   -- Backplane Clocks
   --bpClkIn      : in    slv(5 downto 0);
   bpClkOut <= (others=>'0');

   -- Local bus
   --localBusMaster : LocalBusMasterVector(13 downto 8);
   localBusSlave(13 downto 8)  <= (others=>LocalBusSlaveInit);

   -- Clocks
   --signal axiClk         : sl;
   --signal axiClkRst      : sl;
   --signal sysClk125      : sl;
   --signal sysClk125Rst   : sl;
   --signal sysClk200      : sl;
   --signal sysClk200Rst   : sl;

end architecture STRUCTURE;

