library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity control is

	port(	clk,rst, start, c1, c2, c3: in std_logic;
		i_ld, j_ld, k_ld, i_sel, j_sel, k_sel, wr, finish: out std_logic);
end control;

architecture rtl of control is

  type state_type is (s0,s1,s2);
  signal current_state, next_state: state_type;

  signal temp_finish: std_logic;

begin 

	process(start, c1, c2, c3, current_state, temp_finish)
  	begin
    		case current_state is

			when s0 =>  
    				i_ld <= '0';
    				j_ld <= '0';
    				k_ld <= '0';
    				i_sel <= '0'; 
    				j_sel <= '0'; 
    				k_sel <= '0'; 
    				wr <= '0';
    				temp_finish <= '0';
    				next_state <= s1;

			when s1 =>   
  				i_ld <= '1';
  				j_ld <= '1';
  				k_ld <= '1';
  				i_sel <= '0'; 
  				j_sel <= '0'; 
  				k_sel <= '0'; 
				wr <= '0';
    				temp_finish <= temp_finish;

				if (start = '0') then 
	    				next_state <= s1 ;

				elsif (temp_finish = '1') then
					next_state <= s1;
	  			
  			else
	    				next_state <= s2;	
	  			end if;

			when others => 
  				i_ld <= c1 and not c2;
  				j_ld <= c1 and not (c2 and c3);
  				k_ld <= c1;
  				i_sel <= '1'; 
  				j_sel <= c2; 
  				k_sel <= c2 and c3; 
  				wr <= c1 and c2 and c3;
    				temp_finish <= not c1;

    					if (c1 = '0') then
    						next_state <= s1;
    					else 
    						next_state <= s2;
    					end if;
		end case;
	end process;

  	process (rst, clk)
  	begin

    		if (rst ='1') then
      			current_state <= s0;
    		elsif (rising_edge(clk)) then
      			current_state <= next_state;
    		end if;
  	end process;

  	finish <= temp_finish;

end rtl;
