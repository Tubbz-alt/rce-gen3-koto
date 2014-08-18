-------------------------------------------------------------------------------
-- Dpm10G.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity Dpm10G is
   port (

      -- Debug
      led          : out   slv(1 downto 0);

      -- I2C
      i2cSda       : inout sl;
      i2cScl       : inout sl;

      -- Ethernet
      ethRxP       : in    slv(3 downto 0);
      ethRxM       : in    slv(3 downto 0);
      ethTxP       : out   slv(3 downto 0);
      ethTxM       : out   slv(3 downto 0);
      ethRefClkP   : in    sl;
      ethRefClkM   : in    sl;

      -- RTM High Speed
      --dpmToRtmHsP  : out   slv(11 downto 0);
      --dpmToRtmHsM  : out   slv(11 downto 0);
      --rtmToDpmHsP  : in    slv(11 downto 0);
      --rtmToDpmHsM  : in    slv(11 downto 0);

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
end Dpm10G;

architecture STRUCTURE of Dpm10G is

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
   signal dmaClk             : slv(2 downto 0);
   signal dmaClkRst          : slv(2 downto 0);
   signal dmaState           : RceDmaStateArray(2 downto 0);
   signal dmaObMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave         : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster        : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave         : AxiStreamSlaveArray(2 downto 0);

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_DpmCore: entity work.DpmCore 
      generic map (
         TPD_G          => TPD_C,
         RCE_DMA_MODE_G => RCE_DMA_PPI_C,
         OLD_BSI_MODE_G => false,
         ETH_10G_EN_G   => true
      ) port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
         ethRxP                   => ethRxP,
         ethRxM                   => ethRxM,
         ethTxP                   => ethTxP,
         ethTxM                   => ethTxM,
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
         userInterrupt            => (others=>'0')
      );

   -- Empty AXI Slave
   -- 0xA0000000 - 0xAFFFFFFF
   U_AxiLiteEmpty: entity work.AxiLiteEmpty 
      port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         axiReadMaster   => extAxilReadMaster,
         axiReadSlave    => extAxilReadSlave,
         axiWriteMaster  => extAxilWriteMaster,
         axiWriteSlave   => extAxilWriteSlave
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk      <= (others=>sysClk125);
   dmaClkRst   <= (others=>sysClk125Rst);
   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;

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

