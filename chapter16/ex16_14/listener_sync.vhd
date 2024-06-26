library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_sync is 
    port (
        clk, reset: in std_logic; 
        data_in: std_logic_vector(15 downto 0); 
        req_in: in std_logic;
        addr_in: in std_logic_vector(3 downto 0);
        ack_out: out std_logic;
        data_out: out std_logic_vector(15 downto 0);
        pull_in: in std_logic
    );
end listener_sync;
 
architecture arch of listener_sync is 
    signal req_sync: std_logic;

begin
    -- syncronizer instance
    sync_unit: 
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => req_in,
            a_out => req_sync
        );
    
    -- listener instance
    listener_unit: 
    entity work.listener(arch)
        port map (
            clk => clk, reset => reset, 
            req_in => req_sync, 
            ack_out => ack_out,
            data_in => data_in,
            data_out => data_out,
            addr_in => addr_in;
            pull_in => pull_in
        );
end arch;
-- we should be done