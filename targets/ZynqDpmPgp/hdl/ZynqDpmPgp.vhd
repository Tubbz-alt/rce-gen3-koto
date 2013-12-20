-------------------------------------------------------------------------------
-- ZynqDpmPgp.vhd
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

entity ZynqDpmPgp is
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
      dpmToRtmHsP  : out   slv(11 downto 0);
      dpmToRtmHsM  : out   slv(11 downto 0);
      rtmToDpmHsP  : in    slv(11 downto 0);
      rtmToDpmHsM  : in    slv(11 downto 0);

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
end ZynqDpmPgp;

architecture STRUCTURE of ZynqDpmPgp is

   -- Local Signals
   signal obPpiClk         : slv(3 downto 0);
   signal obPpiToFifo      : ObPpiToFifoVector(3 downto 0);
   signal obPpiFromFifo    : ObPpiFromFifoVector(3 downto 0);
   signal ibPpiClk         : slv(3 downto 0);
   signal ibPpiToFifo      : IbPpiToFifoVector(3 downto 0);
   signal ibPpiFromFifo    : IbPpiFromFifoVector(3 downto 0);
   signal dtmFb            : sl;
   signal dtmClk           : slv(1 downto 0);
   signal locRefClk        : slv(1 downto 0);
   signal locRefClkG       : sl;
   signal dtmRefClk        : sl;
   signal axiClk           : sl;
   signal axiClkRst        : sl;
   signal sysClk125        : sl;
   signal sysClk125Rst     : sl;
   signal sysClk200        : sl;
   signal sysClk200Rst     : sl;
   signal localBusMaster   : LocalBusMasterVector(15 downto 8);
   signal localBusSlave    : LocalBusSlaveVector(15 downto 8);
   signal timingCode       : slv(7 downto 0);
   signal timingCodeEn     : sl;
   signal fbCode           : slv(7 downto 0);
   signal fbCodeEn         : sl;
   signal pgpClkRst        : sl;
   signal pgpClk           : sl;
   signal ipgpClk          : sl;
   signal pgpTxMmcmReset   : slv(11 downto 0);
   signal pgpTxMmcmLocked  : sl;
   signal pgpRxIn          : PgpRxInArray(11 downto 0);
   signal pgpRxOut         : PgpRxOutArray(11 downto 0);
   signal pgpTxIn          : PgpTxInArray(11 downto 0);
   signal pgpTxOut         : PgpTxOutArray(11 downto 0);
   signal pgpVcTxQuadIn    : VcTxQuadInArray(11 downto 0);
   signal pgpVcTxQuadOut   : VcTxQuadOutArray(11 downto 0);
   signal pgpVcRxCommonOut : VcRxCommonOutArray(11 downto 0);
   signal pgpVcRxQuadOut   : VcRxQuadOutArray(11 downto 0);
   signal pgpFbClk         : sl;
   signal cellErrorCnt     : Slv32Array(11 downto 0);
   signal linkDownCnt      : Slv32Array(11 downto 0);
   signal linkErrorCnt     : Slv32Array(11 downto 0);
   signal countReset       : sl;
   signal countResetRegA   : sl;
   signal countResetRegB   : sl;
   signal pgpReset         : sl;
   signal clockCount       : slv(31 downto 0);
   signal loopEnable       : slv(2 downto 0);
   signal txCount          : Slv32Array(11 downto 0);
   signal rxCount          : Slv32Array(11 downto 0);
   signal eofeCount        : Slv32Array(11 downto 0);

   type VcUsBuff16InQuad  is array (0 to 3) of VcUsBuff16InType;
   type VcUsBuff16OutQuad is array (0 to 3) of VcUsBuff16OutType;
   type VcDsBuff16InQuad  is array (0 to 3) of VcDsBuff16InType;
   type VcDsBuff16OutQuad is array (0 to 3) of VcDsBuff16OutType;

   type VcUsBuff16InQuadVector  is array (natural range <>) of VcUsBuff16InQuad;
   type VcUsBuff16OutQuadVector is array (natural range <>) of VcUsBuff16OutQuad;
   type VcDsBuff16InQuadVector  is array (natural range <>) of VcDsBuff16InQuad;
   type VcDsBuff16OutQuadVector is array (natural range <>) of VcDsBuff16OutQuad;

   signal usBuff16In       : VcUsBuff16InQuadVector(11 downto 0);
   signal usBuff16Out      : VcUsBuff16OutQuadVector(11 downto 0);
   signal dsBuff16In       : VcDsBuff16InQuadVector(11 downto 0);
   signal dsBuff16Out      : VcDsBuff16OutQuadVector(11 downto 0);

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
   localBusSlave(12 downto 8) <= (others=>LocalBusSlaveInit);

   -- Clocks
   --signal axiClk         : sl;
   --signal axiClkRst      : sl;
   --signal sysClk125      : sl;
   --signal sysClk125Rst   : sl;
   --signal sysClk200      : sl;
   --signal sysClk200Rst   : sl;


   --------------------------------------------------
   -- PGP Lanes
   --------------------------------------------------

   -- Buffer for ref clk
   U_RefBug : BUFG
      port map (
         I     => locRefClk(1),
         O     => locRefClkG
      );

   -- 12 Units
   U_PgpGen : for i in 0 to 11 generate

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

            STABLE_CLOCK_PERIOD_G => 4.0E-9,  --units of seconds 5.0
            CPLL_REFCLK_SEL_G     => "001",
            CPLL_FBDIV_G          => 2,
            CPLL_FBDIV_45_G       => 5,
            CPLL_REFCLK_DIV_G     => 1,
            RXOUT_DIV_G           => 1,
            TXOUT_DIV_G           => 1,
            RX_CLK25_DIV_G        => 10,
            TX_CLK25_DIV_G        => 10,

            --STABLE_CLOCK_PERIOD_G => 6.4E-9,  --units of seconds 3.125
            --CPLL_FBDIV_G          => 4,
            --CPLL_FBDIV_45_G       => 5,
            --CPLL_REFCLK_DIV_G     => 1,
            --RXOUT_DIV_G           => 2,
            --TXOUT_DIV_G           => 2,
            --RX_CLK25_DIV_G        => 7,
            --TX_CLK25_DIV_G        => 7,

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
            gtCPllRefClk     => locRefClk(1), -- Drives CPLL if used
            gtQPllRefClk     => '0',          -- Signals from QPLL if used
            gtQPllClk        => '0',  
            gtQPllLock       => '0',  
            gtQPllRefClkLost => '0',  
            gtQPllReset      => open,
            -- Gt Serial IO
            gtTxP(0)         => dpmToRtmHsP(i),  -- GT Serial Transmit Positive
            gtTxN(0)         => dpmToRtmHsM(i),  -- GT Serial Transmit Negative
            gtRxP(0)         => rtmToDpmHsP(i),  -- GT Serial Receive Positive
            gtRxN(0)         => rtmToDpmHsM(i),  -- GT Serial Receive Negative
            -- Tx Clocking
            pgpTxReset        => pgpClkRst,
            pgpTxClk          => pgpClk,
            pgpTxMmcmReset    => pgpTxMmcmReset(i),
            pgpTxMmcmLocked   => pgpTxMmcmLocked,
            -- Rx clocking
            pgpRxReset        => pgpClkRst,
            pgpRxRecClk       => open,         -- recovered clock
            pgpRxClk          => pgpClk,
            pgpRxMmcmReset    => open,
            pgpRxMmcmLocked   => '1',
            -- Non VC Rx Signals
            pgpRxIn           => pgpRxIn(i),
            pgpRxOut          => pgpRxOut(i),
            -- Non VC Tx Signals
            pgpTxIn           => pgpTxIn(i),
            pgpTxOut          => pgpTxOut(i),
            -- Frame Transmit Interface - Array of 4 VCs
            pgpVcTxQuadIn     => pgpVcTxQuadIn(i),
            pgpVcTxQuadOut    => pgpVcTxQuadOut(i),
            -- Frame Receive Interface - Array of 4 VCs
            pgpVcRxCommonOut  => pgpVcRxCommonOut(i),
            pgpVcRxQuadOut    => pgpVcRxQuadOut(i),
            -- GT loopback control
            loopback         => loopEnable
         );

      -- Rx Control
      pgpRxIn(i).flush    <= '0';
      pgpRxIn(i).resetRx  <= '0';

      -- Rx Status
      --pgpRxOut(i).linkReady
      --pgpRxOut(i).cellError
      --pgpRxOut(i).linkDown   
      --pgpRxOut(i).linkError  
      --pgpRxOut(i).opCodeEn   
      --pgpRxOut(i).opCode     
      --pgpRxOut(i).remLinkReady
      --pgpRxOut(i).remLinkData 

      -- Tx Control
      pgpTxIn(i).flush        <= '0';
      pgpTxIn(i).opCodeEn     <= '0';
      pgpTxIn(i).opCode       <= (others=>'0');
      pgpTxIn(i).locLinkReady <= pgpRxOut(i).linkReady;
      pgpTxIn(i).locData      <= (others=>'0');

      -- Tx Status
      --pgpTxOut(i).linkReady

      -- Counters
      process ( pgpClk, pgpClkRst ) begin
         if pgpClkRst = '1' then
            txCount(i)   <= (others=>'0') after 1 ns;
            rxCount(i)   <= (others=>'0') after 1 ns;
            eofeCount(i) <= (others=>'0') after 1 ns;
         elsif rising_edge(pgpClk) then

            if countResetRegB = '1' then
               txCount(i) <= (others=>'0') after 1 ns;
            elsif (pgpVcTxQuadIn(i)(0).valid = '1' and pgpVcTxQuadIn(i)(0).eof = '1' and pgpVcTxQuadOut(i)(0).ready = '1') or
                  (pgpVcTxQuadIn(i)(1).valid = '1' and pgpVcTxQuadIn(i)(1).eof = '1' and pgpVcTxQuadOut(i)(1).ready = '1') or
                  (pgpVcTxQuadIn(i)(2).valid = '1' and pgpVcTxQuadIn(i)(2).eof = '1' and pgpVcTxQuadOut(i)(2).ready = '1') or
                  (pgpVcTxQuadIn(i)(3).valid = '1' and pgpVcTxQuadIn(i)(3).eof = '1' and pgpVcTxQuadOut(i)(3).ready = '1')  then
               txCount(i) <= txCount(i) + 1 after 1 ns;
            end if;

            if countResetRegB = '1' then
               rxCount(i) <= (others=>'0') after 1 ns;
            elsif (pgpVcRxQuadOut(i)(0).valid = '1' and pgpVcTxQuadIn(i)(0).eof = '1') or
                  (pgpVcRxQuadOut(i)(1).valid = '1' and pgpVcTxQuadIn(i)(1).eof = '1') or
                  (pgpVcRxQuadOut(i)(2).valid = '1' and pgpVcTxQuadIn(i)(2).eof = '1') or
                  (pgpVcRxQuadOut(i)(3).valid = '1' and pgpVcTxQuadIn(i)(3).eof = '1')  then
               rxCount(i) <= rxCount(i) + 1 after 1 ns;
            end if;

            if countResetRegB = '1' then
               eofeCount(i) <= (others=>'0') after 1 ns;
            elsif (pgpVcRxQuadOut(i)(0).valid = '1' and pgpVcRxCommonOut(i).eof = '1' and pgpVcRxCommonOut(i).eofe = '1') or
                  (pgpVcRxQuadOut(i)(1).valid = '1' and pgpVcRxCommonOut(i).eof = '1' and pgpVcRxCommonOut(i).eofe = '1') or
                  (pgpVcRxQuadOut(i)(2).valid = '1' and pgpVcRxCommonOut(i).eof = '1' and pgpVcRxCommonOut(i).eofe = '1') or
                  (pgpVcRxQuadOut(i)(3).valid = '1' and pgpVcRxCommonOut(i).eof = '1' and pgpVcRxCommonOut(i).eofe = '1')  then
               eofeCount(i) <= eofeCount(i) + 1 after 1 ns;
            end if;

         end if;
      end process;


      -- Transmit data on VCs
      U_LoopGen : for j in 0 to 3 generate
         pgpVcTxQuadIn(i)(j).locBuffAFull <= '0';
         pgpVcTxQuadIn(i)(j).locBuffFull  <= '0';
         pgpVcTxQuadIn(i)(j).eofe         <= '0';
         pgpVcTxQuadIn(i)(j).valid        <= '1';
         pgpVcTxQuadIn(i)(j).sof          <= '1' when pgpVcTxQuadIn(i)(j).data(0) = 0    else '0';
         pgpVcTxQuadIn(i)(j).eof          <= '1' when pgpVcTxQuadIn(i)(j).data(0) = 1500 else '0';
         pgpVcTxQuadIn(i)(j).data(1 to 3) <= (others=>(others=>'0'));

         process ( pgpClk, pgpClkRst ) begin
            if pgpClkRst = '1' then
               pgpVcTxQuadIn(i)(j).data(0)  <= (others=>'0') after 1 ns;
            elsif rising_edge(pgpClk) then

               if pgpVcTxQuadOut(i)(j).ready = '1' then
                  if pgpVcTxQuadIn(i)(j).data(0)  = 1500 then
                     pgpVcTxQuadIn(i)(j).data(0)  <= (others=>'0') after 1 ns;
                  else
                     pgpVcTxQuadIn(i)(j).data(0)  <= pgpVcTxQuadIn(i)(j).data(0)  + 1 after 1 ns;
                  end if;
               end if;
            end if;
         end process;
      end generate;

      process ( pgpClk, pgpClkRst ) begin
         if pgpClkRst = '1' then
            cellErrorCnt(i) <= (others=>'0') after 1 ns;
            linkDownCnt(i)  <= (others=>'0') after 1 ns;
            linkErrorCnt(i) <= (others=>'0') after 1 ns;
            countResetRegA  <= '0'           after 1 ns;
            countResetRegB  <= '0'           after 1 ns;
         elsif rising_edge(pgpClk) then
            countResetRegA  <= countReset     after 1 ns;
            countResetRegB  <= countResetRegA after 1 ns;

            if countResetRegB = '1' then
               cellErrorCnt(i) <= (others=>'0') after 1 ns;
            elsif pgpRxOut(i).cellError = '1' and cellErrorCnt(i) /= x"FFFFFFFF" then
               cellErrorCnt(i) <= cellErrorCnt(i) + 1 after 1 ns;
            end if;

            if countResetRegB = '1' then
               linkDownCnt(i)  <= (others=>'0') after 1 ns;
            elsif pgpRxOut(i).linkDown = '1' and linkDownCnt(i) /= x"FFFFFFFF" then
               linkDownCnt(i) <= linkDownCnt(i) + 1 after 1 ns;
            end if;

            if countResetRegB = '1' then
               linkErrorCnt(i) <= (others=>'0') after 1 ns;
            elsif pgpRxOut(i).linkError = '1' and linkErrorCnt(i) /= x"FFFFFFFF" then
               linkErrorCnt(i) <= linkErrorCnt(i) + 1 after 1 ns;
            end if;

         end if;
      end process;

   end generate;

   process ( pgpClk, pgpClkRst ) begin
      if pgpClkRst = '1' then
         clockCount <= (others=>'0') after 1 ns;
      elsif rising_edge(pgpClk) then
         clockCount <= clockCount + 1 after 1 ns;
      end if;
   end process;


   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave(13) <= LocalBusSlaveInit after 1 ns;
         countReset        <= '0'               after 1 ns;
         pgpReset          <= '1'               after 1 ns;
         loopEnable        <= (others=>'0')     after 1 ns;
      elsif rising_edge(axiClk) then
         localBusSlave(13).readValid <= localBusMaster(13).readEnable after 1 ns;
         localBusSlave(13).readData  <= (others=>'0')                 after 1 ns;

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
            localBusSlave(13).readData(11 downto 0) <= pgpTxMmcmReset  after 1 ns;
            localBusSlave(13).readData(16)          <= pgpTxMmcmLocked after 1 ns;
            localBusSlave(13).readData(17)          <= pgpClkRst       after 1 ns;

         elsif localBusMaster(13).addr(11 downto 0) = x"010" then
            localBusSlave(13).readData(0) <= pgpReset after 1 ns;

            if localBusMaster(13).writeEnable = '1' then
               pgpReset <= localBusMaster(13).writeData(0) after 1 ns;
            end if;

         elsif localBusMaster(13).addr(11 downto 9) = "001" then
            if localBusMaster(13).addr(4 downto 2) = "000" then
               localBusSlave(13).readData(0)            <= pgpRxOut(conv_integer(localBusMaster(13).addr(8 downto 5))).linkReady after 1 ns;
               localBusSlave(13).readData(31 downto 28) <= clockCount(3 downto 0)                                                after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "001" then
               localBusSlave(13).readData    <= cellErrorCnt(conv_integer(localBusMaster(13).addr(8 downto 5)))       after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "010" then
               localBusSlave(13).readData    <= linkDownCnt(conv_integer(localBusMaster(13).addr(8 downto 5)))        after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "011" then
               localBusSlave(13).readData    <= linkErrorCnt(conv_integer(localBusMaster(13).addr(8 downto 5)))       after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "100" then
               localBusSlave(13).readData    <= txCount(conv_integer(localBusMaster(13).addr(8 downto 5)))       after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "101" then
               localBusSlave(13).readData    <= rxCount(conv_integer(localBusMaster(13).addr(8 downto 5)))       after 1 ns;
            elsif localBusMaster(13).addr(4 downto 2) = "110" then
               localBusSlave(13).readData    <= eofeCount(conv_integer(localBusMaster(13).addr(8 downto 5)))       after 1 ns;
            end if;
         end if;

      end if;
   end process;

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
         CLKOUT0_DIVIDE_F     => 4.0,
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
         RST                  => pgpReset
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

end architecture STRUCTURE;

