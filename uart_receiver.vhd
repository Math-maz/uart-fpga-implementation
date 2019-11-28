--- UART RECEIVER CORE 8-BIT
--- VERSION 1.0
--- START BIT , STOP BIT , NO PARITY , SAMPLING RATE = 8x
--- MODIFIED  : 14-01-2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
entity uart_receiver is
port ( rx_clk      : in std_logic ;                       -- receiver's clock  
       rx_data_out : out std_logic_vector( 7 downto 0 ) ; -- 8 bit parallel data output to processor
       rx_intr     : out std_logic ;                      -- receive interrupt 
       rx_reset    : in std_logic ;                       -- reset
       ERROR       : out std_logic ;
       rx_data_in  : in std_logic ) ;                     -- serial data input
end uart_receiver ;

architecture archi_uart_receiver of uart_receiver is
	signal STATE: std_logic_vector(7 downto 0);
	signal rx_data_reg: std_logic_vector(7 downto 0);
begin
  
process(rx_clk,rx_reset)
	variable sum_zeroes : integer range 0 to 9;
	variable sum_ones   : integer range 0 to 9;
	variable sample     : integer range 0 to 9;
	variable counter    : integer range 0 to 9;
begin
if(rx_reset = '0') then
	rx_intr <= '0' ;
	ERROR <= '0' ;
	rx_data_out <= "00000000";
	STATE <= x"00";
	counter := 0 ;
	sample := 0 ;
	sum_zeroes := 0 ;
	sum_ones := 0 ;
elsif(rising_edge(rx_clk))then
case STATE is
  
     when x"00" => ---- CHECKING FOR FIRST LOW ----
						 rx_intr <= '0' ;
                   if(rx_data_in = '0') then
							sum_zeroes := sum_zeroes+1;
							sample := sample + 1;
							STATE <= x"01";
                   end if;                   
     when x"01" => ---- CHECKING FOR START BIT, TO START SAMPLING AND 
                   ---- TO RE-SYNCHRONISE AFTER EVERY DATA FRAME                    
                   if(rx_data_in = '0') then
							sum_zeroes := sum_zeroes+1;
							sample := sample + 1;
                   elsif(rx_data_in = '1') then
							sum_ones := sum_ones +1;
							sample := sample + 1;
                   end if;
                   
                   if(sample =8) then
                   
								 if(sum_zeroes >= sum_ones and sum_zeroes>=4)then
								 STATE <= x"02"; --- IDENTIFIED START BIT  !
								 sample := 0;
							 else            --- IF NOT START BIT !
								 sample := 0;
								 STATE <= x"00";
							 end if;
                  
							 sum_zeroes := 0;
							 sum_ones   := 0;
                   
                   else
							STATE <= x"01";
                   end if;
     when x"02" => ---- START SAMPLING THE DATA ----
                   if(rx_data_in = '0') then
							 sum_zeroes := sum_zeroes+1;
							 sample := sample + 1;
                   elsif(rx_data_in = '1') then
							 sum_ones := sum_ones +1;
							 sample := sample + 1;
                   end if;
                   
                   if(sample =8) then
                   
                   if(sum_ones >= sum_zeroes and sum_ones>=4)then
							 rx_data_reg(counter) <= '1';
							 counter := counter +1;
                   elsif(sum_zeroes >= sum_ones and sum_zeroes>=4)then
							 rx_data_reg(counter) <= '0';
							 counter := counter +1;
                   end if;
                   
                   sum_zeroes := 0;
                   sum_ones   := 0;
                   
                   if(counter =8) then
							 sample := 0;
							 counter := 0;
							 STATE <= x"03";
                   else
							 sample := 0;
							 STATE <= x"02";
                   end if;
                   
                   else
							STATE <= x"02";
                   end if; 
     when x"03" => ---- CHECKING FOR STOP BIT ----
                   if(rx_data_in = '0') then
							 sum_zeroes := sum_zeroes+1;
							 sample := sample + 1;
                   elsif(rx_data_in = '1') then
							 sum_ones := sum_ones +1;
							 sample := sample + 1;
                   end if;
                   
                   if(sample >=4 and sample <9) then
							 if(sum_ones >= sum_zeroes and sum_ones>=4)then
								 rx_data_out <= rx_data_reg ;
								 sample := 0;
								 sum_zeroes := 0;
								 sum_ones   := 0;
								 counter := 0;
								 STATE <= x"04";
							 end if;
							 elsif(sample = 9)then
								STATE <= x"05";
                   end if;  
     when x"04" => ---- DATA SUCCESSFULLY RECEIVED, INTERRUPT GENERATION ----    
                   rx_intr <= '1';
                   STATE <= x"00"; 
     when x"05" => ---- NO STOP BIT RECEIVED, ERROR SIGNAL GENERATION , NEEDS RESET ----    
                   ERROR <= '1';                                                                     
     when OTHERS =>
                   rx_intr <='0';
end case;
end if;
end process;

end archi_uart_receiver ;