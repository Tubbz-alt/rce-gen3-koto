-------------------------------------------------------------------------------
-- ZynqDtm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;

entity ZynqDtm is
   port (

      -- Debug
      led          : out   std_logic_vector(1 downto 0);

      -- I2C
      i2cSda       : inout std_logic;
      i2cScl       : inout std_logic;

      -- PCI Exress
      pciRefClkP   : in    std_logic;
      pciRefClkM   : in    std_logic;
      pcieRxP      : in    std_logic;
      pcieRxM      : in    std_logic;
      pcieTxP      : out   std_logic;
      pcieTxM      : out   std_logic;
      pcieResetL   : out   std_logic;

      -- Ethernet
      ethRxP      : in    std_logic;
      ethRxM      : in    std_logic;
      ethTxP      : out   std_logic;
      ethTxM      : out   std_logic;

      -- RTM High Speed
      --dtmToRtmHsP : out   std_logic_vector(1 downto 0);
      --dtmToRtmHsM : out   std_logic_vector(1 downto 0);
      --rtmToDtmHsP : in    std_logic_vector(1 downto 0);
      --rtmToDtmHsM : in    std_logic_vector(1 downto 0);
      --hsRefClkP   : in    std_logic;
      --hsRefClkM   : in    std_logic;

      -- RTM Low Speed
      dtmToRtmLsP  : inout std_logic_vector(11 downto 0);
      dtmToRtmLsM  : inout std_logic_vector(11 downto 0);

      -- DPM Signals
      dpm0ToDtmP   : inout std_logic_vector(3  downto 0);
      dpm0ToDtmM   : inout std_logic_vector(3  downto 0);
      dpm1ToDtmP   : inout std_logic_vector(3  downto 0);
      dpm1ToDtmM   : inout std_logic_vector(3  downto 0);
      dpm2ToDtmP   : inout std_logic_vector(3  downto 0);
      dpm2ToDtmM   : inout std_logic_vector(3  downto 0);
      dpm3ToDtmP   : inout std_logic_vector(3  downto 0);
      dpm3ToDtmM   : inout std_logic_vector(3  downto 0);

      -- User clock
      userClkP     : in    std_logic;
      userClkM     : in    std_logic;

      -- Backplane Clocks
      bpClkIn      : in    std_logic_vector(5 downto 0);
      --bpClkOut     : out   std_logic_vector(5 downto 0);

      -- IPMI
      dtmToIpmiP   : inout std_logic_vector(1 downto 0);
      dtmToIpmiM   : inout std_logic_vector(1 downto 0)
   );
end ZynqDtm;

architecture STRUCTURE of ZynqDtm is

   -- Local Signals
   signal localBusMaster     : LocalBusMasterVector(15 downto 8);
   signal localBusSlave      : LocalBusSlaveVector(15 downto 8);
   signal ethFromArm         : EthFromArmVector(1 downto 0);
   signal ethToArm           : EthToArmVector(1 downto 0);
   signal pciRefClk          : std_logic;
   signal ponResetL          : std_logic;
   signal axiClk             : std_logic;
   signal axiClkRst          : std_logic;
   signal sysClk125          : std_logic;
   signal sysClk200          : std_logic;
   signal sysClk200Rst       : std_logic;

begin

   --------------------------------------------------
   -- Core
   --------------------------------------------------
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         DEBUG_EN_G   => false,
         AXI_CLKDIV_G => 4.7
      ) port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         axiClk             => axiClk,
         axiClkRst          => axiClkRst,
         sysClk125          => sysClk125,
         sysClk125Rst       => open,
         sysClk200          => sysClk200,
         sysClk200Rst       => sysClk200Rst,
         localBusMaster     => localBusMaster,
         localBusSlave      => localBusSlave,
         ethFromArm         => ethFromArm,
         ethToArm           => ethToArm
      );

   localBusSlave(14 downto 8)  <= (others=>LocalBusSlaveInit);

   led <= "00";

   --------------------------------------------------
   -- PCI Express
   --------------------------------------------------

   U_ZynqPcieMaster : entity work.ZynqPcieMaster 
      port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         localBusMaster  => localBusMaster(15),
         localBusSlave   => localBusSlave(15),
         pciRefClk       => pciRefClk,
         pcieResetL      => pcieResetL,
         pcieRxP         => pcieRxP,
         pcieRxM         => pcieRxM,
         pcieTxP         => pcieTxP,
         pcieTxM         => pcieTxM
      );

   -- Input clock
   U_PcieRefClk : IBUFDS_GTE2
      port map(
         O       => pciRefClk,
         ODIV2   => open,
         I       => pciRefClkP,
         IB      => pciRefClkM,
         CEB     => '0'
      );

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_ZynqEthernet : entity work.ZynqEthernet 
      port map (
         sysClk125                => sysClk125,
         sysClk200                => sysClk200,
         sysClk200Rst             => sysClk200Rst,
         ethFromArm               => ethFromArm(0),
         ethToArm                 => ethToArm(0),
         ethRxP                   => ethRxP,
         ethRxM                   => ethRxM,
         ethTxP                   => ethTxP,
         ethTxM                   => ethTxM
      );

    ethToArm(1) <= EthToArmInit;

   --------------------------------------------------
   -- Unused Signals
   --------------------------------------------------

   -- RTM High Speed
   --dtmToRtmHsP : out   std_logic_vector(1 downto 0);
   --dtmToRtmHsM : out   std_logic_vector(1 downto 0);
   --rtmToDtmHsP : in    std_logic_vector(1 downto 0);
   --rtmToDtmHsM : in    std_logic_vector(1 downto 0);
   --hsRefClkP   : in    std_logic;
   --hsRefClkM   : in    std_logic;

   -- RTM Low Speed
   dtmToRtmLsP  <= (others=>'Z');
   dtmToRtmLsM  <= (others=>'Z');

   -- DPM Signals
   dpm0ToDtmP   <= (others=>'Z');
   dpm0ToDtmM   <= (others=>'Z');
   dpm1ToDtmP   <= (others=>'Z');
   dpm1ToDtmM   <= (others=>'Z');
   dpm2ToDtmP   <= (others=>'Z');
   dpm2ToDtmM   <= (others=>'Z');
   dpm3ToDtmP   <= (others=>'Z');
   dpm3ToDtmM   <= (others=>'Z');

   -- User clock
   --userClkP     : in    std_logic;
   --userClkM     : in    std_logic;

   -- Backplane Clocks
   --bpClkIn      : in    std_logic_vector(5 downto 0);
   --bpClkOut     <= (others=>'0');

   -- IPMI
   dtmToIpmiP   <= (others=>'Z');
   dtmToIpmiM   <= (others=>'Z');

end architecture STRUCTURE;

