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
use work.Pgp2bPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity DtmRtmTest is
   generic (
      TPD_G               : time             := 1 ns;
      AXIL_BASE_ADDRESS_G : slv(31 downto 0) := x"00000000"
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

   constant MASTERS_COUNT_C : integer := 2;

   -- Local Signals
   signal locRefClk          : sl;
   signal locRefClkG         : sl;
   signal rtmClkCount        : slv(5 downto 0);
   signal rtmClkOut          : slv(5 downto 0);
   signal tmpAxiReadMaster   : AxiLiteReadMasterType;
   signal tmpAxiReadSlave    : AxiLiteReadSlaveType;
   signal tmpAxiWriteMaster  : AxiLiteWriteMasterType;
   signal tmpAxiWriteSlave   : AxiLiteWriteSlaveType;
   signal pgpAxiReadMaster   : AxiLiteReadMasterArray(MASTERS_COUNT_C-1 downto 0);
   signal pgpAxiReadSlave    : AxiLiteReadSlaveArray(MASTERS_COUNT_C-1 downto 0);
   signal pgpAxiWriteMaster  : AxiLiteWriteMasterArray(MASTERS_COUNT_C-1 downto 0);
   signal pgpAxiWriteSlave   : AxiLiteWriteSlaveArray(MASTERS_COUNT_C-1 downto 0);
   signal pgpClkRst          : sl;
   signal pgpClkRstSw        : sl;
   signal pgpClk             : sl;
   signal ipgpClk            : sl;
   signal pgpTxMmcmReset     : sl;
   signal pgpTxMmcmLocked    : sl;
   signal pgpRxIn            : Pgp2bRxInType;
   signal pgpRxOut           : Pgp2bRxOutType;
   signal pgpTxIn            : Pgp2bTxInType;
   signal pgpTxOut           : Pgp2bTxOutType;
   signal pgpTxMasters       : AxiStreamMasterArray(3 downto 0);
   signal pgpTxSlaves        : AxiStreamSlaveArray(3 downto 0);
   signal pgpRxMasters       : AxiStreamMasterArray(3 downto 0);
   signal pgpRxCtrl          : AxiStreamCtrlArray(3 downto 0);
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

   constant MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray := 
      genAxiLiteConfig ( MASTERS_COUNT_C, x"00000000" , 16, 12 );
      --genAxiLiteConfig ( MASTERS_COUNT_C, AXIL_BASE_ADDRESS_G , 16, 12 );

begin

   --------------------------------------------------
   -- Registers
   --------------------------------------------------

   U_AxiLiteAsync : entity work.AxiLiteAsync 
      generic map (
         TPD_G            => TPD_G,
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
         mAxiReadMaster    => tmpAxiReadMaster,
         mAxiReadSlave     => tmpAxiReadSlave,
         mAxiWriteMaster   => tmpAxiWriteMaster,
         mAxiWriteSlave    => tmpAxiWriteSlave
      );

   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => MASTERS_COUNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => MASTERS_CONFIG_C
      ) port map (
         axiClk              => pgpClk,
         axiClkRst           => pgpClkRst,
         sAxiWriteMasters(0) => tmpAxiWriteMaster,
         sAxiWriteSlaves(0)  => tmpAxiWriteSlave,
         sAxiReadMasters(0)  => tmpAxiReadMaster,
         sAxiReadSlaves(0)   => tmpAxiReadSlave,
         mAxiWriteMasters    => pgpAxiWriteMaster,
         mAxiWriteSlaves     => pgpAxiWriteSlave,
         mAxiReadMasters     => pgpAxiReadMaster,
         mAxiReadSlaves      => pgpAxiReadSlave
      );

   -- Sync
   process (pgpClk) is
   begin
      if (rising_edge(pgpClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (pgpClkRst, pgpAxiReadMaster(0), pgpAxiWriteMaster(0), r, pgpTxMmcmLocked, pgpTxMmcmReset, 
            pgpRxOut, cellErrorCnt, linkDownCnt, linkErrorCnt, txCount, rxCount, eofeCount, clockCount )
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      axiSlaveWaitTxn(pgpAxiWriteMaster(0), pgpAxiReadMaster(0), v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         if pgpAxiWriteMaster(0).awaddr(11 downto 0) = x"000" then
            v.countReset := pgpAxiWriteMaster(0).wdata(0);

         elsif pgpAxiWriteMaster(0).awaddr(11 downto 0) = x"004" then
            v.loopEnable := pgpAxiWriteMaster(0).wdata(2 downto 0);

         elsif pgpAxiWriteMaster(0).awaddr(11 downto 0) = x"010" then
            v.pgpTxReset := pgpAxiWriteMaster(0).wdata(0);
            v.pgpRxReset := pgpAxiWriteMaster(0).wdata(16);

         elsif pgpAxiWriteMaster(0).awaddr(11 downto 0) = x"014" then
            v.clkReset := pgpAxiWriteMaster(0).wdata(0);
         end if;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         if pgpAxiReadMaster(0).araddr(11 downto 0)  = x"000" then
            v.axiReadSlave.rdata(0) := r.countReset;

         elsif pgpAxiReadMaster(0).araddr(11 downto 0)  = x"004" then
            v.axiReadSlave.rdata(2 downto 0) := r.loopEnable;

         elsif pgpAxiReadMaster(0).araddr(11 downto 0)  = x"008" then
            v.axiReadSlave.rdata := clockCount;

         elsif pgpAxiReadMaster(0).araddr(11 downto 0)  = x"00C" then
            v.axiReadSlave.rdata(16) := pgpTxMmcmLocked;
            v.axiReadSlave.rdata(0)  := pgpTxMmcmReset;

         elsif pgpAxiReadMaster(0).araddr(11 downto 0)  = x"010" then
            v.axiReadSlave.rdata(16) := r.pgpRxReset;
            v.axiReadSlave.rdata(0)  := r.pgpTxReset;

         elsif pgpAxiReadMaster(0).araddr(11 downto 0)  = x"014" then
            v.axiReadSlave.rdata(0) := r.clkReset;

         elsif pgpAxiReadMaster(0).araddr(11 downto 9)  = "001" then
            case pgpAxiReadMaster(0).araddr(4 downto 2) is

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
      pgpAxiReadSlave(0)  <= r.axiReadSlave;
      pgpAxiWriteSlave(0) <= r.axiWriteSlave;
      
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
         pgpTxMasters      => pgpTxMasters,
         pgpTxSlaves       => pgpTxSlaves,
         -- Frame Receive Interface - 1 Lane, Array of 4 VCs
         pgpRxMasters      => pgpRxMasters,
         pgpRxMasterMuxed  => open,
         pgpRxCtrl         => pgpRxCtrl
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
   pgpRxIn.loopback <= (others=>'0');

   -- Tx Control
   pgpTxIn.flush        <= '0';
   pgpTxIn.opCodeEn     <= '0';
   pgpTxIn.opCode       <= (others=>'0');
   pgpTxIn.locData      <= (others=>'0');

   -- Counters
   process ( pgpClk ) begin
      if rising_edge(pgpClk) then

         if r.countReset = '1' or pgpClkRstSw = '1' then
            txCount <= (others=>'0') after 1 ns;
         elsif pgpTxOut.frameTx = '1' then
            txCount <= txCount + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
            rxCount <= (others=>'0') after 1 ns;
         elsif pgpRxOut.frameRx = '1' then
            rxCount <= rxCount + 1 after 1 ns;
         end if;

         if r.countReset = '1' or pgpClkRstSw = '1' then
            eofeCount <= (others=>'0') after 1 ns;
         elsif pgpRxOut.frameRxErr = '1' then
            eofeCount <= eofeCount + 1 after 1 ns;
         end if;

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

   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map (
         TPD_G                      => TPD_G,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         XIL_DEVICE_G               => "7SERIES",
         BRAM_EN_G                  => true,
         USE_BUILT_IN_G             => false,
         GEN_SYNC_FIFO_G            => false,
         CASCADE_SIZE_G             => 1,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 16),
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 256,
         MASTER_AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 0
      ) port map (

         mAxisClk     => pgpClk,
         mAxisRst     => pgpClkRst,
         mAxisSlave   => pgpTxSlaves(0),
         mAxisMaster  => pgpTxMasters(0),
         locClk       => pgpClk,
         locRst       => pgpClkRst,
         trig         => '1',
         packetLength => x"00000800",
         busy         => open,
         tDest        => (others=>'0'),
         tId          => (others=>'0')
      );

   pgpTxMasters(3 downto 1) <= (others=>AXI_STREAM_MASTER_INIT_C);


   U_SsiPrbsRx: entity work.SsiPrbsRx 
      generic map (
         TPD_G                      => 1 ns,
         STATUS_CNT_WIDTH_G         => 32,
         AXI_ERROR_RESP_G           => AXI_RESP_OK_C,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         CASCADE_SIZE_G             => 1,
         XIL_DEVICE_G               => "7SERIES",
         BRAM_EN_G                  => true,
         USE_BUILT_IN_G             => false,
         GEN_SYNC_FIFO_G            => false,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 16),
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 256,
         SLAVE_AXI_STREAM_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         SLAVE_AXI_PIPE_STAGES_G    => 0,
         MASTER_AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 0
      ) port map (
         sAxisClk        => pgpClk,
         sAxisRst        => pgpClkRst,
         sAxisMaster     => pgpRxMasters(0),
         sAxisSlave      => open,
         sAxisCtrl       => pgpRxCtrl(0),
         mAxisClk        => pgpClk,
         mAxisRst        => pgpClkRst,
         mAxisMaster     => open,
         mAxisSlave      => AXI_STREAM_SLAVE_FORCE_C,
         axiClk          => pgpCLk,
         axiRst          => pgpClkRst,
         axiReadMaster   => pgpAxiReadMaster(1),
         axiReadSlave    => pgpAxiReadSlave(1),
         axiWriteMaster  => pgpAxiWriteMaster(1),
         axiWriteSlave   => pgpAxiWriteSlave(1),
         updatedResults  => open,
         busy            => open,
         errMissedPacket => open,
         errLength       => open,
         errDataBus      => open,
         errEofe         => open,
         errWordCnt      => open,
         errbitCnt       => open,
         packetRate      => open,
         packetLength    => open
      ); 

   pgpRxCtrl(3 downto 1) <= (others=>AXI_STREAM_CTRL_UNUSED_C);

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

