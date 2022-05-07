library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity toplevel is

    port (	clk, rst, start : in std_logic;
    		mat1, mat2 : in std_logic_vector(15 downto 0);
    		m1, m2, n1, n2 : in std_logic_vector(15 downto 0);
    		res_in : in std_logic_vector(31 downto 0);
    		finish, wr : out std_logic;
    		i_out, j_out, k_out : out std_logic_vector(15 downto 0);
    		res_out : out std_logic_vector(31 downto 0));
end toplevel;

architecture rtl of toplevel is

    component datapath is
        
	port (	clk, rst, i_ld, j_ld, k_ld, i_sel, j_sel, k_sel : in std_logic;
    		mat1, mat2 : in std_logic_vector(15 downto 0);
    		m1, m2, n1, n2 : in std_logic_vector(15 downto 0);
    		res_in : in std_logic_vector(31 downto 0);
    		c1, c2, c3 : out std_logic;
    		i_out, j_out, k_out : out std_logic_vector(15 downto 0);
    		res_out : out std_logic_vector(31 downto 0));
    end component;

    component control is

        port(	clk,rst, start, c1, c2, c3: in std_logic;
 	 	i_ld, j_ld, k_ld, i_sel, j_sel, k_sel, wr, finish: out std_logic);

    end component;

    	signal i_ld, j_ld, k_ld, i_sel, j_sel, k_sel, c1, c2, c3 : std_logic;

    begin

        dp    : datapath  port map(clk, rst, i_ld, j_ld, k_ld, i_sel, j_sel, k_sel, mat1, mat2, m1, m2, n1, n2, res_in, c1, c2, c3, i_out, j_out, k_out, res_out);
        ctrl  : control   port map(clk, rst, start, c1, c2, c3, i_ld, j_ld, k_ld, i_sel, j_sel, k_sel, wr, finish);

    end rtl;
