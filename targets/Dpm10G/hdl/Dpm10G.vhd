-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Dpm10G.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-10-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: PPI 10GbE + PGP 
-------------------------------------------------------------------------------
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Gtx7CfgPkg.all;
use work.Pgp2bPkg.all;
use work.EthMacPkg.all;

entity Dpm10G is
   generic (
      TPD_G           : time                  := 1 ns;
      PGP_LANES_G     : integer range 1 to 12 := 12;
      PGP_LINE_RATE_G : real                  := 3.125E9);
   port (
      -- Debug
      led         : out   slv(1 downto 0);
      -- I2C
      i2cSda      : inout sl;
      i2cScl      : inout sl;
      -- Ethernet
      ethRxP      : in    slv(3 downto 0);
      ethRxM      : in    slv(3 downto 0);
      ethTxP      : out   slv(3 downto 0);
      ethTxM      : out   slv(3 downto 0);
      ethRefClkP  : in    sl;
      ethRefClkM  : in    sl;
      -- RTM High Speed
      dpmToRtmHsP : out   slv(PGP_LANES_G-1 downto 0);
      dpmToRtmHsM : out   slv(PGP_LANES_G-1 downto 0);
      rtmToDpmHsP : in    slv(PGP_LANES_G-1 downto 0);
      rtmToDpmHsM : in    slv(PGP_LANES_G-1 downto 0);
      -- Reference Clocks
      locRefClkP  : in    sl;
      locRefClkM  : in    sl;
      dtmRefClkP  : in    sl;
      dtmRefClkM  : in    sl;
      -- DTM Signals
      dtmClkP     : in    slv(1 downto 0);
      dtmClkM     : in    slv(1 downto 0);
      dtmFbP      : out   sl;
      dtmFbM      : out   sl;
      -- Clock Select
      clkSelA     : out   slv(1 downto 0);
      clkSelB     : out   slv(1 downto 0));
end Dpm10G;

architecture STRUCTURE of Dpm10G is

   -- Constants
   constant AXIL_CLK_FREQ_C    : real            := 125.0E6;
   constant GTX_REFCLK_FREQ_C  : real            := 250.0E6;
   constant PGP_GTX_CPLL_CFG_C : Gtx7CPllCfgType := getGtx7CPllCfg(GTX_REFCLK_FREQ_C, PGP_LINE_RATE_G);

   signal locRefClk  : sl;
   signal locRefClkG : sl;

   -- DPM System clocks
   signal sysClk125    : sl;
   signal sysClk125Rst : sl;
   signal sysClk200    : sl;
   signal sysClk200Rst : sl;

   -- AXI-Lite
   signal axilClk            : sl;
   signal axilClkRst         : sl;
   signal extAxilReadMaster  : AxiLiteReadMasterType;
   signal extAxilReadSlave   : AxiLiteReadSlaveType;
   signal extAxilWriteMaster : AxiLiteWriteMasterType;
   signal extAxilWriteSlave  : AxiLiteWriteSlaveType;

   -- DMA
   signal dmaClk      : slv(2 downto 0);
   signal dmaClkRst   : slv(2 downto 0);
   signal dmaState    : RceDmaStateArray(2 downto 0);
   signal dmaObMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave  : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave  : AxiStreamSlaveArray(2 downto 0);

   -- PGP
   signal pgpClk           : sl;
   signal pgpClkRst        : sl;
   signal pgpTxIn          : Pgp2bTxInArray(PGP_LANES_G-1 downto 0);
   signal pgpTxOut         : Pgp2bTxOutArray(PGP_LANES_G-1 downto 0);
   signal pgpTxMasters     : AxiStreamQuadMasterArray(PGP_LANES_G-1 downto 0);
   signal pgpTxSlaves      : AxiStreamQuadSlaveArray(PGP_LANES_G-1 downto 0);
   signal pgpRxIn          : Pgp2bRxInArray(PGP_LANES_G-1 downto 0);
   signal pgpRxOut         : Pgp2bRxOutArray(PGP_LANES_G-1 downto 0);
   signal pgpRxMasterMuxed : AxiStreamMasterArray(PGP_LANES_G-1 downto 0);
   signal pgpRxCtrl        : AxiStreamQuadCtrlArray(PGP_LANES_G-1 downto 0);

   -- User loopback
   signal userEthObMaster : AxiStreamMasterType;
   signal userEthObSlave  : AxiStreamSlaveType;
   signal userEthIbMaster : AxiStreamMasterType;
   signal userEthIbSlave  : AxiStreamSlaveType;

