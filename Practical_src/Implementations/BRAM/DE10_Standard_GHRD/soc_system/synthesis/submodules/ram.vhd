library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ram is
	port(	clk, rst, wr : in std_logic;
		row, col : in std_logic_vector(15 downto 0);
		din : in std_logic_vector(15 downto 0);
		y : out std_logic_vector(15 downto 0));
end ram;

architecture rtl of ram is

	type ram_type is array (0 to 2, 0 to 2) of std_logic_vector(15 downto 0);
	signal program: ram_type := (others =>(others => (others => '0'))); 

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if ( rst = '1') then 
				program <= (others =>(others => (others => '0')));
			else
				if (wr = '1') then
					program(conv_integer(unsigned(row)), conv_integer(unsigned(col))) <= din;
				end if;
			end if;
		end if;
	end process;
	y <= program(conv_integer(unsigned(row)), conv_integer(unsigned(col)));
end rtl;
