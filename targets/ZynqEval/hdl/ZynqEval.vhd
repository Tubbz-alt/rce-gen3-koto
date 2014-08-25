-------------------------------------------------------------------------------
-- ZynqEval.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity ZynqEval is
   port (
      i2cSda     : inout sl;
      i2cScl     : inout sl
   );
end ZynqEval;

architecture STRUCTURE of ZynqEval is
   signal sysClk125               : sl;
   signal sysClk125Rst            : sl;
   signal sysClk200               : sl;
   signal sysClk200Rst            : sl;
   signal axiClk                  : sl;
   signal axiClkRst               : sl;
   signal extAxilReadMaster       : AxiLiteReadMasterType;
   signal extAxilReadSlave        : AxiLiteReadSlaveType;
   signal extAxilWriteMaster      : AxiLiteWriteMasterType;
   signal extAxilWriteSlave       : AxiLiteWriteSlaveType;
   signal dmaClk                  : slv(2 downto 0);
   signal dmaClkRst               : slv(2 downto 0);
   signal dmaState                : RceDmaStateArray(2 downto 0);
   signal dmaObMaster             : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave              : AxiStreamSlaveArray(2 downto 0);
   signal dmaIbMaster             : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave              : AxiStreamSlaveArray(2 downto 0);
   signal writeRegister           : Slv32Array(0 downto 0);
   signal readRegister            : Slv32Array(0 downto 0);

   signal crcOut        : slv(31 downto 0);
   signal crcOutAdj     : slv(31 downto 0);
   signal crcDataValid  : sl;
   signal crcDataWidth  : slv(2 downto 0);
   signal crcIn         : slv(63 downto 0);
   signal crcInAdj      : slv(63 downto 0);
   signal crcReset      : sl;
   signal crcCount      : slv(15 downto 0);

   -- Debug Signals
   attribute dont_touch : string;

   attribute dont_touch of crcOut        : signal is "true";
   attribute dont_touch of crcDataValid  : signal is "true";
   attribute dont_touch of crcDataWidth  : signal is "true";
   attribute dont_touch of crcIn         : signal is "true";
   attribute dont_touch of crcInAdj      : signal is "true";
   attribute dont_touch of crcReset      : signal is "true";
   attribute dont_touch of crcCount      : signal is "true";

   constant TPD_C : time := 1 ns;

begin

   -- Core
   U_EvalCore: entity work.EvalCore
      generic map (
         TPD_G          => TPD_C,
         RCE_DMA_MODE_G => RCE_DMA_PPI_C,
         OLD_BSI_MODE_G => false
      )
      port map (
         i2cSda                   => i2cSda,
         i2cScl                   => i2cScl,
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
   U_AxiLiteEmpty: entity work.AxiLiteEmpty 
      port map (
         axiClk          => axiClk,
         axiClkRst       => axiClkRst,
         axiReadMaster   => extAxilReadMaster,
         axiReadSlave    => extAxilReadSlave,
         axiWriteMaster  => extAxilWriteMaster,
         axiWriteSlave   => extAxilWriteSlave,
         writeRegister   => writeRegister,
         readRegister    => readRegister
      );


   --------------------------------------------------
   -- PPI Loopback
   --------------------------------------------------
   dmaClk      <= (others=>sysClk125);
   dmaClkRst   <= (others=>sysClk125Rst);
   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;

   U_Crc32 : entity work.Crc32
      generic map (
         BYTE_WIDTH_G => 8
      ) port map (
         crcOut        => crcOut,
         crcClk        => axiClk,
         crcDataValid  => crcDataValid,
         crcDataWidth  => crcDataWidth,
         crcIn         => crcInAdj,
         crcReset      => crcReset
      ); 

   process ( axiClk ) begin

      if rising_edge(axiClk) then
         if axiClkRst = '1' or writeRegister(0)(0) = '1' then
            crcDataValid <= '0';
            crcDataWidth <= (others=>'0');
            crcIn        <= (others=>'0');
            crcReset     <= '0';
         else

            case crcCount is 

               when x"00FF" =>
                  crcDataValid <= '0';
                  crcDataWidth <= "111";
                  crcIn        <= x"1200000000c28001";
                  crcReset     <= '1';
               when x"0100" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"1200000000c28001";
                  crcReset     <= '0';
               when x"0101" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"42422600276ceef2";
                  crcReset     <= '0';
               when x"0102" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"0080000000000003";
                  crcReset     <= '0';
               when x"0103" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"0000066ceef21200";
                  crcReset     <= '0';
               when x"0104" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"eef2120000800000";
                  crcReset     <= '0';
               when x"0105" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"001400002880066c";
                  crcReset     <= '0';
               when x"0106" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "111";
                  crcIn        <= x"00000000000f0002";
                  crcReset     <= '0';
               when x"0107" =>
                  crcDataValid <= '1';
                  crcDataWidth <= "011";
                  crcIn        <= x"f0eb0b2200000000";
                  crcReset     <= '0';
               when others =>
                  crcDataValid <= '0';
                  crcDataWidth <= "111";
                  crcIn        <= (others=>'0');
                  crcReset     <= '0';
            end case;
         end if;
      end if;
   end process;

   --crcInAdj               <= crcIn;
   crcInAdj(63 downto 56) <= crcIn(7  downto  0);
   crcInAdj(55 downto 48) <= crcIn(15 downto  8);
   crcInAdj(47 downto 40) <= crcIn(23 downto 16);
   crcInAdj(39 downto 32) <= crcIn(31 downto 24);
   crcInAdj(31 downto 24) <= crcIn(39 downto 32);
   crcInAdj(23 downto 16) <= crcIn(47 downto 40);
   crcInAdj(15 downto  8) <= crcIn(55 downto 48);
   crcInAdj(7  downto  0) <= crcIn(63 downto 56);

   crcOutAdj <= crcOut;
   --crcOutAdj(31 downto 24) <= crcOut(7  downto  0);
   --crcOutAdj(23 downto 16) <= crcOut(15 downto  8);
   --crcOutAdj(15 downto  8) <= crcOut(23 downto 16);
   --crcOutAdj(7  downto  0) <= crcOut(31 downto 24);

   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            crcCount <= (others=>'0');
         else
            crcCount <= crcCount + 1;
         end if;
      end if;
   end process;

end architecture STRUCTURE;

