-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Dpm10G.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2016-11-03
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
      BUILD_INFO_G    : BuildInfoType;
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
   constant AXIL_CLK_FREQ_C    : real                                         := 125.0E6;
   constant GTX_REFCLK_FREQ_C  : real                                         := 250.0E6;
   constant PGP_GTX_CPLL_CFG_C : Gtx7CPllCfgType                              := getGtx7CPllCfg(GTX_REFCLK_FREQ_C, PGP_LINE_RATE_G);
   constant XBAR_CONFIG_C      : AxiLiteCrossbarMasterConfigArray(2 downto 0) := genAxiLiteConfig(3, X"A0000000", 28, 16);

   signal locRefClk  : sl;
   signal locRefClkG : sl;

   -- DPM System clocks
   signal sysClk125    : sl;
   signal sysClk125Rst : sl;
   signal sysClk200    : sl;
   signal sysClk200Rst : sl;

   -- AXI-Lite
   signal axilClk             : sl;
   signal axilClkRst          : sl;
   signal extAxilReadMaster   : AxiLiteReadMasterType;
   signal extAxilReadSlave    : AxiLiteReadSlaveType;
   signal extAxilWriteMaster  : AxiLiteWriteMasterType;
   signal extAxilWriteSlave   : AxiLiteWriteSlaveType;
   signal extAxilReadMasters  : AxiLiteReadMasterArray(2 downto 0);
   signal extAxilReadSlaves   : AxiLiteReadSlaveArray(2 downto 0);
   signal extAxilWriteMasters : AxiLiteWriteMasterArray(2 downto 0);
   signal extAxilWriteSlaves  : AxiLiteWriteSlaveArray(2 downto 0);

   -- DMA
   signal dmaClk      : slv(2 downto 0);
   signal dmaClkRst   : slv(2 downto 0);
   signal dmaState    : RceDmaStateArray(2 downto 0);
   signal dmaObMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave  : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave  : AxiStreamSlaveArray(2 downto 0);

   -- PGP
   signal pgpClk    : sl;
   signal pgpClkRst : sl;

   signal pgpTxIn          : Pgp2bTxInArray(PGP_LANES_G-1 downto 0);
   signal pgpTxOut         : Pgp2bTxOutArray(PGP_LANES_G-1 downto 0);
   signal pgpTxMasters     : AxiStreamQuadMasterArray(PGP_LANES_G-1 downto 0);
   signal pgpTxSlaves      : AxiStreamQuadSlaveArray(PGP_LANES_G-1 downto 0);
   signal pgpRxIn          : Pgp2bRxInArray(PGP_LANES_G-1 downto 0);
   signal pgpRxOut         : Pgp2bRxOutArray(PGP_LANES_G-1 downto 0);
   signal pgpRxMasterMuxed : AxiStreamMasterArray(PGP_LANES_G-1 downto 0);
   signal pgpRxCtrl        : AxiStreamQuadCtrlArray(PGP_LANES_G-1 downto 0);

   signal intPgpTxIn          : Pgp2bTxInArray(PGP_LANES_G-1 downto 0);
   signal intPgpTxOut         : Pgp2bTxOutArray(PGP_LANES_G-1 downto 0);
   signal intPgpTxMasters     : AxiStreamQuadMasterArray(PGP_LANES_G-1 downto 0);
   signal intPgpTxSlaves      : AxiStreamQuadSlaveArray(PGP_LANES_G-1 downto 0);
   signal intPgpRxIn          : Pgp2bRxInArray(PGP_LANES_G-1 downto 0);
   signal intPgpRxOut         : Pgp2bRxOutArray(PGP_LANES_G-1 downto 0);
   signal intPgpRxMasterMuxed : AxiStreamMasterArray(PGP_LANES_G-1 downto 0);
   signal intPgpRxCtrl        : AxiStreamQuadCtrlArray(PGP_LANES_G-1 downto 0);

