--- TRANSMISSOR UART 8-BIT
--- START BIT , STOP BIT , SEM PARIDADE

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_transmitter is
port ( tx_data_in : in std_logic_vector( 7 downto 0 ) ; -- Input paralelo de 8 bits vindo do processador
       tx_clk     : in std_logic ;                      -- Clock do transmissor
       tx_load    : in std_logic ;                      -- Sinal de Carregamento
       tx_intr    : out std_logic ;                     -- Interrompedor
       tx_reset   : in std_logic ;                      -- Reset
       tx_data_out: out std_logic ) ;                   -- Output de dados seriais
end uart_transmitter ;

architecture archi_uart_transmitter of uart_transmitter is
begin
process(tx_clk , tx_reset)
variable tx_data_reg : std_logic_vector( 7 downto 0 ):= "11111111"; -- Registrador de dados
variable tx_counter : integer range 0 to 12 :=0 ;                   
begin
if (tx_reset = '0') then          -- Condição de Reset
tx_data_reg := "11111111";
tx_counter  := 0 ;
tx_data_out <= '1' ;
tx_intr     <= '0' ;
elsif (rising_edge(tx_clk)) then  -- tx_clk decide baud rate
if(tx_load = '0') then
    if(tx_counter = 11 ) then
    tx_data_reg := "11111111";  -- reinicializa data_reg
    tx_counter := 0 ;           -- reinicializa contador
    tx_intr <= '1';             -- interrupt em high
    elsif(tx_counter = 10 ) then     
    tx_data_out <= '1' ;        -- stop bit enviado
    tx_counter := tx_counter + 1 ;
    elsif(tx_counter = 0 ) then
    tx_data_reg := tx_data_in ; -- 8 bits de dados do processador copiados para registrador de dados
    tx_data_out <= '1' ;        -- stop bit enviado
    tx_intr     <= '0' ;        -- interrupt em low
    tx_counter := tx_counter + 1 ;
    elsif(tx_counter = 1) then
    tx_data_out <= '0' ;        -- start bit enviado
    tx_counter := tx_counter + 1 ;
    else
    tx_data_out <= tx_data_reg(tx_counter-2); -- bits de dados enviados de maneira serial, o menos significativo primeiro
    tx_counter := tx_counter + 1 ;
    end if ; -- tx_counter != 0 , 1, 10    
else
tx_data_reg := "11111111";
tx_counter  := 0 ;
tx_data_out <= '1' ;
tx_intr     <= '0' ;  
end if ; -- ok_load
end if ; -- rising_edge de tx_clk
end process ;
end archi_uart_transmitter ;