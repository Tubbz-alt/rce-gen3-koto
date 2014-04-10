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
use work.AxiLitePkg.all;

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

   -- PPI Configurations
   constant PPI0_CONFIG_C : PpiConfigType := ( 
      obHeaderAddrWidth  => 9,
      obDataAddrWidth    => 9,
      obReadyThold       => 1,
      ibHeaderAddrWidth  => 9,
      ibHeaderPauseThold => 255,
      ibDataAddrWidth    => 9,
      ibDataPauseThold   => 255
   );

   constant PPI1_CONFIG_C : PpiConfigType := ( 
      obHeaderAddrWidth  => 9,
      obDataAddrWidth    => 9,
      obReadyThold       => 1,
      ibHeaderAddrWidth  => 9,
      ibHeaderPauseThold => 255,
      ibDataAddrWidth    => 9,
      ibDataPauseThold   => 255
   );

   constant PPI2_CONFIG_C : PpiConfigType := ( 
      obHeaderAddrWidth  => 9,
      obDataAddrWidth    => 9,
      obReadyThold       => 1,
      ibHeaderAddrWidth  => 9,
      ibHeaderPauseThold => 255,
      ibDataAddrWidth    => 9,
      ibDataPauseThold   => 255
   );

   -- PPI Configuration
   constant PPI_CONFIG_C : PpiConfigArray(2 downto 0) := (
      0 =>  PPI0_CONFIG_C,
      1 =>  PPI1_CONFIG_C,
      2 =>  PPI2_CONFIG_C
   );

   constant TPD_C : time := 1 ns;

   -- Local Signals
   signal ppiClk             : slv(2 downto 0);
   signal ppiOnline          : slv(2 downto 0);
   signal ppiReadToFifo      : PpiReadToFifoArray(2 downto 0);
   signal ppiReadFromFifo    : PpiReadFromFifoArray(2 downto 0);
   signal ppiWriteToFifo     : PpiWriteToFifoArray(2 downto 0);
   signal ppiWriteFromFifo   : PpiWriteFromFifoArray(2 downto 0);
   signal axiClk             : sl;
   signal axiClkRst          : sl;
   signal sysClk125          : sl;
   signal sysClk125Rst       : sl;
   signal sysClk200          : sl;
   signal sysClk200Rst       : sl;
   signal timingCode         : slv(7 downto 0);
   signal timingCodeEn       : sl;
   signal fbCode             : Slv8Array(7 downto 0);
   signal fbCodeEn           : slv(7 downto 0);
   signal intAxiReadMaster   : AxiLiteReadMasterArray(1 downto 0);
   signal intAxiReadSlave    : AxiLiteReadSlaveArray(1 downto 0);
   signal intAxiWriteMaster  : AxiLiteWriteMasterArray(1 downto 0);
   signal intAxiWriteSlave   : AxiLiteWriteSlaveArray(1 downto 0);
   signal topAxiReadMaster   : AxiLiteReadMasterType;
   signal topAxiReadSlave    : AxiLiteReadSlaveType;
   signal topAxiWriteMaster  : AxiLiteWriteMasterType;
   signal topAxiWriteSlave   : AxiLiteWriteSlaveType;

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DtmCore: entity work.DtmCore 
      generic map (
         TPD_G        => TPD_C,
         PPI_CONFIG_G => PPI_CONFIG_C
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         pciRefClkP          => pciRefClkP,
         pciRefClkM          => pciRefClkM,
         pciRxP              => pciRxP,
         pciRxM              => pciRxM,
         pciTxP              => pciTxP,
         pciTxM              => pciTxM,
         pciResetL           => pciResetL,
         ethRxP              => ethRxP,
         ethRxM              => ethRxM,
         ethTxP              => ethTxP,
         ethTxM              => ethTxM,
         clkSelA             => clkSelA,
         clkSelB             => clkSelB,
         ethRxCtrl           => ethRxCtrl,
         ethRxClk            => ethRxClk,
         ethRxDataA          => ethRxDataA,
         ethRxDataB          => ethRxDataB,
         ethRxDataC          => ethRxDataC,
         ethRxDataD          => ethRxDataD,
         ethTxCtrl           => ethTxCtrl,
         ethTxClk            => ethTxClk,
         ethTxDataA          => ethTxDataA,
         ethTxDataB          => ethTxDataB,
         ethTxDataC          => ethTxDataC,
         ethTxDataD          => ethTxDataD,
         ethMdc              => ethMdc,
         ethMio              => ethMio,
         ethResetL           => ethResetL,
         dtmToIpmiP          => dtmToIpmiP,
         dtmToIpmiM          => dtmToIpmiM,
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sysClk125           => sysClk125,
         sysClk125Rst        => sysClk125Rst,
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         localAxiReadMaster  => topAxiReadMaster,
         localAxiReadSlave   => topAxiReadSlave ,
         localAxiWriteMaster => topAxiWriteMaster,
         localAxiWriteSlave  => topAxiWriteSlave ,
         ppiClk              => ppiClk,
         ppiOnline           => ppiOnline,
         ppiReadToFifo       => ppiReadToFifo,
         ppiReadFromFifo     => ppiReadFromFifo,
         ppiWriteToFifo      => ppiWriteToFifo,
         ppiWriteFromFifo    => ppiWriteFromFifo
      );


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

            -- Channel 0 = 0xA0000000 - 0xA000FFFF : DTM Timing Source
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
         sAxiWriteMasters(0) => topAxiWriteMaster,
         sAxiWriteSlaves(0)  => topAxiWriteSlave,
         sAxiReadMasters(0)  => topAxiReadMaster,
         sAxiReadSlaves(0)   => topAxiReadSlave,
         mAxiWriteMasters    => intAxiWriteMaster,
         mAxiWriteSlaves     => intAxiWriteSlave,
         mAxiReadMasters     => intAxiReadMaster,
         mAxiReadSlaves      => intAxiReadSlave
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   U_LoopGen : for i in 0 to 2 generate

      ppiClk(i) <= axiClk;

      ppiWriteToFifo(i).data    <= ppiReadFromFifo(i).data;
      ppiWriteToFifo(i).size    <= ppiReadFromFifo(i).size;
      ppiWriteToFifo(i).ftype   <= ppiReadFromFifo(i).ftype;
      ppiWriteToFifo(i).eoh     <= ppiReadFromFifo(i).eoh;
      ppiWriteToFifo(i).eof     <= ppiReadFromFifo(i).eof;
      ppiWriteToFifo(i).err     <= '0';

      ppiWriteToFifo(i).valid   <= ppiReadFromFifo(i).valid;

      ppiReadToFifo(i).read     <= ppiReadFromFifo(i).valid;

   end generate;


   --------------------------------------------------
   -- Timing Signals
   --------------------------------------------------
   U_DtmTimingSource : entity work.DtmTimingSource 
      generic map (
         TPD_G => TPD_C
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         axiReadMaster       => intAxiReadMaster(0),
         axiReadSlave        => intAxiReadSlave(0),
         axiWriteMaster      => intAxiWriteMaster(0),
         axiWriteSlave       => intAxiWriteSlave(0),
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         distClk             => sysClk200,
         distClkRst          => sysClk200Rst,
         timingCode          => timingCode,
         timingCodeEn        => timingCodeEn,
         fbCode              => fbCode,
         fbCodeEn            => fbCodeEn,
         dpmClkP             => dpmClkP,
         dpmClkM             => dpmClkM,
         dpmFbP              => dpmFbP,
         dpmFbM              => dpmFbM,
         led                 => led
      );

   timingCode   <= (others=>'0');
   timingCodeEn <= '0';
   --signal fbCode         : Slv8(7 downto 0);
   --signal fbCodeEn       : slv(7 downto 0);


   --------------------------------------------------
   -- RTM Testing
   --------------------------------------------------

   U_RtmTest : entity work.DtmRtmTest 
      generic map (
         TPD_G => TPD_C
      ) port map (
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         topAxiReadMaster    => intAxiReadMaster(1),
         topAxiReadSlave     => intAxiReadSlave(1),
         topAxiWriteMaster   => intAxiWriteMaster(1),
         topAxiWriteSlave    => intAxiWriteSlave(1),
         locRefClkP          => locRefClkP,
         locRefClkM          => locRefClkM,
         dtmToRtmHsP         => dtmToRtmHsP,
         dtmToRtmHsM         => dtmToRtmHsM,
         rtmToDtmHsP         => rtmToDtmHsP,
         rtmToDtmHsM         => rtmToDtmHsM,
         dtmToRtmLsP         => dtmToRtmLsP,
         dtmToRtmLsM         => dtmToRtmLsM
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

end architecture STRUCTURE;

