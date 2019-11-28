--- TEST BENCH FOR UART 8-BIT
--- SENDING 00000000 TO 11111111 @9600 BPS
--- RECEIVING 01010101 SERIALLY @9600 BPS

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TB is
end UART_TB;

architecture ARCHI_UART_TB of UART_TB is
component UART 
port(  tx_data_in : in std_logic_vector( 7 downto 0 ) ;                            
       tx_load    : in std_logic ;                     
       tx_intr    : out std_logic ;                     
       tx_data_out: out std_logic ;
       baud_rate  : in std_logic_vector(3 downto 0);
       rx_data_out: out std_logic_vector( 7 downto 0 ) ; 
       rx_intr    : out std_logic ;   
       ERROR      : out std_logic ;                  
       rx_data_in : in std_logic  ;        
       clock_in : in std_logic ;
       enable : in std_logic ; 
       reset : in std_logic        
    );
end component;
signal tx_data_in :  std_logic_vector( 7 downto 0 ) ;                            
signal tx_load    :  std_logic ;                     
signal tx_intr    :  std_logic ;                     
signal tx_data_out:  std_logic ;
signal divider    :  std_logic_vector(3 downto 0);
signal rx_data_out:  std_logic_vector( 7 downto 0 ) ; 
signal rx_intr    :  std_logic ;                     
signal rx_data_in :  std_logic := '0' ;        
signal clock_in   :  std_logic := '0' ;
signal enable     :  std_logic ; 
signal reset      :  std_logic ;
signal state      :  std_logic := '0';
signal ERROR      :  std_logic := '0';
begin
test : UART port map( tx_data_in => tx_data_in ,
                      tx_load => tx_load ,
                      tx_intr => tx_intr ,
                      tx_data_out => tx_data_out ,
                      baud_rate => divider ,
                      rx_data_out => rx_data_out ,
                      rx_intr => rx_intr ,
                      rx_data_in => rx_data_in ,
                      clock_in => clock_in ,
                      ERROR => ERROR ,
                      enable => enable ,
                      reset => reset ); 
                      
clock_in <= not clock_in after 10 ns ; 
divider <= "0100";
process(clock_in)
variable start : integer := 0;
variable data  : unsigned (7 downto 0) := "00000000";
variable count : integer := 0;
begin
if(rising_edge(clock_in))then
if(start =0) then
reset <= '0';
start := 1 ;
elsif(start =1) then
reset <= '1';
start  := 2;
elsif(start =2) then
tx_data_in <= std_logic_vector(data)  ;
start := 3;
else
enable <= '0';
tx_load  <=  '0';
if(tx_intr = '1' and state = '0') then
if(data = "11111111") then
data := "00000000";
tx_data_in <= std_logic_vector(data)  ;
state <= '1';
else
data := data + "00000001" ;
tx_data_in <= std_logic_vector(data)  ;
state <= '1';
end if;
end if;
if(tx_intr = '0') then
state <= '0';
end if;

if(count  = 10416 ) then -- count = 2xbaudcount for baud rate 9600
count := 0;
rx_data_in <=  not rx_data_in ;
else
count := count + 1;
end if;

end if;
end if; --clock
end process;                  
end  ARCHI_UART_TB;