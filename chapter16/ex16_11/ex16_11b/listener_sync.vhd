library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity listener_sync is
    port (
        clk, reset: in std_logic;
        req_in: in std_logic;
        ack_out: out std_logic;
        ttl_granted, ltt_granted: inout std_logic_vector(15 downto 0);
    );
end entity listener_sync;

architecture arch of listener_sync is 
    signal req_sync: std_logic;
begin

    -- two flop syncronizer
    syncronizer_unit:
    entity work.syncronizer(two_flop_arch)
        port map(
            clk => clk, reset => reset, 
            a_in => req_in, b_out => req_sync
        );
    
    listener_unit: 
    entity work.listener(arch)
        port map(
            clk => clk, reste => reset,
            req_in => req_sync, ack_out => ack_out, 
            data_inout => data_inout, 
            ttl_granted => ttl_granted, ltt_granted => ltt_granted
        );
end arch;