-------------------------------------------------------------------------------
-- DpmEmpty.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity DpmEmpty is
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
      ethRefClkP   : in    sl;
      ethRefClkM   : in    sl;

      -- RTM High Speed
      dpmToRtmHsP  : out   slv(11 downto 0);
      dpmToRtmHsM  : out   slv(11 downto 0);
      rtmToDpmHsP  : in    slv(11 downto 0);
      rtmToDpmHsM  : in    slv(11 downto 0);

      -- Reference Clocks
      locRefClkP   : in    sl;
      locRefClkM   : in    sl;
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
end DpmEmpty;

architecture STRUCTURE of DpmEmpty is

   constant TPD_C : time := 1 ns;

   -- Local Signals
   signal axiClk             : sl;
   signal axiClkRst          : sl;
   signal sysClk125          : sl;
   signal sysClk125Rst       : sl;
   signal sysClk200          : sl;
   signal sysClk200Rst       : sl;
   signal extAxilReadMaster  : AxiLiteReadMasterType;
   signal extAxilReadSlave   : AxiLiteReadSlaveType;
   signal extAxilWriteMaster : AxiLiteWriteMasterType;
   signal extAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal pgpAxilReadMaster  : AxiLiteReadMasterType;
   signal pgpAxilReadSlave   : AxiLiteReadSlaveType;
   signal pgpAxilWriteMaster : AxiLiteWriteMasterType;
   signal pgpAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal clkAxilReadMaster  : AxiLiteReadMasterType;
   signal clkAxilReadSlave   : AxiLiteReadSlaveType;
   signal clkAxilWriteMaster : AxiLiteWriteMasterType;
   signal clkAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal dmaClk             : slv(2 downto 0);
   signal dmaClkRst          : slv(2 downto 0);
   signal dmaOnline          : slv(2 downto 0);
   signal dmaEnable          : slv(2 downto 0);
   signal dmaObMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave         : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave         : AxiStreamSlaveArray(2 downto 0);
   signal iethRxP            : slv(3 downto 0);
   signal iethRxM            : slv(3 downto 0);
   signal iethTxP            : slv(3 downto 0);
   signal iethTxM            : slv(3 downto 0);
   signal timingCode         : slv(7 downto 0);
   signal timingCodeEn       : sl;
   signal fbCode             : slv(7 downto 0);
   signal fbCodeEn           : sl;

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DpmCore: entity work.DpmCore 
      generic map (
         TPD_G          => TPD_C,
         RCE_DMA_MODE_G => RCE_DMA_PPI_C,
         ETH_10G_EN_G   => false
      ) port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         ethRxP                   => iethRxP,
         ethRxM                   => iethRxM,
         ethTxP                   => iethTxP,
         ethTxM                   => iethTxM,
         ethRefClkP               => ethRefClkP,
         ethRefClkM               => ethRefClkM,
         clkSelA                  => clkSelA,
         clkSelB                  => clkSelB,
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
         dmaOnline                => dmaOnline,
         dmaEnable                => dmaEnable,
         dmaObMaster              => dmaObMaster,
         dmaObSlave               => dmaObSlave,
         dmaIbMaster              => dmaIbMaster,
         dmaIbSlave               => dmaIbSlave
      );

   ethTxP(0)           <= iethTxP(0);
   ethTxM(0)           <= iethTxM(0);
   iethRxP(0)          <= ethRxP(0);
   iethRxM(0)          <= ethRxM(0);
   iethRxP(3 downto 1) <= (others=>'0');
   iethRxM(3 downto 1) <= (others=>'0');


   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xA0000000 - 0xAFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 2,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- Channel 0 = 0xA0000000 - 0xA000FFFF : DPM Timing Source
            0 => ( baseAddr     => x"A0000000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            -- Channel 1 = 0xA0001000 - 0xA001FFFF : PGP Test
            1 => ( baseAddr     => x"A0010000",
                   addrBits     => 16,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => extAxiWriteMaster,
         sAxiWriteSlaves(0)  => extAxiWriteSlave,
         sAxiReadMasters(0)  => extAxiReadMaster,
         sAxiReadSlaves(0)   => extAxiReadSlave,
         mAxiWriteMasters(0) => clkAxiWriteMaster,
         mAxiWriteSlaves(0)  => clkAxiWriteSlave,
         mAxiReadMasters(0)  => clkAxiReadMaster,
         mAxiReadSlaves(0)   => clkAxiReadSlave
         mAxiWriteMasters(1) => pgpAxiWriteMaster,
         mAxiWriteSlaves(1)  => pgpAxiWriteSlave,
         mAxiReadMasters(1)  => pgpAxiReadMaster,
         mAxiReadSlaves(1)   => pgpAxiReadSlave
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk      <= (others=>sysClk125);
   dmaClkRst   <= (others=>sysClk125Rst);
   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;


   --------------------------------------------------
   -- Timing Signals
   --------------------------------------------------
   U_DpmTimingSink : entity work.DpmTimingSink 
      generic map (
         TPD_G => TPD_C
      ) port map (
         axiClk         => axiClk,
         axiClkRst      => axiClkRst,
         axiReadMaster  => clkAxiReadMaster,
         axiReadSlave   => clkAxiReadSlave,
         axiWriteMaster => clkAxiWriteMaster,
         axiWriteSlave  => clkAxiWriteSlave,
         sysClk200      => sysClk200,
         sysClk200Rst   => sysClk200Rst,
         dtmClkP        => dtmClkP,
         dtmClkM        => dtmClkM,
         dtmFbP         => dtmFbP,
         dtmFbM         => dtmFbM,
         distClk        => open,
         distClkRst     => open,
         timingCode     => timingCode,
         timingCodeEn   => timingCodeEn,
         fbCode         => fbCode,
         fbCodeEn       => fbCodeEn,
         led            => led
      );

   fbCode   <= timingCode;
   fbCodeEn <= timingCodeEn;


   --------------------------------------------------
   -- RTM Testing
   --------------------------------------------------
   U_RtmTest : entity work.DpmRtmTest 
      generic map (
         TPD_G => TPD_C
      ) port map (
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         topAxiReadMaster    => pgpAxiReadMaster,
         topAxiReadSlave     => pgpAxiReadSlave,
         topAxiWriteMaster   => pgpAxiWriteMaster,
         topAxiWriteSlave    => pgpAxiWriteSlave,
         locRefClkP          => locRefClkP,
         locRefClkM          => locRefClkM,
         dpmToRtmHsP         => dpmToRtmHsP,
         dpmToRtmHsM         => dpmToRtmHsM,
         rtmToDpmHsP         => rtmToDpmHsP,
         rtmToDpmHsM         => rtmToDpmHsM
      );


   --------------------------------------------------
   -- Top Level Signals
   --------------------------------------------------

   -- Reference Clocks
   --dtmRefClkP   : in    sl;
   --dtmRefClkM   : in    sl;

end architecture STRUCTURE;

