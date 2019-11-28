--- UART 8-BIT
--- VERSION 1.0
--- INPUT CLOCK = 100 MHz
--- BAUD RATES AVAILABLE : 600,1200,2400,4800,9600,19200,38400,57600,115200
--- START BIT , STOP BIT , NO PARITY , SAMPLING RATE = 8x
--- MAXIMUM PERMISSIBLE FREQUENCY MISMATCH ERROR FOR DATA RECEPTION = +/- 4.0%
--- MODIFIED  : 14-01-2017
--- DEVELOPER : MITU RAJ , ERDCIIT , TRIVANDRUM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
port(  tx_data_in : in std_logic_vector( 7 downto 0 ) ;                            
       tx_load    : in std_logic ;                     
       tx_intr    : out std_logic ;                     
       tx_data_out: out std_logic ;
       baud_rate  : in std_logic_vector(3 downto 0);
       rx_data_out: out std_logic_vector( 7 downto 0 ) ; 
       rx_intr    : out std_logic ;                     
       rx_data_in : in std_logic  ;        
       clock_in   : in std_logic ;
       enable     : in std_logic ; 
       ERROR      : out std_logic ;
       --chk      : out std_logic ;      
       reset      : in std_logic 
       
      );

end UART ;

architecture archi_UART of UART is

signal clock_out_rx : std_logic ;
signal clock_out_tx : std_logic ;

component uart_transmitter 
port ( tx_data_in : in std_logic_vector( 7 downto 0 ) ; -- 8 bit parallel data input from processor
       tx_clk     : in std_logic ;                      -- transmitter's clock
       tx_load    : in std_logic ;                      -- load signal
       tx_intr    : out std_logic ;                     -- transmit interrupt 
       tx_reset   : in std_logic ;                      -- RESET 
       tx_data_out: out std_logic ) ;                   -- serial data output
end component ;

component uart_receiver 
port ( rx_clk      : in std_logic ;                       -- receiver's clock  
       rx_data_out : out std_logic_vector( 7 downto 0 ) ; -- 8 bit parallel data output to processor
       rx_intr     : out std_logic ;                      -- receive interrupt 
       ERROR       : out std_logic ;                      -- ERROR signal
       rx_reset    : in std_logic ;                       -- RESET
       rx_data_in  : in std_logic ) ;                     -- serial data input
end component ;

component baud_generator 
port ( clock_in : in std_logic ;
       enable : in std_logic ;
       baud_rate : in std_logic_vector(3 downto 0) ;
       reset : in std_logic ;
       clock_out_tx : out std_logic ;
       clock_out_rx : out std_logic ) ;
     
end component ;

begin
cA : baud_generator   PORT MAP( clock_in => clock_in ,
                                enable => enable ,
                                baud_rate => baud_rate ,
                                reset => reset ,
                                clock_out_rx => clock_out_rx ,
                                clock_out_tx => clock_out_tx );
                             
cB : uart_transmitter PORT MAP( tx_data_in => tx_data_in , 
                                tx_clk => clock_out_tx ,
                                tx_load => tx_load , 
                                tx_reset => reset ,
                                tx_intr => tx_intr ,
                                tx_data_out => tx_data_out );

cC : uart_receiver    PORT MAP( rx_data_in => rx_data_in ,
                                rx_clk => clock_out_rx ,
                                rx_data_out => rx_data_out ,
                                rx_intr => rx_intr ,
                                ERROR => ERROR ,
                                rx_reset => reset );
                                
--chk <= clock_out_tx;
end archi_UART ;