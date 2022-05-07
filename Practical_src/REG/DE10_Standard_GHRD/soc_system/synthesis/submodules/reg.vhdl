library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity reg is
port(
	clk: 		in 	std_logic;
	rst: 		in 	std_logic;
	wr_en: 		in 	std_logic;
	reg_in: 	in 	std_logic_vector(31 downto 0);
	reg_out: 	out std_logic_vector(31 downto 0)
);

end entity reg;

architecture rtl of reg is
signal reg_temp: std_logic_vector(31 downto 0);
begin

	process (clk, rst)
	begin

		if(rst = '1') then 
			reg_temp <= (others => '0');

		elsif (rising_edge(clk)) then

			if(wr_en = '1') then 
				reg_temp <= reg_in;
			end if;

		end if;
	end process;

reg_out <= reg_temp;
end rtl;
