library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- integrated the entire system 
entity entire_system is 
    port (
        clk10mhz, reset: in std_logic
        clk40mhz: in std_logic
    );
end entire_system; 

architecture arch of entire_system is 
    signal data_line: std_logic_vector(15 downto 0); 
    signal addr_line: std_logic_vector(3 downto 0); 
    signal req_line: std_logic;

begin
    -- the talker instance 
    talker_unit: 
    entity work.talker(arch)
        port map (
            clk => clk10mhz, reset => reset, 
            data_out => data_line, 
            req_out => req_line, 
            addr_out => addr_line
        );
    
    -- the listener instance 
    listener_unit: 
    entity work.listener_sync(arch) 
        port map (
            clk => clk40mhz, reset => reset, 
            addr_in => addr_line, 
            data_in => data_line, 
            req_in => req_line
        );
    -- the entire system is integrated
    
end arch;