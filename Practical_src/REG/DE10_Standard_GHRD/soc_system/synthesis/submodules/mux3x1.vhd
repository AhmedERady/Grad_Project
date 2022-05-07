library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity mux3x1 is

    port (s : in std_logic_vector(1 downto 0);
    	  a, b, c : in std_logic_vector(15 downto 0);
    	  y : out std_logic_vector(15 downto 0));

end mux3x1;

architecture rtl of mux3x1 is
begin

    y <= a when s = "00" else 
         b when s = "01" else c;

end rtl;
