library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity adder is
    
	port (	a, b : in std_logic_vector(15 downto 0);
		y : out std_logic_vector(15 downto 0));
end adder;

architecture rtl of adder is

	signal y_uns : unsigned(15 downto 0);

begin

	y_uns <= unsigned(a) + unsigned(b);
	y <= std_logic_vector(y_uns);

end rtl;
