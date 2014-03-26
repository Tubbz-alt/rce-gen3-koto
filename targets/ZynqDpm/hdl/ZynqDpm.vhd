-------------------------------------------------------------------------------
-- ZynqDpm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity ZynqDpm is
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
end ZynqDpm;

architecture STRUCTURE of ZynqDpm is

   -- Local Signals
   signal ppiClk               : slv(3 downto 0);
   signal ppiOnline            : slv(3 downto 0);
   signal ppiReadToFifo        : PpiReadToFifoArray(3 downto 0);
   signal ppiReadFromFifo      : PpiReadFromFifoArray(3 downto 0);
   signal ppiWriteToFifo       : PpiWriteToFifoArray(3 downto 0);
   signal ppiWriteFromFifo     : PpiWriteFromFifoArray(3 downto 0);
   signal axiClk             : sl;
   signal axiClkRst          : sl;
   signal sysClk125          : sl;
   signal sysClk125Rst       : sl;
   signal sysClk200          : sl;
   signal sysClk200Rst       : sl;
   signal timingCode         : slv(7 downto 0);
   signal timingCodeEn       : sl;
   signal fbCode             : slv(7 downto 0);
   signal fbCodeEn           : sl;
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
   U_DpmCore: entity work.DpmCore 
      port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         ethRxP                   => ethRxP,
         ethRxM                   => ethRxM,
         ethTxP                   => ethTxP,
         ethTxM                   => ethTxM,
         axiClk                   => axiClk,
         axiClkRst                => axiClkRst,
         sysClk125                => sysClk125,
         sysClk125Rst             => sysClk125Rst,
         sysClk200                => sysClk200,
         sysClk200Rst             => sysClk200Rst,
         localAxiReadMaster       => topAxiReadMaster,
         localAxiReadSlave        => topAxiReadSlave,
         localAxiWriteMaster      => topAxiWriteMaster,
         localAxiWriteSlave       => topAxiWriteSlave,
         ppiClk                   => ppiClk,
         ppiOnline                => ppiOnline,
         ppiReadToFifo            => ppiReadToFifo,
         ppiReadFromFifo          => ppiReadFromFifo,
         ppiWriteToFifo           => ppiWriteToFifo,
         ppiWriteFromFifo         => ppiWriteFromFifo,
         clkSelA                  => clkSelA,
         clkSelB                  => clkSelB
      );


   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xA0000000 - 0xAFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => 1 ns,
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
   U_LoopGen : for i in 0 to 3 generate

      ppiClk(i) <= axiClk;

      ppiWriteToFifo(i).data    <= ppiReadFromFifo(i).data;
      ppiWriteToFifo(i).size    <= ppiReadFromFifo(i).size;
      ppiWriteToFifo(i).ftype   <= ppiReadFromFifo(i).ftype;
      ppiWriteToFifo(i).mgmt    <= ppiReadFromFifo(i).mgmt;
      ppiWriteToFifo(i).eoh     <= ppiReadFromFifo(i).eoh;
      ppiWriteToFifo(i).eof     <= ppiReadFromFifo(i).eof;
      ppiWriteToFifo(i).err     <= '0';

      ppiWriteToFifo(i).valid   <= ppiReadFromFifo(i).valid;

      ppiReadToFifo(i).read     <= ppiReadFromFifo(i).valid;

   end generate;


   --------------------------------------------------
   -- Timing Signals
   --------------------------------------------------
   U_DpmTimingSink : entity work.DpmTimingSink 
      generic map (
         TPD_G => 1 ns
      ) port map (
         axiClk                    => axiClk,
         axiClkRst                 => axiClkRst,
         axiReadMaster             => intAxiReadMaster(0),
         axiReadSlave              => intAxiReadSlave(0),
         axiWriteMaster            => intAxiWriteMaster(0),
         axiWriteSlave             => intAxiWriteSlave(0),
         sysClk200                 => sysClk200,
         sysClk200Rst              => sysClk200Rst,
         dtmClkP                   => dtmClkP,
         dtmClkM                   => dtmClkM,
         dtmFbP                    => dtmFbP,
         dtmFbM                    => dtmFbM,
         distClk                   => open,
         distClkRst                => open,
         timingCode                => timingCode,
         timingCodeEn              => timingCodeEn,
         fbCode                    => fbCode,
         fbCodeEn                  => fbCodeEn,
         led                       => led
      );

   fbCode   <= timingCode;
   fbCodeEn <= timingCodeEn;


   --------------------------------------------------
   -- RTM Testing
   --------------------------------------------------

   U_RtmTest : entity work.DpmRtmTest 
      port map (
         sysClk200           => sysClk200,
         sysClk200Rst        => sysClk200Rst,
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         topAxiReadMaster    => intAxiReadMaster(1),
         topAxiReadSlave     => intAxiReadSlave(1),
         topAxiWriteMaster   => intAxiWriteMaster(1),
         topAxiWriteSlave    => intAxiWriteSlave(1),
         locRefClkP          => locRefClkP(1),
         locRefClkM          => locRefClkM(1),
         dpmToRtmHsP         => dpmToRtmHsP,
         dpmToRtmHsM         => dpmToRtmHsM,
         rtmToDpmHsP         => rtmToDpmHsP,
         rtmToDpmHsM         => rtmToDpmHsM
      );


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
   --locRefClkP   : in    slv(1  downto 0);
   --locRefClkM   : in    slv(1  downto 0);
   --dtmRefClkP   : in    sl;
   --dtmRefClkM   : in    sl;

   -- DTM Signals
   --dtmClkP      : in    slv(1  downto 0);
   --dtmClkM      : in    slv(1  downto 0);
   --dtmFbP       : out   sl;
   --dtmFbM       : out   sl;

   -- Clocks
   --signal axiClk         : sl;
   --signal axiClkRst      : sl;
   --signal sysClk125      : sl;
   --signal sysClk125Rst   : sl;
   --signal sysClk200      : sl;
   --signal sysClk200Rst   : sl;

end architecture STRUCTURE;

