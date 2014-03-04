-------------------------------------------------------------------------------
-- ZynqDtm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.VcPkg.all;
use work.Pgp2CoreTypesPkg.all;

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
      dtmToRtmHsP : out   sl;
      dtmToRtmHsM : out   sl;
      rtmToDtmHsP : in    sl;
      rtmToDtmHsM : in    sl;

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
   signal locRefClkG     : sl;
   signal timingCode     : slv(7 downto 0);
   signal timingCodeEn   : sl;
   signal fbCode         : Slv8Array(7 downto 0);
   signal fbCodeEn       : slv(7 downto 0);
   signal rtmClkCount    : slv(5 downto 0);
   signal rtmClkOut      : slv(5 downto 0);

   signal pgpClkRst        : sl;
   signal pgpClk           : sl;
   signal ipgpClk          : sl;
   signal pgpTxMmcmReset   : sl;
   signal pgpTxMmcmLocked  : sl;
   signal pgpRxIn          : PgpRxInType;
   signal pgpRxOut         : PgpRxOutType;
   signal pgpTxIn          : PgpTxInType;
   signal pgpTxOut         : PgpTxOutType;
   signal pgpVcTxQuadIn    : VcTxQuadInType;
   signal pgpVcTxQuadOut   : VcTxQuadOutType;
   signal pgpVcRxCommonOut : VcRxCommonOutType;
   signal pgpVcRxQuadOut   : VcRxQuadOutType;
   signal pgpFbClk         : sl;
   signal cellErrorCnt     : slv(31 downto 0);
   signal linkDownCnt      : slv(31 downto 0);
   signal linkErrorCnt     : slv(31 downto 0);
   signal countReset       : sl;
   signal countResetPgp    : sl;
   signal pllReset         : sl;
   signal pgpRxReset       : sl;
   signal pgpTxReset       : sl;
   signal pgpRxResetCore   : sl;
   signal pgpTxResetCore   : sl;
   signal clockCount       : slv(31 downto 0);
   signal loopEnable       : slv(2 downto 0);
   signal txCount          : slv(31 downto 0);
   signal rxCount          : slv(31 downto 0);
   signal eofeCount        : slv(31 downto 0);
   signal locRdEnCnt       : slv(3 downto 0);
   signal locRdEn          : sl;
   signal pgpRdEn          : sl;
   signal pgpRdEdge        : sl;
   signal pgpRdValid       : sl;
   signal locRdValid       : sl;
   signal pgpRdData        : slv(31 downto 0);

   type VcUsBuff16InQuad  is array (0 to 3) of VcUsBuff16InType;
   type VcUsBuff16OutQuad is array (0 to 3) of VcUsBuff16OutType;
   type VcDsBuff16InQuad  is array (0 to 3) of VcDsBuff16InType;
   type VcDsBuff16OutQuad is array (0 to 3) of VcDsBuff16OutType;

   signal usBuff16In       : VcUsBuff16InQuad;
   signal usBuff16Out      : VcUsBuff16OutQuad;
   signal dsBuff16In       : VcDsBuff16InQuad;
   signal dsBuff16Out      : VcDsBuff16OutQuad;

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
         dtmToIpmiP      => dtmToIpmiP,
         dtmToIpmiM      => dtmToIpmiM,
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
   U_DtmTimingSource : entity work.DtmTimingSource 
      generic map (
         TPD_G => 1 ns
      ) port map (
         axiClk                    => axiClk,
         axiClkRst                 => axiClkRst,
         localBusMaster            => localBusMaster(14),
         localBusSlave             => localBusSlave(14),
         sysClk200                 => sysClk200,
         sysClk200Rst              => sysClk200Rst,
         distClk                   => sysClk200,
         distClkRst                => sysClk200Rst,
         timingCode                => timingCode,
         timingCodeEn              => timingCodeEn,
         fbCode                    => fbCode,
         fbCodeEn                  => fbCodeEn,
         dpmClkP                   => dpmClkP,
         dpmClkM                   => dpmClkM,
         dpmFbP                    => dpmFbP,
         dpmFbM                    => dpmFbM,
         led                       => led
      );

   timingCode   <= (others=>'0');
   timingCodeEn <= '0';
   --signal fbCode         : Slv8(7 downto 0);
   --signal fbCodeEn       : slv(7 downto 0);


   --------------------------------------------------
   -- Output RTM Clocks
   --------------------------------------------------

   process ( sysClk200 ) begin
      if rising_edge(sysClk200) then
         if sysClk200Rst = '1' then
            rtmClkCount <= (others=>'0') after 1 ns;
            rtmClkOut   <= (others=>'0') after 1 ns;
         else
            rtmClkCount <= rtmClkCount + 1 after 1 ns;
            rtmClkOut   <= rtmClkCount     after 1 ns;
         end if;
      end if;
   end process;

   U_RtmOut : for i in 0 to 5 generate
      U_RtmBuf : OBUFDS
         port map(
            O      => dtmToRtmLsP(i),
            OB     => dtmToRtmLsM(i),
            I      => rtmClkOut(i)
         );
   end generate;


   --------------------------------------------------
   -- PGP Lanes
   --------------------------------------------------

   -- Local Ref Clk 
   U_LocRefClk : IBUFDS_GTE2
      port map(
         O       => locRefClk,
         ODIV2   => open,
         I       => locRefClkP,
         IB      => locRefClkM,
         CEB     => '0'
      );

   -- Buffer for ref clk
   U_RefBug : BUFG
      port map (
         I     => locRefClk,
         O     => locRefClkG
      );

   -- PGP Core
   U_Pgp: entity work.Pgp2Gtx7MultiLane 
      generic map (
         TPD_G                 => 1 ns,
         -----------------------------------------
         -- GT Settings
         -----------------------------------------
         -- Sim Generics
         SIM_GTRESET_SPEEDUP_G => "FALSE",
         SIM_VERSION_G         => "4.0",
         CPLL_REFCLK_SEL_G     => "001",

         -- 5Gbps
         STABLE_CLOCK_PERIOD_G => 4.0E-9,
         CPLL_FBDIV_G          => 2,
         CPLL_FBDIV_45_G       => 5,
         CPLL_REFCLK_DIV_G     => 1,
         RXOUT_DIV_G           => 1,
         TXOUT_DIV_G           => 1,
         RX_CLK25_DIV_G        => 10,
         TX_CLK25_DIV_G        => 10,
         RXCDR_CFG_G           => x"03000023ff20400020",    -- Set by wizard
         RX_OS_CFG_G           => "0000010000000",          -- Set by wizard
         RXDFEXYDEN_G          => '0',                      -- Set by wizard
         RX_DFE_KL_CFG2_G      => x"3010D90C",              -- Set by wizard

         -- 3.125Gbps
         --STABLE_CLOCK_PERIOD_G => 4.0E-9,
         --CPLL_FBDIV_G          => 5,
         --CPLL_FBDIV_45_G       => 5,
         --CPLL_REFCLK_DIV_G     => 2,
         --RXOUT_DIV_G           => 2,
         --TXOUT_DIV_G           => 2,
         --RX_CLK25_DIV_G        => 10,
         --TX_CLK25_DIV_G        => 10,
         --RXCDR_CFG_G           => x"03000023ff40200020",    -- Set by wizard
         --RX_OS_CFG_G           => "0000010000000",          -- Set by wizard
         --RXDFEXYDEN_G          => '0',                      -- Set by wizard
         --RX_DFE_KL_CFG2_G      => x"3010D90C",              -- Set by wizard

         -- 1.125Gbps
         --STABLE_CLOCK_PERIOD_G => 4.0E-9,  --units of seconds 1.25
         --CPLL_FBDIV_G          => 2,
         --CPLL_FBDIV_45_G       => 5,
         --CPLL_REFCLK_DIV_G     => 1,
         --RXOUT_DIV_G           => 4,
         --TXOUT_DIV_G           => 4,
         --RX_CLK25_DIV_G        => 10,
         --TX_CLK25_DIV_G        => 10,
         --RXCDR_CFG_G           => x"03000023ff40080020",    -- Set by wizard
         --RX_OS_CFG_G           => "0000010000000",          -- Set by wizard
         --RXDFEXYDEN_G          => '0',                      -- Set by wizard
         --RX_DFE_KL_CFG2_G      => x"3010D90C",              -- Set by wizard

         -- Configure PLL sourc
         TX_PLL_G              => "CPLL",
         RX_PLL_G              => "CPLL",
         -- Configure Number of
         LANE_CNT_G            => 1,
         ----------------------------------------
         -- PGP Settings
         ----------------------------------------
         PayloadCntTop         => 7,  -- Top bit for payload counter
         EnShortCells          => 1,  -- Enable short non-EOF cells
         VcInterleave          => 1
      ) port map (
         -- GT Clocking
         stableClk        => sysClk200,    -- GT needs a stable clock to "boot up"
         gtCPllRefClk     => locRefClk,    -- Drives CPLL if used
         gtQPllRefClk     => '0',          -- Signals from QPLL if used
         gtQPllClk        => '0',  
         gtQPllLock       => '0',  
         gtQPllRefClkLost => '0',  
         gtQPllReset      => open,
         -- Gt Serial IO
         gtTxP(0)         => dtmToRtmHsP,  -- GT Serial Transmit Positive
         gtTxN(0)         => dtmToRtmHsM,  -- GT Serial Transmit Negative
         gtRxP(0)         => rtmToDtmHsP,  -- GT Serial Receive Positive
         gtRxN(0)         => rtmToDtmHsM,  -- GT Serial Receive Negative
         -- Tx Clocking
         pgpTxReset        => pgpTxResetCore,
         pgpTxClk          => pgpClk,
         pgpTxMmcmReset    => pgpTxMmcmReset,
         pgpTxMmcmLocked   => pgpTxMmcmLocked,
         -- Rx clocking
         pgpRxReset        => pgpRxResetCore,
         pgpRxRecClk       => open,         -- recovered clock
         pgpRxClk          => pgpClk,
         pgpRxMmcmReset    => open,
         pgpRxMmcmLocked   => '1',
         -- Non VC Rx Signals
         pgpRxIn           => pgpRxIn,
         pgpRxOut          => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn           => pgpTxIn,
         pgpTxOut          => pgpTxOut,
         -- Frame Transmit Interface - Array of 4 VCs
         pgpVcTxQuadIn     => pgpVcTxQuadIn,
         pgpVcTxQuadOut    => pgpVcTxQuadOut,
         -- Frame Receive Interface - Array of 4 VCs
         pgpVcRxCommonOut  => pgpVcRxCommonOut,
         pgpVcRxQuadOut    => pgpVcRxQuadOut,
         -- GT loopback control
         loopback         => loopEnable
      );

   -- Reset
   U_pgpRxRstGen : entity work.RstSync
      generic map (
         TPD_G           => 1 ns,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => pgpClk,
        asyncRst => pgpRxReset,
        syncRst  => pgpRxResetCore
      );

   -- Reset
   U_pgpTxRstGen : entity work.RstSync
      generic map (
         TPD_G           => 1 ns,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => pgpClk,
        asyncRst => pgpTxReset,
        syncRst  => pgpTxResetCore
      );


   -- Rx Control
   pgpRxIn.flush    <= '0';
   pgpRxIn.resetRx  <= '0';

   -- Rx Status
   --pgpRxOut.linkReady
   --pgpRxOut.cellError
   --pgpRxOut.linkDown   
   --pgpRxOut.linkError  
   --pgpRxOut.opCodeEn   
   --pgpRxOut.opCode     
   --pgpRxOut.remLinkReady
   --pgpRxOut.remLinkData 

   -- Tx Control
   pgpTxIn.flush        <= '0';
   pgpTxIn.opCodeEn     <= '0';
   pgpTxIn.opCode       <= (others=>'0');
   pgpTxIn.locLinkReady <= pgpRxOut.linkReady;
   pgpTxIn.locData      <= (others=>'0');

   -- Tx Status
   --pgpTxOut.linkReady

   -- Counters
   process ( pgpClk ) begin
      if rising_edge(pgpClk) then
         if pgpClkRst = '1' then
            txCount   <= (others=>'0') after 1 ns;
            rxCount   <= (others=>'0') after 1 ns;
            eofeCount <= (others=>'0') after 1 ns;
         else

            if countResetPgp = '1' then
               txCount <= (others=>'0') after 1 ns;
            elsif (pgpVcTxQuadIn(0).valid = '1' and pgpVcTxQuadIn(0).eof = '1' and pgpVcTxQuadOut(0).ready = '1') or
                  (pgpVcTxQuadIn(1).valid = '1' and pgpVcTxQuadIn(1).eof = '1' and pgpVcTxQuadOut(1).ready = '1') or
                  (pgpVcTxQuadIn(2).valid = '1' and pgpVcTxQuadIn(2).eof = '1' and pgpVcTxQuadOut(2).ready = '1') or
                  (pgpVcTxQuadIn(3).valid = '1' and pgpVcTxQuadIn(3).eof = '1' and pgpVcTxQuadOut(3).ready = '1')  then
               txCount <= txCount + 1 after 1 ns;
            end if;

            if countResetPgp = '1' then
               rxCount <= (others=>'0') after 1 ns;
            elsif (pgpVcRxQuadOut(0).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '0') or
                  (pgpVcRxQuadOut(1).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '0') or
                  (pgpVcRxQuadOut(2).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '0') or
                  (pgpVcRxQuadOut(3).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '0')  then
               rxCount <= rxCount + 1 after 1 ns;
            end if;

            if countResetPgp = '1' then
               eofeCount <= (others=>'0') after 1 ns;
            elsif (pgpVcRxQuadOut(0).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '1') or
                  (pgpVcRxQuadOut(1).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '1') or
                  (pgpVcRxQuadOut(2).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '1') or
                  (pgpVcRxQuadOut(3).valid = '1' and pgpVcRxCommonOut.eof = '1' and pgpVcRxCommonOut.eofe = '1')  then
               eofeCount <= eofeCount + 1 after 1 ns;
            end if;

         end if;
      end if;
   end process;


   -- Transmit data on VCs
   U_DataLoopGen : for j in 0 to 3 generate
      pgpVcTxQuadIn(j).locBuffAFull <= '0';
      pgpVcTxQuadIn(j).locBuffFull  <= '0';
      pgpVcTxQuadIn(j).eofe         <= '0';
      pgpVcTxQuadIn(j).valid        <= '1';
      pgpVcTxQuadIn(j).sof          <= '1' when pgpVcTxQuadIn(j).data(0) = 0    else '0';
      pgpVcTxQuadIn(j).eof          <= '1' when pgpVcTxQuadIn(j).data(0) = 1500 else '0';
      pgpVcTxQuadIn(j).data(1 to 3) <= (others=>(others=>'0'));

      process ( pgpClk ) begin
         if rising_edge(pgpClk) then
            if pgpClkRst = '1' then
               pgpVcTxQuadIn(j).data(0)  <= (others=>'0') after 1 ns;
            elsif pgpVcTxQuadOut(j).ready = '1' then
               if pgpVcTxQuadIn(j).data(0)  = 1500 then
                  pgpVcTxQuadIn(j).data(0)  <= (others=>'0') after 1 ns;
               else
                  pgpVcTxQuadIn(j).data(0)  <= pgpVcTxQuadIn(j).data(0)  + 1 after 1 ns;
               end if;
            end if;
         end if;
      end process;
   end generate;

   process ( pgpClk ) begin
      if rising_edge(pgpClk) then
         if pgpClkRst = '1' then
            cellErrorCnt <= (others=>'0') after 1 ns;
            linkDownCnt  <= (others=>'0') after 1 ns;
            linkErrorCnt <= (others=>'0') after 1 ns;
         else

            if countResetPgp = '1' then
               cellErrorCnt <= (others=>'0') after 1 ns;
            elsif pgpRxOut.cellError = '1' and cellErrorCnt /= x"FFFFFFFF" then
               cellErrorCnt <= cellErrorCnt + 1 after 1 ns;
            end if;

            if countResetPgp = '1' then
               linkDownCnt  <= (others=>'0') after 1 ns;
            elsif pgpRxOut.linkDown = '1' and linkDownCnt /= x"FFFFFFFF" then
               linkDownCnt <= linkDownCnt + 1 after 1 ns;
            end if;

            if countResetPgp = '1' then
               linkErrorCnt <= (others=>'0') after 1 ns;
            elsif pgpRxOut.linkError = '1' and linkErrorCnt /= x"FFFFFFFF" then
               linkErrorCnt <= linkErrorCnt + 1 after 1 ns;
            end if;
         end if;
      end if;
   end process;

   process ( pgpClk ) begin
      if rising_edge(pgpClk) then
         if pgpClkRst = '1' then
            clockCount <= (others=>'0') after 1 ns;
         else
            clockCount <= clockCount + 1 after 1 ns;
         end if;
      end if;
   end process;


   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            localBusSlave(13) <= LocalBusSlaveInit after 1 ns;
            countReset        <= '0'               after 1 ns;
            pllReset          <= '1'               after 1 ns;
            pgpRxReset        <= '1'               after 1 ns;
            pgpTxReset        <= '1'               after 1 ns;
            loopEnable        <= (others=>'0')     after 1 ns;
            locRdEnCnt        <= (others=>'0')     after 1 ns;
            locRdEn           <= '0'               after 1 ns;
         else
            localBusSlave(13).readValid <= localBusMaster(13).readEnable after 1 ns;
            localBusSlave(13).readData  <= (others=>'0')                 after 1 ns;

            if localBusMaster(13).readEnable = '1' then
               locRdEnCnt <= (others=>'1') after 1 ns;
               locRdEn    <= '1'           after 1 ns;
            elsif locRdEnCnt = 0 then
               locRdEn <= '0' after 1 ns;
            else
               locRdEnCnt <= locRdEnCnt - 1 after 1 ns;
            end if;

            if localBusMaster(13).addr(11 downto 0) = x"000" then
               localBusSlave(13).readData(0) <= countReset after 1 ns;

               if localBusMaster(13).writeEnable = '1' then
                  countReset <= localBusMaster(13).writeData(0) after 1 ns;
               end if;

            elsif localBusMaster(13).addr(11 downto 0) = x"004" then
               localBusSlave(13).readData(2 downto 0) <= loopEnable after 1 ns;

               if localBusMaster(13).writeEnable = '1' then
                  loopEnable <= localBusMaster(13).writeData(2 downto 0) after 1 ns;
               end if;

            elsif localBusMaster(13).addr(11 downto 0) = x"008" then
               localBusSlave(13).readData <= clockCount after 1 ns;

            elsif localBusMaster(13).addr(11 downto 0) = x"00C" then
               localBusSlave(13).readData(0)           <= pgpTxMmcmReset  after 1 ns;
               localBusSlave(13).readData(16)          <= pgpTxMmcmLocked after 1 ns;
               localBusSlave(13).readData(17)          <= pgpClkRst       after 1 ns;

            elsif localBusMaster(13).addr(11 downto 0) = x"010" then
               localBusSlave(13).readData(0)            <= pgpTxReset after 1 ns;
               localBusSlave(13).readData(16)           <= pgpRxReset after 1 ns;

               if localBusMaster(13).writeEnable = '1' then
                  pgpTxReset <= localBusMaster(13).writeData(0)  after 1 ns;
                  pgpRxReset <= localBusMaster(13).writeData(16) after 1 ns;
               end if;

            elsif localBusMaster(13).addr(11 downto 0) = x"014" then
               localBusSlave(13).readData(0) <= pllReset after 1 ns;

               if localBusMaster(13).writeEnable = '1' then
                  pllReset <= localBusMaster(13).writeData(0) after 1 ns;
               end if;

            elsif localBusMaster(13).addr(11 downto 9) = "001" then
               localBusSlave(13).readValid <= locRdValid after 1 ns;
               localBusSlave(13).readData  <= pgpRdData  after 1 ns;
            end if;

         end if;
      end if;
   end process;

   U_CRstSyncA : entity work.SynchronizerEdge
      generic map (
         TPD_G          => 1 ns,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 4,
         INIT_G         => "0"
      ) port map (
         clk         => pgpClk,
         rst         => pgpClkRst,
         dataIn      => countReset,
         dataOut     => countResetPgp,
         risingEdge  => open,
         fallingEdge => open
      );


   U_ReadSyncA : entity work.SynchronizerEdge
      generic map (
         TPD_G          => 1 ns,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 8,
         INIT_G         => "0"
      ) port map (
         clk         => pgpClk,
         rst         => pgpClkRst,
         dataIn      => locRdEn,
         dataOut     => pgpRdEn,
         risingEdge  => pgpRdEdge,
         fallingEdge => open
      );

   process ( pgpClk ) begin
      if rising_edge(pgpClk) then
         if pgpClkRst = '1' then
            pgpRdData  <= (others=>'0') after 1 ns;
            pgpRdValid <= '0'           after 1 ns;
         else
            pgpRdValid <= pgpRdEn after 1 ns;

            if pgpRdEdge = '1' then
               pgpRdData  <= (others=>'0') after 1 ns;

               if localBusMaster(13).addr(4 downto 2) = "000" then
                  pgpRdData(0)            <= pgpRxOut.linkReady after 1 ns;
                  pgpRdData(31 downto 28) <= clockCount(3 downto 0) after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "001" then
                  pgpRdData    <= cellErrorCnt after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "010" then
                  pgpRdData    <= linkDownCnt  after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "011" then
                  pgpRdData    <= linkErrorCnt after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "100" then
                  pgpRdData    <= txCount after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "101" then
                  pgpRdData    <= rxCount after 1 ns;
               elsif localBusMaster(13).addr(4 downto 2) = "110" then
                  pgpRdData    <= eofeCount after 1 ns;
               end if;
            end if;
         end if;
      end if;
   end process;

   U_ReadSyncB : entity work.SynchronizerEdge
      generic map (
         TPD_G          => 1 ns,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 8,
         INIT_G         => "0"
      ) port map (
         clk         => axiClk,
         rst         => axiClkRst,
         dataIn      => pgpRdValid,
         dataOut     => open,
         risingEdge  => locRdValid,
         fallingEdge =>open
      );

   -- PLL
   U_PgpClkGen : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => FALSE,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => FALSE,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 4.000,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => FALSE,
         CLKOUT0_DIVIDE_F     => 4.0, -- 5.0 gbps
         --CLKOUT0_DIVIDE_F     => 16.0, -- 1.125 gbps
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.5,
         CLKOUT0_USE_FINE_PS  => FALSE,
         CLKOUT1_DIVIDE       => 5,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.5,
         CLKOUT1_USE_FINE_PS  => FALSE,
         CLKOUT2_DIVIDE       => 8,
         CLKOUT2_PHASE        => 0.000,
         CLKOUT2_DUTY_CYCLE   => 0.5,
         CLKOUT2_USE_FINE_PS  => FALSE,
         CLKIN1_PERIOD        => 4.0,
         REF_JITTER1          => 0.010
      )
      port map (
         CLKFBOUT             => pgpFbClk,
         CLKFBOUTB            => open,
         CLKOUT0              => ipgpClk,
         CLKOUT0B             => open,
         CLKOUT1              => open,
         CLKOUT1B             => open,
         CLKOUT2              => open,
         CLKOUT2B             => open,
         CLKOUT3              => open,
         CLKOUT3B             => open,
         CLKOUT4              => open,
         CLKOUT5              => open,
         CLKOUT6              => open,
         CLKFBIN              => pgpFbClk,
         CLKIN1               => locRefClkG,
         CLKIN2               => '0',
         CLKINSEL             => '1',
         DADDR                => (others => '0'),
         DCLK                 => '0',
         DEN                  => '0',
         DI                   => (others => '0'),
         DO                   => open,
         DRDY                 => open,
         DWE                  => '0',
         PSCLK                => '0',
         PSEN                 => '0',
         PSINCDEC             => '0',
         PSDONE               => open,
         LOCKED               => pgpTxMmcmLocked,
         CLKINSTOPPED         => open,
         CLKFBSTOPPED         => open,
         PWRDWN               => '0',
         RST                  => pllReset
      );

   -- Clock Buffer
   U_pgpClkBuf : BUFG
      port map (
         I     => ipgpClk,
         O     => pgpClk
      );

   -- Reset Gen
   U_pgpClkRstGen : entity work.RstSync
      generic map (
         TPD_G           => 1 ns,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => pgpClk,
        asyncRst => pgpTxMmcmLocked,
        syncRst  => pgpClkRst
      );


   --------------------------------------------------
   -- Top Level Signals
   --------------------------------------------------

   -- Debug
   --led          : out   slv(1 downto 0);

   -- Reference Clock
   --locRefClkP  : in    sl;
   --locRefClkM  : in    sl;

   -- RTM High Speed
   --dtmToRtmHsP : out   sl;
   --dtmToRtmHsM : out   sl;
   --rtmToDtmHsP : in    sl;
   --rtmToDtmHsM : in    sl;

   -- RTM Low Speed
   --dtmToRtmLsP  : inout slv(5 downto 0);
   --dtmToRtmLsM  : inout slv(5 downto 0);

   -- DPM Signals
   --dpmClkP      : out   slv(2  downto 0);
   --dpmClkM      : out   slv(2  downto 0);
   --dpmFbP       : in    slv(7  downto 0);
   --dpmFbM       : in    slv(7  downto 0);

   -- Backplane Clocks
   --bpClkIn      : in    slv(5 downto 0);
   --bpClkOut     : out   slv(5 downto 0);
   bpClkOut <= (others=>'0');

   -- Spare Signals
   --plSpareP     : inout slv(4 downto 0);
   --plSpareM     : inout slv(4 downto 0)
   plSpareP <= (others=>'Z');
   plSpareM <= (others=>'Z');

   -- Local bus
   --localBusMaster : LocalBusMasterVector(12 downto 8);
   localBusSlave(12 downto 8)  <= (others=>LocalBusSlaveInit);

end architecture STRUCTURE;

