library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb is
end tb ;

architecture behav of tb is

	constant clockperiod: time:= 100 ps;

	signal clk				:	std_logic:='0';
	signal  rst, start 			: 	std_logic;
	signal	kernel_datain, input_datain 	:  	std_logic_vector(15 downto 0);
	signal	m1, m2, n1, n2 			:  	std_logic_vector(15 downto 0);
	signal	kernel_wr, input_wr 		: 	std_logic;
	signal	kernel_en, input_en, output_en	:  	std_logic;
	signal	kernel_row_adr, kernel_col_adr	: 	std_logic_vector(15 downto 0);
	signal	input_row_adr, input_col_adr	:	std_logic_vector(15 downto 0);
	signal	output_row_adr, output_col_adr	: 	std_logic_vector(15 downto 0);
	signal	finish 				:  	std_logic;
	signal	output_result			:  	std_logic_vector(31 downto 0);

	component interface_level

	port (	clk, rst, start 	: in 	std_logic;
	kernel_datain, input_datain 	: in 	std_logic_vector(15 downto 0);
	m1, m2, n1, n2 			: in 	std_logic_vector(15 downto 0);
	kernel_wr, input_wr 		: in	std_logic;
	kernel_en, input_en, output_en	: in 	std_logic;
	kernel_row_adr, kernel_col_adr	: in	std_logic_vector(15 downto 0);
	input_row_adr, input_col_adr	: in	std_logic_vector(15 downto 0);
	output_row_adr, output_col_adr	: in	std_logic_vector(15 downto 0);
	finish 				: out 	std_logic;
	output_result			: out 	std_logic_vector(31 downto 0));
    
	end component;
  begin

	clk <= not clk after clockperiod /2;
	rst <= '1' , '0' after 0.15 ns;

	-- Loading ker
	kernel_wr <= '1' after 0.50 ns, '0' after 1.50 ns;
	kernel_en <= '1' after 0.50 ns, '0' after 1.50 ns;

	kernel_row_adr <= x"0000" after 0.50 ns, x"0000" after 0.75 ns, x"0001" after 1.00 ns, x"0001" after 1.25 ns; 
	kernel_col_adr <= x"0000" after 0.50 ns, x"0001" after 0.75 ns, x"0000" after 1.00 ns, x"0001" after 1.25 ns; 
	kernel_datain  <= x"0001" after 0.60 ns, x"0002" after 0.85 ns, x"0003" after 1.10 ns, x"0004" after 1.35 ns; 

	-- Loading inp
	input_wr  <= '1' after 1.50 ns, '0' after 2.50 ns;
	input_en  <= '1' after 1.50 ns, '0' after 2.50 ns;

	input_row_adr <= x"0000" after 1.50 ns, x"0000" after 1.75 ns, x"0001" after 2.00 ns, x"0001" after 2.25 ns; 
	input_col_adr <= x"0000" after 1.50 ns, x"0001" after 1.75 ns, x"0000" after 2.00 ns, x"0001" after 2.25 ns; 
	input_datain  <= x"0001" after 1.60 ns, x"0002" after 1.85 ns, x"0003" after 2.10 ns, x"0004" after 2.35 ns; 

	-- Setup sizes
	m1 <= x"0002";
	m2 <= x"0002";
	n1 <= x"0002";
	n2 <= x"0002";

	-- Start mult
	start <= '0' , '1' after 3.00 ns , '0' after 3.25 ns;

	-- Get output
	output_en <= '0';

	dut: interface_level  port map(clk,rst,start, kernel_datain, input_datain,m1, m2, n1, n2, 
	kernel_wr, input_wr, kernel_en, input_en, output_en, kernel_row_adr, kernel_col_adr, 
	input_row_adr, input_col_adr,output_row_adr, output_col_adr,finish,output_result);

end behav;
