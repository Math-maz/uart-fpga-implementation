--- INPUT CLOCK   : 100 MHz; Escolhido --> 110.592 MHz
--- BAUD RATES DISPONÍVEIS : 9600, 115200

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity baud_generator is
port(  clock_in : in std_logic ;
       enable : in std_logic ;
       baud_rate : in std_logic_vector(0 downto 0);
       reset : in std_logic ;
       clock_out_tx : out std_logic ; --- Clock para Transmissor
       clock_out_rx : out std_logic   --- Clock para Receptor
     );
end baud_generator ;

architecture baud_generator_archi of baud_generator is
signal divider :  unsigned(16 downto 0) ;
begin
  -------------- BAUD RATE CONFIGURADO PARA O INPUT DE CLOCK DE 100 MHz -------------------
  divider <= "00001010001011000" when baud_rate = "1" else --- 9600
             "00000000110110010" when baud_rate = "0" ; --- 115200
           
          
process(clock_in,reset)
variable count : unsigned(16 downto 0):= "00000000000000000";
variable count1: unsigned(16 downto 0):= "00000000000000000";
variable logiclevel_tx : std_logic := '1' ;
variable logiclevel_rx : std_logic := '1' ;

begin
if(reset ='0') then
count := "00000000000000000" ;
count1:= "00000000000000000" ;
logiclevel_tx := '1' ;
logiclevel_rx := '1' ;
clock_out_tx <= '0';
clock_out_rx <= '0';
elsif(rising_edge(clock_in)) then
if(enable = '0') then
if(count = divider) then
logiclevel_tx := not logiclevel_tx ;
clock_out_tx <= logiclevel_tx ;
count := "00000000000000000" ;
else
clock_out_tx <= logiclevel_tx ;
end if ;
if(count1 = ("000" & divider(16 downto 3 ))) then
logiclevel_rx := not logiclevel_rx ;
clock_out_rx <= logiclevel_rx ;
count1:= "00000000000000000" ;
else
clock_out_rx <= logiclevel_rx ;
end if ;
count := count + 1 ;
count1 := count1 + 1 ;
else
clock_out_rx <= '0';
clock_out_tx <= '0';
count := "00000000000000000" ;
count1:= "00000000000000000" ;
logiclevel_tx := '1' ;
logiclevel_rx := '1' ;
end if ;
end if ;
end process ;
end baud_generator_archi ;