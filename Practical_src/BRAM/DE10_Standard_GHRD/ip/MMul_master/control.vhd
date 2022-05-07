library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity control is

	port(	clk,rst, start, c1, c2, c3: in std_logic;
		i_ld, j_ld, k_ld, wr, finish: out std_logic;
		i_sel, j_sel, k_sel: out std_logic_vector(1 downto 0);
		out_sel: out std_logic);
end control;

architecture rtl of control is

  type state_type is (s0,s1,s2,s3,s4);
  signal current_state, next_state: state_type;
  signal temp_finish: std_logic;
  signal temp_out_sel: std_logic;

begin 

	process(start, temp_finish, c1, c2, c3, current_state)
  	begin
    		case current_state is

			when s0 =>  
    				i_ld <= '0';
    				j_ld <= '0';
    				k_ld <= '0';
    				i_sel <= "00"; 
    				j_sel <= "00"; 
    				k_sel <= "00";
    				temp_out_sel <= '0';
    				wr <= '0';
    				temp_finish <= '0';
    				next_state <= s1;

			when s1 =>
  				i_ld <= '1';
  				j_ld <= '1';
  				k_ld <= '1';
  				i_sel <= "00"; 
  				j_sel <= "00"; 
  				k_sel <= "00"; 
  				temp_out_sel <= '0';
					wr <= '0';
					temp_finish <= temp_finish;

			if (start = '0') then 
				next_state <= s1;

			elsif (temp_finish = '1') then
				next_state <= s1;

			-- go to reset
			else
				next_state <= s4;

			end if;

			-- read new data from inputs and increment in the next cycle
			when s2 =>
				i_ld <= c1 and not c2;
				j_ld <= c1 and not (c2 and c3);
				k_ld <= c1;
				i_sel <= "01"; 
				j_sel <= "0" & c2; 
				k_sel <= "0" & (c2 and c3);
				temp_out_sel <= '1';
				wr <= c1 and c2 and c3;
				temp_finish <= not c1;

				if (c1 = '0') then
					next_state <= s1;
				
				elsif (c2 = '0' or c3 = '0') then
					next_state <= s4;

				else
					next_state <= s3;

				end if;
		
			-- write to output and actually increment (if any)
			when s3 =>
  				i_ld <= c1 and not c2;
  				j_ld <= c1 and not (c2 and c3);
  				k_ld <= c1;
					i_sel <= "11"; 
					j_sel <= "11"; 
					k_sel <= "11";
					temp_out_sel <= temp_out_sel;
  				wr <= '0';
  				temp_finish <= not c1;

					if (c1 = '0') then
						next_state <= s1;
					else 
						next_state <= s2;
					end if;

			-- reset without increment
			when others =>
  				i_ld <= c1 and not c2;
  				j_ld <= c1 and not (c2 and c3);
  				k_ld <= c1;
					i_sel <= "11"; 
					j_sel <= "11"; 
					k_sel <= "11";
					temp_out_sel <= '0';
  				wr <= c1 and c2 and c3;
  				temp_finish <= not c1;
					
					next_state <= s3;

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
  	out_sel <= temp_out_sel;
end rtl;
