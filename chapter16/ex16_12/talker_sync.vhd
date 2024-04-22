library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker_sync is 
    port (
        clk, reset: in std_logic;
        ack_in_sync: in std_logic;
        a_in, b_in: std_logic_vector(7 downto 0);
        ttl_granted_in, ltt_granted_in: in std_logic;
        r_out: out std_logic_vector(15 downto 0);
        req_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0);
        start: in std_logic;
    );
end talker_sync;

architecture arch of talker_sync is 
    signal ack_in_sync: std_logic;
begin
    -- the ack_in syncronizer
    ack_syncronizer:
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map(
            clk => clk, reset => reset, 
            a_in => ack_in,
            a_out => ack_in_sync
        );
    
    -- the talker unit
    talker_unit: 
    entity work.talker(arch)
        port map(
            clk => clk, reset => reset, 
            ack_in => ack_in_sync,
            start => start,
            req_out => req_out, 
            data_inout => data_inout,
            a_in => a_in, b_in => b_in,
            r_out => r_out
        );
    

end arch;