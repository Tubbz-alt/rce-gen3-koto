library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;
use work.StdRtlPkg.all;

package arraytype is
    type    dataarray is array(31 downto 0) of std_logic_vector(17 downto 0);
    type    fei4array is array(31 downto 0) of std_logic_vector(24 downto 0);
    type    array10b is array(31 downto 0) of std_logic_vector(9 downto 0);
    type    hb is array(1 downto 0) of std_logic_vector(4 downto 0);
    type    hbpipeline is array(40 downto 0) of std_logic_vector(2 downto 0);
    type    hitbusoutput is array(1 downto 0) of std_logic_vector(31 downto 0);
  type CounterType is record
    timeoutcounter:        Slv8Array(15 downto 0);
    toomanyheadercounter:  Slv8Array(15 downto 0);
    skippedtriggercounter: Slv8Array(15 downto 0);
    badheadercounter:      Slv8Array(15 downto 0);
    missingtriggercounter: Slv8Array(15 downto 0);
    datanoheadercounter:   Slv8Array(15 downto 0);
    desynchcounter:        Slv8Array(15 downto 0);
    occounter:             Slv32Array(15 downto 0);
  end record CounterType;

end package arraytype; 
