-------------------------------------------------------------------------------
-- ZynqDpm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqDpm is
   port (

      -- Debug
      led          : out   slv(1 downto 0);

      -- I2C
      i2cSda       : inout sl;
      i2cScl       : inout sl;

      -- Ethernet
      ethRxP       : in    slv(0 downto 0);
      ethRxM       : in    slv(0 downto 0);
      ethTxP       : out   slv(0 downto 0);
      ethTxM       : out   slv(0 downto 0);

      -- RTM High Speed
      --dpmToRtmHsP  : out   slv(11 downto 0);
      --dpmToRtmHsM  : out   slv(11 downto 0);
      --rtmToDpmHsP  : in    slv(11 downto 0);
      --rtmToDpmHsM  : in    slv(11 downto 0);

      -- Reference Clocks
      locRefClkP   : in    slv(1  downto 0);
      locRefClkM   : in    slv(1  downto 0);
      dtmRefClkP   : in    sl;
      dtmRefClkM   : in    sl;

      -- DTM Signals
      dtmClkP      : in    slv(1  downto 0);
      dtmClkM      : in    slv(1  downto 0);
      dtmFbP       : out   sl;
      dtmFbM       : out   sl;

      -- Clock Select
      clkSelA      : out   slv(1 downto 0);
      clkSelB      : out   slv(1 downto 0)
   );
end ZynqDpm;

architecture STRUCTURE of ZynqDpm is

   -- Local Signals
   signal obPpiClk       : slv(3 downto 0);
   signal obPpiToFifo    : ObPpiToFifoVector(3 downto 0);
   signal obPpiFromFifo  : ObPpiFromFifoVector(3 downto 0);
   signal ibPpiClk       : slv(3 downto 0);
   signal ibPpiToFifo    : IbPpiToFifoVector(3 downto 0);
   signal ibPpiFromFifo  : IbPpiFromFifoVector(3 downto 0);
   signal dtmFb          : sl;
   signal dtmClk         : slv(1 downto 0);
   signal locRefClk      : slv(1 downto 0);
   signal dtmRefClk      : sl;
   signal axiClk         : sl;
   signal axiClkRst      : sl;
   signal sysClk125      : sl;
   signal sysClk125Rst   : sl;
   signal sysClk200      : sl;
   signal sysClk200Rst   : sl;
   signal localBusMaster : LocalBusMasterVector(15 downto 8);
   signal localBusSlave  : LocalBusSlaveVector(15 downto 8);
   signal timingCode     : slv(7 downto 0);
   signal timingCodeEn   : sl;
   signal fbCode         : slv(7 downto 0);
   signal fbCodeEn       : sl;

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DpmCore: entity work.DpmCore 
      port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         ethRxP                   => ethRxP,
         ethRxM                   => ethRxM,
         ethTxP                   => ethTxP,
         ethTxM                   => ethTxM,
         locRefClkP               => locRefClkP,
         locRefClkM               => locRefClkM,
         locRefClk                => locRefClk,
         dtmRefClkP               => dtmRefClkP,
         dtmRefClkM               => dtmRefClkM,
         dtmRefClk                => dtmRefClk,
         axiClk                   => axiClk,
         axiClkRst                => axiClkRst,
         sysClk125                => sysClk125,
         sysClk125Rst             => sysClk125Rst,
         sysClk200                => sysClk200,
         sysClk200Rst             => sysClk200Rst,
         dtmClkP                  => dtmClkP,
         dtmClkM                  => dtmClkM,
         dtmClk                   => dtmClk,
         dtmFbP                   => dtmFbP,
         dtmFbM                   => dtmFbM,
         dtmFb                    => dtmFb,
         localBusMaster           => localBusMaster,
         localBusSlave            => localBusSlave,
         obPpiClk                 => obPpiClk,
         obPpiToFifo              => obPpiToFifo,
         obPpiFromFifo            => obPpiFromFifo,
         ibPpiClk                 => ibPpiClk,
         ibPpiToFifo              => ibPpiToFifo,
         ibPpiFromFifo            => ibPpiFromFifo,
         clkSelA                  => clkSelA,
         clkSelB                  => clkSelB
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
   U_DpmTiming : entity work.DpmTimingSink 
      generic map (
         TPD_G => 1 ns
      ) port map (
         axiClk                    => axiClk,
         axiClkRst                 => axiClkRst,
         localBusMaster            => localBusMaster(14),
         localBusSlave             => localBusSlave(14),
         dpmClk                    => dtmClk,
         dpmFb                     => dtmFb,
         sysClk200                 => sysClk200,
         sysClk200Rst              => sysClk200Rst,
         sysClk                    => open,
         sysClkRst                 => open,
         timingCode                => timingCode,
         timingCodeEn              => timingCodeEn,
         fbCode                    => fbCode,
         fbCodeEn                  => fbCodeEn,
         led                       => led
      );

   fbCode   <= timingCode;
   fbCodeEn <= timingCodeEn;


   --------------------------------------------------
   -- Unused Signals
   --------------------------------------------------

   --led <= "11";

   -- RTM High Speed
   --dpmToRtmHsP : out   slv(11 downto 0);
   --dpmToRtmHsM : out   slv(11 downto 0);
   --rtmToDpmHsP : in    slv(11 downto 0);
   --rtmToDpmHsM : in    slv(11 downto 0);

   -- Reference Clocks
   --locRefClk   : slv(1  downto 0);
   --dtmRefClk   : sl;


   -- Local bus
   --localBusMaster : LocalBusMasterVector(15 downto 8);
   localBusSlave(15)          <= LocalBusSlaveInit;
   localBusSlave(13 downto 8) <= (others=>LocalBusSlaveInit);

   -- Clocks
   --signal axiClk         : sl;
   --signal axiClkRst      : sl;
   --signal sysClk125      : sl;
   --signal sysClk125Rst   : sl;
   --signal sysClk200      : sl;
   --signal sysClk200Rst   : sl;

end architecture STRUCTURE;
