library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity multiplier is
    
    port (a, b : in std_logic_vector(15 downto 0);
    y : out std_logic_vector(31 downto 0));
end multiplier;

architecture rtl of multiplier is
	signal y_s : signed(31 downto 0);
begin

	y_s <= signed(a) * signed(b);
	y <= std_logic_vector(y_s);

end rtl;
