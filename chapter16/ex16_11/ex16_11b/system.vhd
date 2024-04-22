library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- in this file, we integrate the entire system
-- starting from the talker to the listener to the bus access arbiter

entity entire_system is 
    port (
        clk, reset: in std_logic;
        a_in, b_in: in std_logic_vector(7 downto 0);
        y_out: out std_logic_vector(15 downto 0)
    );
end entire_system;

architecture arch of entire_system is 
    signal data_bus: std_logic_vector(15 downto 0);
    signal ttl_granted_line, ltt_granted_line: std_logic;
    signal req_line, ack_line: std_logic;
    
begin

    -- the talker component
    talker_unit: 
    entity work.talker_sync(arch)
        port map(
            clk => clk, reset => reset, 
            ack_in => ack_line, req_out => req_line,
            data_inout => data_bus, 
            ttl_granted => ltt_granted_line, 
            ltt_granted => ttl_granted_line
        );

    listener_unit: 
    entity work.listener_sync(arch)
        port map(
            clk => clk, reset => reset,
            req_in => req_line, 
            ack_out => req_line,
            data_inout => data_bus,
            ttl_granted => ttl_granted_line, 
            ltt_granted => ltt_granted_line
        );
    
    arbiter_unit: 
    entity work.bus_arbiter(arch)
        port map (
            req_in => req_line,
            ack_in => ack_line,
            ltt_granted => ltt_granted_line,
            ttl_granted => ttl_granted_line
        );

    
end arch;