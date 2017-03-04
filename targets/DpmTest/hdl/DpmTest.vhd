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
-- DpmTest.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity DpmTest is
   generic (
      BUILD_INFO_G   : BuildInfoType
   );
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
end DpmTest;

architecture STRUCTURE of DpmTest is

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
   signal locAxilReadMaster  : AxiLiteReadMasterArray(9 downto 0);
   signal locAxilReadSlave   : AxiLiteReadSlaveArray(9 downto 0);
   signal locAxilWriteMaster : AxiLiteWriteMasterArray(9 downto 0);
   signal locAxilWriteSlave  : AxiLiteWriteSlaveArray(9 downto 0);
   signal dmaClk             : slv(2 downto 0);
   signal dmaClkRst          : slv(2 downto 0);
   signal dmaState           : RceDmaStateArray(2 downto 0);
   signal dmaObMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave         : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave         : AxiStreamSlaveArray(2 downto 0);
   signal prbsAxisMaster     : AxiStreamMasterArray(7 downto 0);
   signal prbsAxisSlave      : AxiStreamSlaveArray(7 downto 0);
   signal iethRxP            : slv(3 downto 0);
   signal iethRxM            : slv(3 downto 0);
   signal iethTxP            : slv(3 downto 0);
   signal iethTxM            : slv(3 downto 0);
   signal timingCode         : slv(7 downto 0);
   signal timingCodeEn       : sl;
   signal fbCode             : slv(7 downto 0);
   signal fbCodeEn           : sl;
   signal userInterrupt      : slv(USER_INT_COUNT_C-1 downto 0);

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DpmCore: entity work.DpmCore 
      generic map (
         TPD_G          => TPD_C,
         BUILD_INFO_G   => BUILD_INFO_G,
         RCE_DMA_MODE_G => RCE_DMA_AXISV2_C,
         --RCE_DMA_MODE_G => RCE_DMA_AXIS_C,
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
         dmaState                 => dmaState,
         dmaObMaster              => dmaObMaster,
         dmaObSlave               => dmaObSlave,
         dmaIbMaster              => dmaIbMaster,
         dmaIbSlave               => dmaIbSlave,
         userInterrupt            => userInterrupt
      );

   ethTxP(0)           <= iethTxP(0);
   ethTxM(0)           <= iethTxM(0);
   iethRxP(0)          <= ethRxP(0);
   iethRxM(0)          <= ethRxM(0);
   iethRxP(3 downto 1) <= (others=>'0');
   iethRxM(3 downto 1) <= (others=>'0');
   userInterrupt       <= (others=>'0');


   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xA0000000 - 0xAFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 10,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            0 => ( baseAddr     => x"A0000000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            1 => ( baseAddr     => x"A0010000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            2 => ( baseAddr     => x"A0020000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            3 => ( baseAddr     => x"A0030000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            4 => ( baseAddr     => x"A0040000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            5 => ( baseAddr     => x"A0050000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            6 => ( baseAddr     => x"A0060000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            7 => ( baseAddr     => x"A0070000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            8 => ( baseAddr     => x"A0080000",
                   addrBits     => 16,
                   connectivity => x"FFFF"),

            9 => ( baseAddr     => x"A0090000",
                   addrBits     => 16,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => extAxilWriteMaster,
         sAxiWriteSlaves(0)  => extAxilWriteSlave,
         sAxiReadMasters(0)  => extAxilReadMaster,
         sAxiReadSlaves(0)   => extAxilReadSlave,
         mAxiWriteMasters    => locAxilWriteMaster,
         mAxiWriteSlaves     => locAxilWriteSlave,
         mAxiReadMasters     => locAxilReadMaster,
         mAxiReadSlaves      => locAxilReadSlave
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk      <= (others=>sysClk200);
   dmaClkRst   <= (others=>sysClk200Rst);
   dmaIbMaster(2 downto 1) <= dmaObMaster(2 downto 1);
   dmaObSlave(2 downto 1)  <= dmaIbSlave(2 downto 1);
   dmaObSlave(0)           <= AXI_STREAM_SLAVE_FORCE_C;

   U_PrbsGen: for i in 0 to 7 generate
      U_Prbs: entity work.SsiPrbsTx
         generic map (
            AXI_ERROR_RESP_G           => AXI_RESP_OK_C,
            GEN_SYNC_FIFO_G            => false,
            VALID_THOLD_G              => 128,
            MASTER_AXI_STREAM_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C)
         port map (
            -- Master Port (mAxisClk)
            mAxisClk        => sysClk200,
            mAxisRst        => sysClk200Rst,
            mAxisMaster     => prbsAxisMaster(i),
            mAxisSlave      => prbsAxisSlave(i),
            locClk          => axiClk,
            locRst          => axiClkRst,
            trig            => '0',
            packetLength    => X"00000100",
            axilReadMaster  => locAxilReadMaster(2+i),
            axilReadSlave   => locAxilReadSlave(2+i),
            axilWriteMaster => locAxilWriteMaster(2+i),
            axilWriteSlave  => locAxilWriteSlave(2+i));
   end generate;

   U_PrbsMux: entity work.AxiStreamMux
      generic map (
         NUM_SLAVES_G   => 8,
         MODE_G         => "INDEXED",
         TDEST_LOW_G    => 0,
         ILEAVE_EN_G    => true,
         ILEAVE_REARB_G => 128)
      port map (
         axisClk      => sysClk200,
         axisRst      => sysClk200Rst,
         sAxisMasters => prbsAxisMaster,
         sAxisSlaves  => prbsAxisSlave,
         mAxisMaster  => dmaIbMaster(0),
         mAxisSlave   => dmaIbSlave(0));

   --------------------------------------------------
   -- Timing Signals
   --------------------------------------------------
   U_DpmTimingSink : entity work.DpmTimingSink 
      generic map (
         TPD_G => TPD_C
      ) port map (
         axiClk         => axiClk,
         axiClkRst      => axiClkRst,
         axiReadMaster  => locAxilReadMaster(0),
         axiReadSlave   => locAxilReadSlave(0),
         axiWriteMaster => locAxilWriteMaster(0),
         axiWriteSlave  => locAxilWriteSlave(0),
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
         topAxiReadMaster    => locAxilReadMaster(1),
         topAxiReadSlave     => locAxilReadSlave(1),
         topAxiWriteMaster   => locAxilWriteMaster(1),
         topAxiWriteSlave    => locAxilWriteSlave(1),
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
