library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity interface_level is

    port (	clk, rst, start 		: in 	std_logic;
    		kernel_datain, input_datain 	: in 	std_logic_vector(15 downto 0);
    		m1, m2, n1, n2 			: in 	std_logic_vector(15 downto 0);
    		kernel_wr, input_wr 		: in	std_logic;
		kernel_en, input_en, output_en	: in 	std_logic;
		kernel_row_adr, kernel_col_adr	: in	std_logic_vector(15 downto 0);
		input_row_adr, input_col_adr	: in	std_logic_vector(15 downto 0);
		output_row_adr, output_col_adr	: in	std_logic_vector(15 downto 0);
    		finish 				: out 	std_logic;
		output_result			: out 	std_logic_vector(31 downto 0));


end interface_level;

architecture rtl of interface_level is
  
  	signal wr: std_logic;
  	signal i_out, j_out, k_out 	     					: std_logic_vector(15 downto 0);
	signal kernelrow, kernelcol, inputrow, inputcol, outputrow, outputcol 	: std_logic_vector(15 downto 0);
  	signal res_in, res_out 	   	     					: std_logic_vector(31 downto 0);
  	signal mat1, mat2     	             					: std_logic_vector(15 downto 0);

  	component toplevel is

  		port (	clk, rst, start : in std_logic;
  	  		mat1, mat2 : in std_logic_vector(15 downto 0);
  	  		m1, m2, n1, n2 : in std_logic_vector(15 downto 0);
  	  		res_in : in std_logic_vector(31 downto 0);
  	  		finish, wr : out std_logic;
  	  		i_out, j_out, k_out : out std_logic_vector(15 downto 0);
  	  		res_out : out std_logic_vector(31 downto 0));
  	end component ;

  	component inp_ram is

		port(clk, wr : in std_logic;
			row, col : in std_logic_vector(15 downto 0);
			din : in std_logic_vector(15 downto 0);
			y : out std_logic_vector(15 downto 0);
			col_count: in std_logic_vector(15 downto 0));
    	end component;

	component ker_ram is

		port(clk, wr : in std_logic;
			row, col : in std_logic_vector(15 downto 0);
			din : in std_logic_vector(15 downto 0);
			y : out std_logic_vector(15 downto 0);
			col_count: in std_logic_vector(15 downto 0));
	end component;

	component out_ram is

		port(clk, wr : in std_logic;
			row, col : in std_logic_vector(15 downto 0);
			din : in std_logic_vector(31 downto 0);
			y : out std_logic_vector(31 downto 0);
			col_count: in std_logic_vector(15 downto 0));
	end component;

	component mux2x1 is

    	port (s : in std_logic;
    	  a, b : in std_logic_vector(15 downto 0);
    	  y : out std_logic_vector(15 downto 0));
    	end component;

  begin

	dut		: toplevel	port map (clk, rst, start, mat1, mat2, m1, m2, n1, n2,  res_in, finish, wr, i_out, j_out, k_out, res_out);
	output_ram 	: out_ram 	port map (clk, wr, outputrow, outputcol, res_out, res_in,n2);
	kernel_ram 	: ker_ram 	port map (clk, kernel_wr, kernelrow, kernelcol, kernel_datain, mat1,m2);
	input_ram 	: inp_ram	port map (clk, input_wr, inputrow, inputcol, input_datain, mat2,n2);
	kernel_row	: mux2x1		port map (kernel_en, i_out, kernel_row_adr, kernelrow);
	kernel_col	: mux2x1		port map (kernel_en, k_out, kernel_col_adr, kernelcol);
	input_row	: mux2x1		port map (input_en, k_out, input_row_adr, inputrow);
	input_col	: mux2x1		port map (input_en, j_out, input_col_adr, inputcol);
	output_row	: mux2x1		port map (output_en, i_out, output_row_adr, outputrow);
	output_col	: mux2x1		port map (output_en, j_out, output_col_adr, outputcol);

	output_result <= res_in;
 
  end rtl;
