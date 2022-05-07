library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity comparator is
    
	port (	a, b : in std_logic_vector(15 downto 0);
		y : out std_logic);
end comparator;

architecture rtl of comparator is
begin
    y <= '1' when unsigned(a) < unsigned(b) else '0';
end rtl;
