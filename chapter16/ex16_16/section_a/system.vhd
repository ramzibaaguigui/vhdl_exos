library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity entire_system is 
    port (
        clka, clkb: in std_logic; 
        reset: in std_logic
    );
end entire_system; 

architecture arch of entire_system is 
    signal data_line: std_logic_vector(15 downto 0);
    signal req_line: std_logic;
    signal addr_line: std_logic_vector(3 downto 0); 
begin
    talker_unit: 
    entity work.talker(arch)
        port map (
            clk => clka, reset => reset, 
            data_in => data_line, addr_out => addr_line, 
            req_out => req_line
        );

    listener_unit: 
    entity work.listener_sync(arch)
        port map(
            clk => clkb, reset => reset, 
            data_out => data_line, addr_in => addr_line, 
            req_in => req_line
        );
    
end arch;