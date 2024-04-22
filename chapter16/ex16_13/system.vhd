library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- integrate the entire signal 
entity entire_system is 
    port (
        clk, reset: in std_logic;
    );
end entire_system;

architecture arch of entire_system is 
    signal data_bus: std_logic_vector(7 downto 0); 
    signal pull_line: std_logic;
    signal addr_bus: std_logic;
    signal ack_line, req_line: std_logic;

begin
    -- talker instance
    talker_intance: 
    entity work.talker_sync(arch)
        port map(
            clk => clk, reset => reset, 
            req_out => req_line,
            ack_in => ack_line,
            pull_out => pull_line,
            data_inout => data_bus,
            addr_out => addr_bus 
        );
    
    -- listener instance
    listener_instance: 
    entity work.listener_sync(arch)
        port map(
            clk => clk, reset => reset, 
            req_in => req_line,
            ack_out => ack_line,
            pull_in => pull_line,
            data_inout => data_bus,
            addr_in => addr_bus    
        );

end arch;

-- this should be the entire system
