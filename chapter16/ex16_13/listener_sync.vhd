library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_sync is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic; 
        ack_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0)
        addr_in: in std_logic_vector(2 downto 0); 
        pull_in: in std_logic; -- if the operation is pull or push
    );
end listener_sync;

architecture arch of listener_sync is 
    
    signal req_sync: std_logic;
begin
    -- crete an instance of the syncronizer for the in req signal
    sync_unit: 
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => req_in, a_out => req_sync
        );
    
    -- the listener unit
    listener_unit: 
    entity work.listener(arch)
        port map(
            clk => clk, 
            reset => reset, 
            req_in => req_sync,
            ack_out => ack_out,
            pull_in => pull_in, 
            data_inout => data_inout, 
            addr_in => addr_in
        );
end arch;