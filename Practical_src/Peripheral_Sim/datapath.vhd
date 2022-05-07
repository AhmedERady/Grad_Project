library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity datapath is
    
	port (	clk, rst, i_ld, j_ld, k_ld : in std_logic;
			i_sel, j_sel, k_sel : in std_logic_vector(1 downto 0);
    		mat1, mat2 : in std_logic_vector(15 downto 0);
    		m1, m2, n1, n2 : in std_logic_vector(15 downto 0);
    		res_in : in std_logic_vector(31 downto 0);
    		c1, c2, c3 : out std_logic;
    		i_out, j_out, k_out : out std_logic_vector(15 downto 0);
    		res_out : out std_logic_vector(31 downto 0);
    		out_sel: in std_logic);
end datapath;

architecture rtl of datapath is

	component adder is

        	port (	a, b : in std_logic_vector(15 downto 0);
			y : out std_logic_vector(15 downto 0));
    	end component;
	
	component adder_res is

		port (	a, b : in std_logic_vector(31 downto 0);
			y : out std_logic_vector(31 downto 0));
	end component;

	component comparator is

		port (	a, b : in std_logic_vector(15 downto 0);
			y : out std_logic);
	end component;   
     
	
	component mux3x1 is

        	 port (	s : in std_logic_vector(1 downto 0);
    	  		a, b, c : in std_logic_vector(15 downto 0);
    	  		y : out std_logic_vector(15 downto 0));
    	end component;

		component outmux is

    	port (s : in std_logic;
    	  a, b : in std_logic_vector(31 downto 0);
    	  y : out std_logic_vector(31 downto 0));
    	end component;

    	component reg is

		port (	clk, rst, en: in std_logic;
			reg_in: in std_logic_vector(15 downto 0);
			reg_out: out std_logic_vector(15 downto 0));
    	end component;
 
    	component multiplier is

        	port (	a, b : in std_logic_vector(15 downto 0);
        		y : out std_logic_vector(31 downto 0));
    	end component;

    	signal mat1_2  : std_logic_vector(31 downto 0);
    	signal i, one_m, iplus1, zero_m, i_in, j, jplus1, j_in, k, kplus1, k_in : std_logic_vector(15 downto 0);
    	signal out_zero, out_mux, addr_out: std_logic_vector(31 downto 0);

    begin

        one_m(15 downto 1) <= (others => '0');
        one_m(0) <= '1';
        zero_m <= (others => '0');
        out_zero <= (others => '0');

        i_adder : adder port map (i, one_m, iplus1);
        i_mux 	: mux3x1 	port map (i_sel, zero_m, iplus1, i, i_in);
        i_reg 	: reg 	port map (clk, rst, i_ld, i_in, i);

        j_adder : adder port map (j, one_m, jplus1);
        j_mux 	: mux3x1  	port map (j_sel, zero_m, jplus1, j, j_in);
        j_reg 	: reg   port map (clk, rst, j_ld, j_in, j);
        
        k_adder : adder	port map (k, one_m, kplus1);
        k_mux 	: mux3x1  	port map (k_sel, zero_m, kplus1, k, k_in);
        k_reg 	: reg  	port map (clk, rst, k_ld, k_in, k);

        im_comp : comparator  port map (i, m1, c1);
        jn_comp : comparator  port map (j, n2, c2);
        km_comp : comparator  port map (k, m2, c3);

        zero_addr: outmux port map(out_sel, out_zero, addr_out, out_mux);

        res_adder      : adder_res 	     port map (res_in, mat1_2, addr_out);
		res_multiplier : multiplier  port map (mat1, mat2, mat1_2);

        i_out<= i;
        j_out<= j;
        k_out<= k;
        res_out <= out_mux;

    end rtl;
