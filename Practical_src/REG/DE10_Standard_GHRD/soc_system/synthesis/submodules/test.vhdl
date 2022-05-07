library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity test is
port(
	clk: 				in  std_logic;
	reset: 				in  std_logic;

	-- Avalon Bus Slave
	avs_s0_address:		in  std_logic_vector(1 downto 0);
	avs_s0_read: 		in  std_logic;
	avs_s0_write: 		in  std_logic;
	avs_s0_readdata: 	out std_logic_vector(31 downto 0);
	avs_s0_writedata:	in  std_logic_vector(31 downto 0)
);
end entity test;

architecture rtl of test is

signal i_wr: std_logic;
signal i: std_logic_vector(31 downto 0);

begin
	
	process(clk, reset)
	begin

		if(reset = '1') then
			i <= (others => '0');

		elsif(clk'event and clk = '1') then

			if(i_wr = '1') then
				i <= avs_s0_writedata;
			end if;

		end if;
	end process;


	i_wr  <= '1' when avs_s0_address = "00" and avs_s0_write = '1' else '0';
	
	avs_s0_readdata <= i when avs_s0_address = "01" and avs_s0_read = '1' else (others => 'X');

end rtl;
