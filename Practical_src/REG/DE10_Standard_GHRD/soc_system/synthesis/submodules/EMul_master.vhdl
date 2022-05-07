library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity EMul_master is
port(
	clk: 				in  std_logic;
	reset: 				in  std_logic;

	-- Avalon Bus Slave
	avs_s0_address:		in  std_logic_vector(3 downto 0);
	avs_s0_read: 		in  std_logic;
	avs_s0_write: 		in  std_logic;
	avs_s0_readdata: 	out std_logic_vector(15 downto 0);
	avs_s0_writedata:	in  std_logic_vector(15 downto 0)
);
end entity EMul_master;

architecture rtl of EMul_master is

signal i_wr,j_wr,k_wr,n_wr,s_wr: std_logic;
signal i_rd,j_rd,k_rd,n_rd,s_rd: std_logic;
signal i,j,k,n,s: std_logic_vector(15 downto 0);

begin
	
	process(clk, reset)
	begin

		if(reset = '1') then
			i <= (others => '0');
			j <= (others => '0');
			k <= (others => '0');
			n <= (others => '0');
			s <= (others => '0');

		elsif(rising_edge(clk)) then
			if(i_wr = '1') 		then	i <= avs_s0_writedata;
			elsif(j_wr = '1') 	then	j <= avs_s0_writedata;
			elsif(k_wr = '1') 	then	k <= avs_s0_writedata;
			elsif(n_wr = '1') 	then	n <= avs_s0_writedata;
			elsif(s_wr = '1') 	then	s <= avs_s0_writedata; 
			end if;
		
		end if;
	end process;

	i_wr  <= '1' when avs_s0_address = "0000" and avs_s0_write 	= '1' else '0';
	j_wr  <= '1' when avs_s0_address = "0001" and avs_s0_write 	= '1' else '0';
	k_wr  <= '1' when avs_s0_address = "0010" and avs_s0_write 	= '1' else '0';
	n_wr  <= '1' when avs_s0_address = "0011" and avs_s0_write 	= '1' else '0';
	s_wr  <= '1' when avs_s0_address = "0100" and avs_s0_write 	= '1' else '0';

	i_rd  <= '1' when avs_s0_address = "0101" and avs_s0_read 	= '1' else '0';
	j_rd  <= '1' when avs_s0_address = "0110" and avs_s0_read 	= '1' else '0';
	k_rd  <= '1' when avs_s0_address = "0111" and avs_s0_read 	= '1' else '0';
	n_rd  <= '1' when avs_s0_address = "1000" and avs_s0_read 	= '1' else '0';
	s_rd  <= '1' when avs_s0_address = "1001" and avs_s0_read 	= '1' else '0';
	
	avs_s0_readdata <= 	i when i_rd = '1' else
						j when j_rd = '1' else
						k when k_rd = '1' else
						n when n_rd = '1' else
						s when s_rd = '1' else 
						(others => '1');

end rtl;
