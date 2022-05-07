library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ker_ram is
	port(clk, wr : in std_logic;
		row, col : in std_logic_vector(15 downto 0);
		din : in std_logic_vector(15 downto 0);
		y : out std_logic_vector(15 downto 0);
		col_count: in std_logic_vector(15 downto 0));
end ker_ram;

architecture rtl of ker_ram is

	-- 0 to (row+1*col+1)-1
	type ram_type is array (0 to 8) of std_logic_vector(15 downto 0);
	signal program: ram_type;
	
	-- col+1
	signal temp_col_count: unsigned(15 downto 0);
	signal addr: unsigned(31 downto 0);

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (wr = '1') then
				program(conv_integer(addr)) <= din;
			end if;
			y <= program(conv_integer(addr));
		end if;
	end process;

addr <= ((unsigned(row) * temp_col_count) + unsigned(col));
temp_col_count <= unsigned(col_count) + 1;
end rtl;