begin

   -----------
   -- DPM Core
   -----------
   U_DpmCore : entity work.DpmCore
      generic map (
         TPD_G           => TPD_G,
         RCE_DMA_MODE_G  => RCE_DMA_PPI_C,
         OLD_BSI_MODE_G  => false,
         ETH_10G_EN_G    => true) 
      port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         ethRxP             => ethRxP,
         ethRxM             => ethRxM,
         ethTxP             => ethTxP,
         ethTxM             => ethTxM,
         ethRefClkP         => ethRefClkP,
         ethRefClkM         => ethRefClkM,
         clkSelA            => clkSelA,
         clkSelB            => clkSelB,
         sysClk125          => sysClk125,
         sysClk125Rst       => sysClk125Rst,
         sysClk200          => sysClk200,
         sysClk200Rst       => sysClk200Rst,
         axiClk             => axilClk,
         axiClkRst          => axilClkRst,
         extAxilReadMaster  => extAxilReadMaster,
         extAxilReadSlave   => extAxilReadSlave,
         extAxilWriteMaster => extAxilWriteMaster,
         extAxilWriteSlave  => extAxilWriteSlave,
         dmaClk             => dmaClk,
         dmaClkRst          => dmaClkRst,
         dmaState           => dmaState,
         dmaObMaster        => dmaObMaster,
         dmaObSlave         => dmaObSlave,
         dmaIbMaster        => dmaIbMaster,
         dmaIbSlave         => dmaIbSlave,
         userInterrupt      => (others => '0'));

   led <= (others => '0');

   -----------
   -- Clocking
   -----------
   -- DTM Clock Signals
   U_DtmClkgen : for i in 0 to 1 generate
      U_DtmClkIn : IBUFDS
         generic map (
            DIFF_TERM => true)
         port map(
            I  => dtmClkP(i),
            IB => dtmClkM(i),
            O  => open);
   end generate;

   -- DTM Feedback
   U_DtmFbOut : OBUFDS
      port map(
         O  => dtmFbP,
         OB => dtmFbM,
         I  => '0');

   -- locRefClk drives PGP
   U_LocRefClkIbufds : IBUFDS_GTE2
      port map (
         I     => locRefClkP,
         IB    => locRefClkM,
         CEB   => '0',
         O     => locRefClk,
         ODIV2 => open);

   U_LocRefClkBufg : BUFG
      port map (
         I => locRefClk,
         O => locRefClkG);

   ClockManager7_1 : entity work.ClockManager7
      generic map (
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 4.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 5.0,
         CLKOUT0_DIVIDE_G   => 8,
         CLKOUT0_RST_HOLD_G => 8)
      port map (
         clkIn     => locRefClkG,
         rstIn     => axilClkRst,
         clkOut(0) => pgpClk,
         rstOut(0) => pgpClkRst);

   dmaClk    <= (others => sysClk200);
   dmaClkRst <= (others => sysClk200Rst);

   -------------------
   -- PPI to PGP Array
   -------------------
   PpiPgpArray_1 : entity work.PpiPgpArray
      generic map (
         TPD_G                   => TPD_G,
         NUM_LANES_G             => PGP_LANES_G,
         AXIL_BASE_ADDRESS_G     => X"A0000000",
         AXIL_CLK_FREQ_G         => AXIL_CLK_FREQ_C,
         RX_AXIS_ADDR_WIDTH_G    => 10,
         RX_AXIS_PAUSE_THRESH_G  => 500,
         RX_AXIS_CASCADE_SIZE_G  => 1,
         RX_DATA_ADDR_WIDTH_G    => 12,
         RX_HEADER_ADDR_WIDTH_G  => 9,
         RX_PPI_MAX_FRAME_SIZE_G => 2048,
         TX_PPI_ADDR_WIDTH_G     => 9,
         TX_AXIS_ADDR_WIDTH_G    => 9,
         TX_AXIS_CASCADE_SIZE_G  => 1)
      port map (
         ppiClk           => dmaClk(0),
         ppiClkRst        => dmaClkRst(0),
         ppiState         => dmaState(0),
         ppiIbMaster      => dmaIbMaster(0),
         ppiIbSlave       => dmaIbSlave(0),
         ppiObMaster      => dmaObMaster(0),
         ppiObSlave       => dmaObSlave(0),
         pgpTxClk         => (others => pgpClk),
         pgpTxClkRst      => (others => pgpClkRst),
         pgpTxIn          => pgpTxIn,
         pgpTxOut         => pgpTxOut,
         pgpTxMasters     => pgpTxMasters,
         pgpTxSlaves      => pgpTxSlaves,
         pgpRxClk         => (others => pgpClk),
         pgpRxClkRst      => (others => pgpClkRst),
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => pgpRxOut,
         pgpRxMasterMuxed => pgpRxMasterMuxed,
         pgpRxCtrl        => pgpRxCtrl,
         axilClk          => axilClk,
         axilClkRst       => axilClkRst,
         axilWriteMaster  => extAxilWriteMaster,
         axilWriteSlave   => extAxilWriteSlave,
         axilReadMaster   => extAxilReadMaster,
         axilReadSlave    => extAxilReadSlave);

   ----------------
   -- PGP GTX Array
   ----------------
   PGP_GTX_GEN : for i in PGP_LANES_G-1 downto 0 generate
      Pgp2bGtx7VarLat_1 : entity work.Pgp2bGtx7VarLat
         generic map (
            TPD_G                 => TPD_G,
            STABLE_CLOCK_PERIOD_G => 4.0E-9,
            CPLL_REFCLK_SEL_G     => "001",
            CPLL_FBDIV_G          => PGP_GTX_CPLL_CFG_C.CPLL_FBDIV_G,
            CPLL_FBDIV_45_G       => PGP_GTX_CPLL_CFG_C.CPLL_FBDIV_45_G,
            CPLL_REFCLK_DIV_G     => PGP_GTX_CPLL_CFG_C.CPLL_REFCLK_DIV_G,
            RXOUT_DIV_G           => PGP_GTX_CPLL_CFG_C.OUT_DIV_G,
            TXOUT_DIV_G           => PGP_GTX_CPLL_CFG_C.OUT_DIV_G,
            RX_CLK25_DIV_G        => PGP_GTX_CPLL_CFG_C.CLK25_DIV_G,
            TX_CLK25_DIV_G        => PGP_GTX_CPLL_CFG_C.CLK25_DIV_G,
--            PMA_RSV_G             => PMA_RSV_G,
--            RX_OS_CFG_G           => RX_OS_CFG_G,
--            RXCDR_CFG_G           => RXCDR_CFG_G,
--            RXDFEXYDEN_G          => RXDFEXYDEN_G,
--            RX_DFE_KL_CFG2_G      => RX_DFE_KL_CFG2_G,
            TX_PLL_G              => "CPLL",
            RX_PLL_G              => "CPLL",
            PAYLOAD_CNT_TOP_G     => 7,
            VC_INTERLEAVE_G       => 1,
            NUM_VC_EN_G           => 4)
         port map (
            stableClk        => sysClk125,
            gtCPllRefClk     => locRefClk,
            gtCPllLock       => open,
            gtQPllRefClk     => '0',
            gtQPllClk        => '0',
            gtQPllLock       => '0',
            gtQPllRefClkLost => '0',
            gtQPllReset      => open,
            gtTxP            => dpmToRtmHsP(i),
            gtTxN            => dpmToRtmHsM(i),
            gtRxP            => rtmToDpmHsP(i),
            gtRxN            => rtmToDpmHsM(i),
            pgpTxReset       => pgpClkRst,
            pgpTxClk         => pgpClk,
            pgpTxRecClk      => open,
            pgpTxMmcmReset   => open,
            pgpTxMmcmLocked  => '1',
            pgpRxReset       => pgpClkRst,
            pgpRxRecClk      => open,
            pgpRxClk         => pgpClk,
            pgpRxMmcmReset   => open,
            pgpRxMmcmLocked  => '1',
            pgpRxIn          => pgpRxIn(i),
            pgpRxOut         => pgpRxOut(i),
            pgpTxIn          => pgpTxIn(i),
            pgpTxOut         => pgpTxOut(i),
            pgpTxMasters     => pgpTxMasters(i),
            pgpTxSlaves      => pgpTxSlaves(i),
            pgpRxMasters     => open,
            pgpRxMasterMuxed => pgpRxMasterMuxed(i),
            pgpRxCtrl        => pgpRxCtrl(i));
   end generate PGP_GTX_GEN;

   -------------------------
   -- User Ethernet loopback
   -------------------------
   userEthIbMaster <= userEthObMaster;
   userEthObSlave  <= userEthIbSlave;

end architecture STRUCTURE;
