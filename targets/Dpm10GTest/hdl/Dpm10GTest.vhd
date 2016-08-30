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
-- Dpm10GTest.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity Dpm10GTest is
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
      dpmToRtmHsP  : out   slv(0 downto 0);
      dpmToRtmHsM  : out   slv(0 downto 0);
      rtmToDpmHsP  : in    slv(0 downto 0);
      rtmToDpmHsM  : in    slv(0 downto 0);

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
end Dpm10GTest;

architecture STRUCTURE of Dpm10GTest is

   constant TPD_C : time := 1 ns;

   constant MAC_ADDR_C : slv(47 downto 0) := x"010300564400";  -- 00:44:56:00:03:01

   -- Local Signals
   signal axiClk              : sl;
   signal axiClkRst           : sl;
   signal sysClk125           : sl;
   signal sysClk125Rst        : sl;
   signal sysClk200           : sl;
   signal sysClk200Rst        : sl;
   signal extAxilReadMaster   : AxiLiteReadMasterType;
   signal extAxilReadSlave    : AxiLiteReadSlaveType;
   signal extAxilWriteMaster  : AxiLiteWriteMasterType;
   signal extAxilWriteSlave   : AxiLiteWriteSlaveType;
   signal dmaClk              : slv(2 downto 0);
   signal dmaClkRst           : slv(2 downto 0);
   signal dmaState            : RceDmaStateArray(2 downto 0);
   signal dmaObMaster         : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave          : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster         : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave          : AxiStreamSlaveArray(2 downto 0);
   signal iethRxP             : slv(3 downto 0);
   signal iethRxM             : slv(3 downto 0);
   signal iethTxP             : slv(3 downto 0);
   signal iethTxM             : slv(3 downto 0);
   signal phyClk              : sl;
   signal phyRst              : sl;
   signal muxAxilReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal muxAxilReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal muxAxilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal muxAxilWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);
   signal readRegisters       : Slv32Array(1 downto 0);
   signal clkFreq             : slv(31 downto 0);
   signal clkLocked           : sl;
   signal clkFast             : sl;
   signal clkSlow             : sl;

   constant AXIS_CONFIG_C  : AxiStreamConfigArray(3 downto 0) := (others => RCEG3_AXIS_DMA_CONFIG_C);

   attribute dont_touch : string;

   attribute dont_touch of axiClk             : signal is "true"; 
   attribute dont_touch of axiClkRst          : signal is "true"; 
   attribute dont_touch of sysClk125          : signal is "true"; 
   attribute dont_touch of sysClk125Rst       : signal is "true"; 
   attribute dont_touch of sysClk200          : signal is "true"; 
   attribute dont_touch of sysClk200Rst       : signal is "true"; 
   attribute dont_touch of extAxilReadMaster  : signal is "true"; 
   attribute dont_touch of extAxilReadSlave   : signal is "true"; 
   attribute dont_touch of extAxilWriteMaster : signal is "true"; 
   attribute dont_touch of extAxilWriteSlave  : signal is "true"; 
   attribute dont_touch of dmaClk             : signal is "true"; 
   attribute dont_touch of dmaClkRst          : signal is "true"; 
   attribute dont_touch of dmaState           : signal is "true"; 
   attribute dont_touch of dmaObMaster        : signal is "true"; 
   attribute dont_touch of dmaObSlave         : signal is "true"; 
   attribute dont_touch of dmaIbMaster        : signal is "true"; 
   attribute dont_touch of dmaIbSlave         : signal is "true"; 
   attribute dont_touch of iethRxP            : signal is "true"; 
   attribute dont_touch of iethRxM            : signal is "true"; 
   attribute dont_touch of iethTxP            : signal is "true"; 
   attribute dont_touch of iethTxM            : signal is "true"; 

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray := genAxiLiteConfig(2, x"A0000000", 16, 12);

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DpmCore: entity work.DpmCore 
      generic map (
         TPD_G          => TPD_C,
         RCE_DMA_MODE_G => RCE_DMA_AXIS_C,
         ETH_10G_EN_G   => false
      ) port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         ethRxP                   => iethRxP,
         ethRxM                   => iethRxM,
         ethTxP                   => iethTxP,
         ethTxM                   => iethTxM,
         --ethRefClkP               => ethRefClkP,
         --ethRefClkM               => ethRefClkM,
         ethRefClkP               => '0',
         ethRefClkM               => '1',
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
         userInterrupt            => (others=>'0')
      );

   ethTxP(0)           <= iethTxP(0);
   ethTxM(0)           <= iethTxM(0);
   iethRxP(0)          <= ethRxP(0);
   iethRxM(0)          <= ethRxM(0);
   iethRxP(3 downto 1) <= (others=>'0');
   iethRxM(3 downto 1) <= (others=>'0');

   U_Cb : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 2,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => extAxilWriteMaster,
         sAxiWriteSlaves(0)  => extAxilWriteSlave,
         sAxiReadMasters(0)  => extAxilReadMaster,
         sAxiReadSlaves(0)   => extAxilReadSlave,
         mAxiWriteMasters    => muxAxilWriteMasters,
         mAxiWriteSlaves     => muxAxilWriteSlaves,
         mAxiReadMasters     => muxAxilReadMasters,
         mAxiReadSlaves      => muxAxilReadSlaves);

   -- Empty AXI Slave
   U_AxiLiteEmpty: entity work.AxiLiteEmpty 
      generic map (
         NUM_READ_REG_G  => 2
      ) port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         axiReadMaster   => muxAxilReadMasters(1),
         axiReadSlave    => muxAxilReadSlaves(1),
         axiWriteMaster  => muxAxilWriteMasters(1),
         axiWriteSlave   => muxAxilWriteSlaves(1),
         readRegister    => readRegisters
      );

   U_Freq: entity work.SyncClockFreq 
      generic map (
         TPD_G             => TPD_C,
         REF_CLK_FREQ_G    => 200.0E+6,
         CLK_LOWER_LIMIT_G => 150.0E+6,
         CLK_UPPER_LIMIT_G => 161.0E+6
      ) port map (
         freqOut     => clkFreq,
         freqUpdated => open,
         locked      => clkLocked,
         tooFast     => clkFast,
         tooSlow     => clkSlow,
         clkIn       => phyClk,
         locClk      => axiClk,
         refClk      => sysClk200
      );

   readRegisters(0)    <= clkFreq;
   readRegisters(1)(0) <= clkLocked;
   readRegisters(1)(1) <= clkFast;
   readRegisters(1)(2) <= clkSlow;
   readRegisters(1)(3) <= phyRst;
   readRegisters(1)(4) <= sysClk200Rst;
   readRegisters(1)(27 downto  5) <= (others=>'0');
   readRegisters(1)(31 downto 28) <= x"A";

   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk(0)      <= sysClk125;
   dmaClkRst(0)   <= sysClk125Rst;
   --dmaIbMaster(0) <= dmaObMaster(0);
   --dmaObSlave(0)  <= dmaIbSlave(0);
   dmaIbMaster(0) <= AXI_STREAM_MASTER_INIT_C;
   dmaObSlave(0)  <= AXI_STREAM_SLAVE_INIT_C;

   dmaClk(1)      <= phyClk;
   dmaClkRst(1)   <= phyRst;

   dmaClk(2)      <= sysClk125;
   dmaClkRst(2)   <= sysClk125Rst;
   dmaIbMaster(2) <= AXI_STREAM_MASTER_INIT_C;
   dmaObSlave(2)  <= AXI_STREAM_SLAVE_INIT_C;
   --dmaIbMaster(2) <= dmaObMaster(2);
   --dmaObSlave(2)  <= dmaIbSlave(2);

   --------------------------------------------------
   -- ETH Test Block
   --------------------------------------------------
   U_10GigE : entity work.TenGigEthGtx7Wrapper
      generic map (
         TPD_G             => 1 ns,
         -- DMA/MAC Configurations
         NUM_LANE_G        => 1,
         -- QUAD PLL Configurations
         REFCLK_DIV2_G     => false,   -- TRUE: gtClkP/N = 312.5 MHz
         --QPLL_REFCLK_SEL_G => "011", -- North
         --QPLL_REFCLK_SEL_G => "101", -- South
         -- AXI Streaming Configurations
         AXIS_CONFIG_G     => AXIS_CONFIG_C
      ) port map (
         -- Local Configurations
         localMac(0)  => MAC_ADDR_C,
         -- Streaming DMA Interface 
         dmaClk(0)       => phyClk,
         dmaRst(0)       => phyRst,
         dmaIbMasters(0) => dmaIbMaster(1),
         dmaIbSlaves(0)  => dmaIbSlave(1),
         dmaObMasters(0) => dmaObMaster(1),
         dmaObSlaves(0)  => dmaObSlave(1),
         -- Slave AXI-Lite Interface 
         axiLiteClk(0)          => axiClk,
         axiLiteRst(0)          => axiClkRst,
         axiLiteReadMasters(0)  => muxAxilReadMasters(0),
         axiLiteReadSlaves(0)   => muxAxilReadSlaves(0),
         axiLiteWriteMasters(0) => muxAxilWriteMasters(0),
         axiLiteWriteSlaves(0)  => muxAxilWriteSlaves(0),
         -- Misc. Signals
         extRst       => sysClk200Rst,
         phyClk       => phyClk,
         phyRst       => phyRst,
         phyReady(0)  => open,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP       => ethRefClkP,
         gtClkN       => ethRefClkM,
         -- MGT Ports
         gtTxP(0)     => dpmToRtmHsP(0),
         gtTxN(0)     => dpmToRtmHsM(0),
         gtRxP(0)     => rtmToDpmHsP(0),
         gtRxN(0)     => rtmToDpmHsM(0));

   --------------------------------------------------
   -- Top Level Signals
   --------------------------------------------------
   led <= (others=>'0');

   -- RTM High Speed
   --dpmToRtmHsP : out   slv(11 downto 0);
   --dpmToRtmHsM : out   slv(11 downto 0);
   --rtmToDpmHsP : in    slv(11 downto 0);
   --rtmToDpmHsM : in    slv(11 downto 0);

   -- Reference Clocks
   --locRefClkP   : in    sl;
   --locRefClkM   : in    sl;
   --dtmRefClkP   : in    sl;
   --dtmRefClkM   : in    sl;

   -- DTM Clock Signals
   U_DtmClkgen : for i in 0 to 1 generate
      U_DtmClkIn : IBUFDS
         generic map ( DIFF_TERM => true ) 
         port map(
            I      => dtmClkP(i),
            IB     => dtmClkM(i),
            O      => open
         );
   end generate;

   -- DTM Feedback
   U_DtmFbOut : OBUFDS
      port map(
         O      => dtmFbP,
         OB     => dtmFbM,
         I      => '0'
      );

end architecture STRUCTURE;

