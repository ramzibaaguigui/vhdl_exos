library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- integrate the entire system
entity entire_system is 
    port (
        clk, reset: in std_logic
    );
end entire_system;

architecture arch of entire_system is 
    signal talker_listener_data_bus: std_logic_vector(15 downto 0);
    signal listener_talker_data_bus: std_logic_vector(15 downto 0); 
    signal addr_bus: std_logic_vector(3 downto 0);
    signal req_line, ack_line: std_logic;
    signal pull_line: std_logic;
begin
    -- talker instance
    talker_unit: 
    entity work.talker_sync(arch)
        port map(
            clk => clk, reset => reset, 
            data_in => listener_talker_data_bus,
            data_out => talker_listener_data_bus, 
            ack_in => ack_line,
            req_out => req_line, 
            addr_out => addr_bus,
            pull_out => pull_line
        );

    -- listener instance
    listener_unit: 
    entity work.listener_sync(arch)
        port map (
            clk => clk, reset => reset, 
            data_in => talker_listener_data_bus,
            data_out => listener_talker_data_bus, 
            ack_out => ack_line,
            req_in => req_line, 
            addr_in => addr_bus,
            pull_in => pull_line
        );
end arch;