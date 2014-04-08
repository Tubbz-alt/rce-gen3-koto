-------------------------------------------------------------------------------
-- DtmRtmTest.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;
use work.Vc64Pkg.all;
use work.Pgp2bPkg.all;
use work.AxiLitePkg.all;

entity DtmRtmTest is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Sys Clocks
      sysClk200          : in  sl;
      sysClk200Rst       : in  sl;

      -- AXI Bus
      axiClk             : in  sl;
      axiClkRst          : in  sl;
      topAxiReadMaster   : in  AxiLiteReadMasterType;
      topAxiReadSlave    : out AxiLiteReadSlaveType;
      topAxiWriteMaster  : in  AxiLiteWriteMasterType;
      topAxiWriteSlave   : out AxiLiteWriteSlaveType;

      -- Reference Clock
      locRefClkP  : in    sl;
      locRefClkM  : in    sl;

      -- RTM High Speed
      dtmToRtmHsP : out   sl;
      dtmToRtmHsM : out   sl;
      rtmToDtmHsP : in    sl;
      rtmToDtmHsM : in    sl;

      -- RTM Low Speed
      dtmToRtmLsP  : inout slv(5 downto 0);
      dtmToRtmLsM  : inout slv(5 downto 0)
   );
end DtmRtmTest;

