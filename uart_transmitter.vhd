--- UART TRANSMITTER CORE 8-BIT
--- VERSION 1.0
--- START BIT , STOP BIT , NO PARITY
--- MODIFIED  : 14-01-2017
--- DEVELOPER : MITU RAJ , ERDCIIT , TRIVANDRUM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_transmitter is
port ( tx_data_in : in std_logic_vector( 7 downto 0 ) ; -- 8 bit parallel data input from processor
       tx_clk     : in std_logic ;                      -- transmitter's clock
       tx_load    : in std_logic ;                      -- load signal
       tx_intr    : out std_logic ;                     -- transmit interrupt 
       tx_reset   : in std_logic ;                      -- RESET 
       tx_data_out: out std_logic ) ;                   -- serial data output
end uart_transmitter ;

architecture archi_uart_transmitter of uart_transmitter is
begin
process(tx_clk , tx_reset)
variable tx_data_reg : std_logic_vector( 7 downto 0 ):= "11111111"; -- data register
variable tx_counter : integer range 0 to 12 :=0 ;                   
begin
if (tx_reset = '0') then          -- RESET CONDITIONS 
tx_data_reg := "11111111";
tx_counter  := 0 ;
tx_data_out <= '1' ;
tx_intr     <= '0' ;
elsif (rising_edge(tx_clk)) then  -- tx_clk decides baud rate
if(tx_load = '0') then
    if(tx_counter = 11 ) then
    tx_data_reg := "11111111";  -- re initialising data_reg
    tx_counter := 0 ;           -- re initialising counter
    tx_intr <= '1';             -- transmit interrupt pulled high 
    elsif(tx_counter = 10 ) then     
    tx_data_out <= '1' ;        -- stop bit sent !
    tx_counter := tx_counter + 1 ;
    elsif(tx_counter = 0 ) then
    tx_data_reg := tx_data_in ; -- 8 bit data from processor copied to data register !
    tx_data_out <= '1' ;        -- stop bit sent !
    tx_intr     <= '0' ;        -- transmit interrupt pulled low !
    tx_counter := tx_counter + 1 ;
    elsif(tx_counter = 1) then
    tx_data_out <= '0' ;        -- start bit sent !
    tx_counter := tx_counter + 1 ;
    else
    tx_data_out <= tx_data_reg(tx_counter-2); -- data bits started sending serially, LSB first !
    tx_counter := tx_counter + 1 ;
    end if ; -- tx_counter != 0 , 1, 10    
else
tx_data_reg := "11111111";
tx_counter  := 0 ;
tx_data_out <= '1' ;
tx_intr     <= '0' ;  
end if ; -- ok_load
end if ; -- rising_edge of tx_clk
end process ;
end archi_uart_transmitter ;