begin

   -----------
   -- DPM Core
   -----------
   U_DpmCore : entity work.DpmCore
      generic map (
         TPD_G          => TPD_G,
         BUILD_INFO_G   => BUILD_INFO_G,
         RCE_DMA_MODE_G => RCE_DMA_PPI_C,
         OLD_BSI_MODE_G => false,
         ETH_10G_EN_G   => true) 
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
         dmaIbSlave         => dmaIbSlave);

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

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 3,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilClkRst,
         sAxiWriteMasters(0) => extAxilWriteMaster,
         sAxiWriteSlaves(0)  => extAxilWriteSlave,
         sAxiReadMasters(0)  => extAxilReadMaster,
         sAxiReadSlaves(0)   => extAxilReadSlave,
         mAxiWriteMasters    => extAxilWriteMasters,
         mAxiWriteSlaves     => extAxilWriteSlaves,
         mAxiReadMasters     => extAxilReadMasters,
         mAxiReadSlaves      => extAxilReadSlaves);     

   -------------------
   -- PPI to PGP Array
   -------------------
   PPI_PGP_GEN : for i in 2 downto 0 generate
      U_PpiPgpArray : entity work.PpiPgpArray
         generic map (
            TPD_G                   => TPD_G,
            NUM_LANES_G             => 4,
            AXIL_BASE_ADDRESS_G     => XBAR_CONFIG_C(i).baseAddr,
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
            ppiClk           => dmaClk(i),
            ppiClkRst        => dmaClkRst(i),
            ppiState         => dmaState(i),
            ppiIbMaster      => dmaIbMaster(i),
            ppiIbSlave       => dmaIbSlave(i),
            ppiObMaster      => dmaObMaster(i),
            ppiObSlave       => dmaObSlave(i),
            pgpTxClk         => (others => pgpClk),
            pgpTxClkRst      => (others => pgpClkRst),
            pgpTxIn          => pgpTxIn(3+(4*i) downto (4*i)),
            pgpTxOut         => pgpTxOut(3+(4*i) downto (4*i)),
            pgpTxMasters     => pgpTxMasters(3+(4*i) downto (4*i)),
            pgpTxSlaves      => pgpTxSlaves(3+(4*i) downto (4*i)),
            pgpRxClk         => (others => pgpClk),
            pgpRxClkRst      => (others => pgpClkRst),
            pgpRxIn          => pgpRxIn(3+(4*i) downto (4*i)),
            pgpRxOut         => pgpRxOut(3+(4*i) downto (4*i)),
            pgpRxMasterMuxed => pgpRxMasterMuxed(3+(4*i) downto (4*i)),
            pgpRxCtrl        => pgpRxCtrl(3+(4*i) downto (4*i)),
            axilClk          => axilClk,
            axilClkRst       => axilClkRst,
            axilWriteMaster  => extAxilWriteMasters(i),
            axilWriteSlave   => extAxilWriteSlaves(i),
            axilReadMaster   => extAxilReadMasters(i),
            axilReadSlave    => extAxilReadSlaves(i));
   end generate PPI_PGP_GEN;

   -- NATURAL_ORDER : for i in PGP_LANES_G-1 downto 0 generate
   -- ---------------------------------
   -- -- Natural PGP Lane Mapping Order
   -- ---------------------------------
   -- intPgpTxIn(i)       <= pgpTxIn(i);
   -- pgpTxOut(i)         <= intPgpTxOut(i);
   -- intPgpTxMasters(i)  <= pgpTxMasters(i);
   -- pgpTxSlaves(i)      <= intPgpTxSlaves(i);
   -- intPgpRxIn(i)       <= pgpRxIn(i);
   -- pgpRxOut(i)         <= intPgpRxOut(i);
   -- pgpRxMasterMuxed(i) <= intPgpRxMasterMuxed(i);
   -- intPgpRxCtrl(i)     <= pgpRxCtrl(i);
   -- end generate NATURAL_ORDER;

   REORG_0 : for i in 3 downto 0 generate
      REORG_1 : for j in 2 downto 0 generate
         -------------------------------
         -- Reorganized PGP Lane Mapping
         -------------------------------
         -- PPI[0] - PGP lanes [0,3,6,9] 
         -- PPI[1] - PGP lanes [1,4,7,10]
         -- PPI[2] - PGP lanes [2,5,8,11]
         -------------------------------
         intPgpTxIn((3*i)+j)       <= pgpTxIn((4*j)+i);
         pgpTxOut((4*j)+i)         <= intPgpTxOut((3*i)+j);
         intPgpTxMasters((3*i)+j)  <= pgpTxMasters((4*j)+i);
         pgpTxSlaves((4*j)+i)      <= intPgpTxSlaves((3*i)+j);
         intPgpRxIn((3*i)+j)       <= pgpRxIn((4*j)+i);
         pgpRxOut((4*j)+i)         <= intPgpRxOut((3*i)+j);
         pgpRxMasterMuxed((4*j)+i) <= intPgpRxMasterMuxed((3*i)+j);
         intPgpRxCtrl((3*i)+j)     <= pgpRxCtrl((4*j)+i);
      end generate REORG_1;
   end generate REORG_0;

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
            pgpRxIn          => intPgpRxIn(i),
            pgpRxOut         => intPgpRxOut(i),
            pgpTxIn          => intPgpTxIn(i),
            pgpTxOut         => intPgpTxOut(i),
            pgpTxMasters     => intPgpTxMasters(i),
            pgpTxSlaves      => intPgpTxSlaves(i),
            pgpRxMasterMuxed => intPgpRxMasterMuxed(i),
            pgpRxCtrl        => intPgpRxCtrl(i));
   end generate PGP_GTX_GEN;

end architecture STRUCTURE;