architecture STRUCTURE of DtmRtmTest is

   -- Local Signals
   signal locRefClk          : sl;
   signal locRefClkG         : sl;
   signal rtmClkCount        : slv(5 downto 0);
   signal rtmClkOut          : slv(5 downto 0);
   signal pgpAxiReadMaster   : AxiLiteReadMasterType;
   signal pgpAxiReadSlave    : AxiLiteReadSlaveType;
   signal pgpAxiWriteMaster  : AxiLiteWriteMasterType;
   signal pgpAxiWriteSlave   : AxiLiteWriteSlaveType;
   signal pgpClkRst          : sl;
   signal pgpClkRstSw        : sl;
   signal pgpClk             : sl;
   signal ipgpClk            : sl;
   signal pgpTxMmcmReset     : sl;
   signal pgpTxMmcmLocked    : sl;
   signal pgpRxIn            : PgpRxInType;
   signal pgpRxOut           : PgpRxOutType;
   signal pgpTxIn            : PgpTxInType;
   signal pgpTxOut           : PgpTxOutType;
   signal pgpTxVcData        : Vc64DataArray(3 downto 0);
   signal pgpTxVcCtrl        : Vc64CtrlArray(3 downto 0);
   signal pgpRxVcData        : Vc64DataType;
   signal pgpRxVcCtrl        : Vc64CtrlArray(3 downto 0);
   signal pgpFbClk           : sl;
   signal cellErrorCnt       : slv(31 downto 0);
   signal linkDownCnt        : slv(31 downto 0);
   signal linkErrorCnt       : slv(31 downto 0);
   signal pgpRxResetCore     : sl;
   signal pgpTxResetCore     : sl;
   signal clockCount         : slv(31 downto 0);
   signal txCount            : slv(31 downto 0);
   signal rxCount            : slv(31 downto 0);
   signal eofeCount          : slv(31 downto 0);

   type RegType is record
      countReset        : sl;
      clkReset          : sl;
      pgpRxReset        : sl;
      pgpTxReset        : sl;
      loopEnable        : slv(2 downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      countReset        => '0',
      clkReset          => '1',
      pgpRxReset        => '1',
      pgpTxReset        => '1',
      loopEnable        => (others=>'0'),
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   --------------------------------------------------
   -- Registers
   --------------------------------------------------

   U_AxiLiteAsync : entity work.AxiLiteAsync 
      generic map (
         NUM_ADDR_BITS_G  => 16
      ) port map (
         sAxiClk           => axiClk,
         sAxiClkRst        => axiClkRst,
         sAxiReadMaster    => topAxiReadMaster,
         sAxiReadSlave     => topAxiReadSlave,
         sAxiWriteMaster   => topAxiWriteMaster,
         sAxiWriteSlave    => topAxiWriteSlave,
         mAxiClk           => pgpClk,
         mAxiClkRst        => pgpClkRst,
         mAxiReadMaster    => pgpAxiReadMaster,
         mAxiReadSlave     => pgpAxiReadSlave,
         mAxiWriteMaster   => pgpAxiWriteMaster,
         mAxiWriteSlave    => pgpAxiWriteSlave
      );

   -- Sync
   process (pgpClk) is
   begin
      if (rising_edge(pgpClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (pgpClkRst, pgpAxiReadMaster, pgpAxiWriteMaster, r, pgpTxMmcmLocked, pgpTxMmcmReset, 
            pgpRxOut, cellErrorCnt, linkDownCnt, linkErrorCnt, txCount, rxCount, eofeCount, clockCount )
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      axiSlaveWaitTxn(pgpAxiWriteMaster, pgpAxiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         if pgpAxiWriteMaster.awaddr(11 downto 0) = x"000" then
            v.countReset := pgpAxiWriteMaster.wdata(0);

         elsif pgpAxiWriteMaster.awaddr(11 downto 0) = x"004" then
            v.loopEnable := pgpAxiWriteMaster.wdata(2 downto 0);

         elsif pgpAxiWriteMaster.awaddr(11 downto 0) = x"010" then
            v.pgpTxReset := pgpAxiWriteMaster.wdata(0);
            v.pgpRxReset := pgpAxiWriteMaster.wdata(16);

         elsif pgpAxiWriteMaster.awaddr(11 downto 0) = x"014" then
            v.clkReset := pgpAxiWriteMaster.wdata(0);
         end if;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         if pgpAxiReadMaster.araddr(11 downto 0)  = x"000" then
            v.axiReadSlave.rdata(0) := r.countReset;

         elsif pgpAxiReadMaster.araddr(11 downto 0)  = x"004" then
            v.axiReadSlave.rdata(2 downto 0) := r.loopEnable;

         elsif pgpAxiReadMaster.araddr(11 downto 0)  = x"008" then
            v.axiReadSlave.rdata := clockCount;

         elsif pgpAxiReadMaster.araddr(11 downto 0)  = x"00C" then
            v.axiReadSlave.rdata(16) := pgpTxMmcmLocked;
            v.axiReadSlave.rdata(0)  := pgpTxMmcmReset;

         elsif pgpAxiReadMaster.araddr(11 downto 0)  = x"010" then
            v.axiReadSlave.rdata(16) := r.pgpRxReset;
            v.axiReadSlave.rdata(0)  := r.pgpTxReset;

         elsif pgpAxiReadMaster.araddr(11 downto 0)  = x"014" then
            v.axiReadSlave.rdata(0) := r.clkReset;

         elsif pgpAxiReadMaster.araddr(11 downto 9)  = "001" then
            case pgpAxiReadMaster.araddr(4 downto 2) is

               when "000" =>
                  v.axiReadSlave.rdata(31 downto 28) := clockCount(3 downto 0);
                  v.axiReadSlave.rdata(0)            := pgpRxOut.linkReady;

               when "001" =>
                  v.axiReadSlave.rdata := cellErrorCnt;

               when "010" =>
                  v.axiReadSlave.rdata := linkDownCnt;

               when "011" =>
                  v.axiReadSlave.rdata := linkErrorCnt;

               when "100" =>
                  v.axiReadSlave.rdata := txCount;

               when "101" =>
                  v.axiReadSlave.rdata := rxCount;

               when "110" =>
                  v.axiReadSlave.rdata := eofeCount;

               when others => null;
            end case;
         end if;

         -- Send Axi response
         axiSlaveReadResponse(v.axiReadSlave);

      end if;

      -- Reset
      if (pgpClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      pgpAxiReadSlave  <= r.axiReadSlave;
      pgpAxiWriteSlave <= r.axiWriteSlave;
      
   end process;


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
   U_Pgp: entity work.Pgp2bGtx7MultiLane
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
            PAYLOAD_CNT_TOP_G     => 7,  -- Top bit for payload counter
            EN_SHORT_CELLS_G      => 1,  -- Enable short non-EOF cells
            VC_INTERLEAVE_G       => 1
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
         -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
         pgpTxVcData       => pgpTxVcData,
         pgpTxVcCtrl       => pgpTxVcCtrl,
         -- Frame Receive Interface - 1 Lane, Array of 4 VCs
         pgpRxVcData       => pgpRxVcData,
         pgpRxVcCtrl       => pgpRxVcCtrl,
         -- GT loopback control
         loopback          => r.loopEnable
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
        asyncRst => r.pgpRxReset,
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
        asyncRst => r.pgpTxReset,
        syncRst  => pgpTxResetCore
      );


   -- Rx Control
   pgpRxIn.flush    <= '0';
   pgpRxIn.resetRx  <= '0';

   -- Rx Status
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
         if r.countReset = '1' or pgpClkRstSw = '1' then
               txCount <= (others=>'0') after 1 ns;
            elsif (pgpTxVcData(0).valid = '1' and pgpTxVcData(0).eof = '1' and pgpTxVcCtrl(0).ready = '1') or
                  (pgpTxVcData(1).valid = '1' and pgpTxVcData(1).eof = '1' and pgpTxVcCtrl(1).ready = '1') or
                  (pgpTxVcData(2).valid = '1' and pgpTxVcData(2).eof = '1' and pgpTxVcCtrl(2).ready = '1') or
                  (pgpTxVcData(3).valid = '1' and pgpTxVcData(3).eof = '1' and pgpTxVcCtrl(3).ready = '1') then
               txCount <= txCount + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
               rxCount <= (others=>'0') after 1 ns;
            elsif (pgpRxVcData.valid = '1' and pgpRxVcData.eof = '1' and pgpRxVcData.eofe = '0') then
               rxCount <= rxCount + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
               eofeCount <= (others=>'0') after 1 ns;
            elsif (pgpRxVcData.valid = '1' and pgpRxVcData.eof = '1' and pgpRxVcData.eofe = '1') then
               eofeCount <= eofeCount + 1 after 1 ns;
         end if;
      end if;
   end process;


   -- Transmit data on VCs
   U_LoopGen : for j in 0 to 3 generate
      pgpRxVcCtrl(j).overflow   <= '0';
      pgpRxVcCtrl(j).almostFull <= '0';
      pgpRxVcCtrl(j).ready      <= '1';
      pgpTxVcData(j).eofe       <= '0';
      pgpTxVcData(j).size       <= '0';
      pgpTxVcData(j).vc         <= "00";
      pgpTxVcData(j).valid      <= '1';
      pgpTxVcData(j).sof        <= '1' when pgpTxVcData(j).data = 0    else '0';
      pgpTxVcData(j).eof        <= '1' when pgpTxVcData(j).data = 1500 else '0';

      process ( pgpClk ) begin
         if rising_edge(pgpClk) then
            if pgpClkRstSw = '1' then
                  pgpTxVcData(j).data <= (others=>'0') after 1 ns;
               elsif pgpTxVcCtrl(j).ready = '1' then
                   if pgpTxVcData(j).data = 1500 then
                     pgpTxVcData(j).data <= (others=>'0') after 1 ns;
               else
                     pgpTxVcData(j).data <= pgpTxVcData(j).data + 1 after 1 ns;
               end if;
            end if;
         end if;
      end process;
   end generate;

   process ( pgpClk ) begin
      if rising_edge(pgpClk) then
         if r.countReset = '1' or pgpClkRstSw = '1' then
               cellErrorCnt <= (others=>'0') after 1 ns;
            elsif pgpRxOut.cellError = '1' and cellErrorCnt /= x"FFFFFFFF" then
               cellErrorCnt <= cellErrorCnt + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
               linkDownCnt  <= (others=>'0') after 1 ns;
            elsif pgpRxOut.linkDown = '1' and linkDownCnt /= x"FFFFFFFF" then
               linkDownCnt <= linkDownCnt + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
               linkErrorCnt <= (others=>'0') after 1 ns;
            elsif pgpRxOut.linkError = '1' and linkErrorCnt /= x"FFFFFFFF" then
               linkErrorCnt <= linkErrorCnt + 1 after 1 ns;
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
         RST                  => axiClkRst
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
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => pgpClk,
        asyncRst => axiClkRst,
        syncRst  => pgpClkRst
      );


   -- Reset Gen
   U_pgpClkRstSwGen : entity work.RstSync
      generic map (
         TPD_G           => 1 ns,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
      )
      port map (
        clk      => pgpClk,
        asyncRst => r.clkReset,
        syncRst  => pgpClkRstSw
      );

end architecture STRUCTURE;

