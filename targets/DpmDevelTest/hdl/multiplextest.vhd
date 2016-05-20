--------------------------------------------------------------
-- Serializer for High Speed I/O board (ATLAS Pixel teststand)
-- Martin Kocian 01/2009
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;
use work.arraytype.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.StdRtlPkg.all;
--------------------------------------------------------------


entity multiplextest is
generic(
        AXI_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(2));
port(   clk:        in std_logic;
        rst:        in std_logic;
        triggerin:  in std_logic;
        maxlength: in integer;
        mAxisMaster: out AxiStreamMasterType;
        mAxisSlave: in AxiStreamSlaveType 
);
end multiplextest;

--------------------------------------------------------------

architecture MULTIPLEXDATA of multiplextest is


  type state_type is (idle, sending, waiting);
  type RegType is record
    txMaster   : AxiStreamMasterType;
    state      : state_type;
    counter: std_logic_vector(7 downto 0);
    last: std_logic;
    repcounter: std_logic_vector(3 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType :=(
     txMaster => AXI_STREAM_MASTER_INIT_C,
     state => idle,
     counter => (others =>'0'),
     last => '0',
     repcounter => (others => '0')
     );
    
  signal enabled: std_logic:='1';
  
  signal r   : RegType := REG_INIT_C;
  signal rin : RegType;

begin

  enabled<=mAxisSlave.tReady;
  mAxisMaster<=r.txMaster;

  comb: process (r, triggerin, enabled, rst) is
    variable v: RegType;
  begin
    v := r;
    case r.state is
      when idle =>
        if(triggerin='1')then
          v.state:=sending;
          v.counter:=toSlv(maxlength-2, 8);
          ssiSetUserSof(AXI_CONFIG_C, v.txMaster, '1');
          v.txMaster.tData(15 downto 0) := v.counter & v.counter; 
          v.txMaster.tValid:='1';
        end if;
      when sending =>
        if(enabled='1')then
          v.counter:=unsigned(r.counter)-1;
          v.txMaster.tData(15 downto 0) := v.counter & v.counter; 
          ssiSetUserSof(AXI_CONFIG_C, v.txMaster, '0');
          if(r.last='1')then
            v.last:='0';
            v.txMaster.tLast:='0';
            v.txMaster.tValid:='0';
            v.state:=waiting;
            v.repcounter:=x"f";
          elsif(r.counter=x"00") then --EOF
            v.txMaster.tLast:='1';
            v.last:='1';
          end if;
        end if;
      when waiting =>
        if(r.repcounter=x"0")then
          v.state:=idle;
        else
          v.repcounter:=unsigned(r.repcounter)-1;
        end if;
      end case;

      if (rst='1')then
        v:= REG_INIT_C;
      end if;

      rin <= v;

  end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq;

end MULTIPLEXDATA;
