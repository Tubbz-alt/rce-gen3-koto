-------------------------------------------------------------------------------
-- ZynqDpm.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;

entity ZynqDpm is
   port (

      -- Debug
      led          : out   std_logic_vector(1 downto 0);

      -- I2C
      i2cSda       : inout std_logic;
      i2cScl       : inout std_logic;

      -- Ethernet
      ethRxP      : in    std_logic;
      ethRxM      : in    std_logic;
      ethTxP      : out   std_logic;
      ethTxM      : out   std_logic;

      -- RTM High Speed
      --dpmToRtmHsP : out   std_logic_vector(11 downto 0);
      --dpmToRtmHsM : out   std_logic_vector(11 downto 0);
      --rtmToDpmHsP : in    std_logic_vector(11 downto 0);
      --rtmToDpmHsM : in    std_logic_vector(11 downto 0);
      --hsRefClkP   : in    std_logic_vector(3  downto 0);
      --hsRefClkM   : in    std_logic_vector(3  downto 0);

      -- RTM Low Speed
      dpmToRtmLsP  : inout std_logic_vector(3  downto 0);
      dpmToRtmLsM  : inout std_logic_vector(3  downto 0);

      -- DPM Signals
      dpmToDtmP    : inout std_logic_vector(1  downto 0);
      dpmToDtmM    : inout std_logic_vector(1  downto 0);

      -- User clock
      userClkP     : in    std_logic;
      userClkM     : in    std_logic

   );
end ZynqDpm;

architecture STRUCTURE of ZynqDpm is

   -- Local Signals
   signal localBusSlave      : LocalBusSlaveVector(15 downto 8);
   signal ethFromArm         : EthFromArmVector(1 downto 0);
   signal ethToArm           : EthToArmVector(1 downto 0);
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
         localBusMaster     => open,
         localBusSlave      => localBusSlave,
         ethFromArm         => ethFromArm,
         ethToArm           => ethToArm
      );

   localBusSlave <= (others=>LocalBusSlaveInit);
   led <= "00";

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
   --dpmToRtmHsP : out   std_logic_vector(11 downto 0);
   --dpmToRtmHsM : out   std_logic_vector(11 downto 0);
   --rtmToDtmHsP : in    std_logic_vector(11 downto 0);
   --rtmToDtmHsM : in    std_logic_vector(11 downto 0);
   --hsRefClkP   : in    std_logic_vector(3  downto 0);
   --hsRefClkM   : in    std_logic_vector(3  downto 0);

   -- RTM Low Speed
   dpmToRtmLsP  <= (others=>'Z');
   dpmToRtmLsM  <= (others=>'Z');

   -- DPM Signals
   dpmToDtmP   <= (others=>'Z');
   dpmToDtmM   <= (others=>'Z');

   -- User clock
   --userClkP     : in    std_logic;
   --userClkM     : in    std_logic;

end architecture STRUCTURE;

