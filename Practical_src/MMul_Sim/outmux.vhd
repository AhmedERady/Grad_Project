library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity outmux is

    port (s : in std_logic;
    	  a, b : in std_logic_vector(31 downto 0);
    	  y : out std_logic_vector(31 downto 0));

end outmux;

architecture rtl of outmux is
begin

    y <= a when s = '0' else b; 

end rtl;
