library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity talker_sync is 
    port (
        clk, reset: in std_logic;
        ack_in: in std_logic;
        req_out: out std_logic;
        data_inout: inout std_logic_vector(15 downto 0);
        ttl_granted, ltt_granted: in std_logic
    );
end talker_sync;

architecture arch of talker_sync is 
    signal ack_sync: std_logic;
begin
    -- syncronizer instalce 
    syncronizer_unit:
    entity work.syncronizer(arch)
    port map(
        clk => clk, reset => reset,
        a_in => ack_in, b_in => ack_sync
    );
    
    talker_unit: 
    entity work.talker
        port map(
            reset => reset, clk => clk, 
            ack_in => ack_sync, req_out => req_out,
            data_inout => data_inout, 
            ltt_granted => ltt_granted, ttl_granted => ttl_granted 
        );
end arch;