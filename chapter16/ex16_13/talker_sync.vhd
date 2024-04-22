library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker_sync is
    port (
        clk, reset: in std_logic;
        ack_in: in std_logic; 
        req_out: out std_logic;
        pull_out: out std_logic; -- '1' when the op is pull, '0' when push 
        data_inout: inout std_logic_vector(7 downto 0); 
        addr_out: out std_logic_vector(2 downto 0)
    );
end talker_sync;

architecture arch of talker_sync is 
    signal ack_sync: std_logic;
begin

    -- the sync unit
    sync_unit: 
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => ack_in, a_out => ack_sync
        );
    
    talker_unit: 
    entity work.talker(arch)
        port map (
            clk => clk, reset => reset, 
            req_out => req_out, 
            ack_in => ack_sync,
            pull_out => pull_out, 
            data_inout => data_inout, 
            addr_out => addr_out   
        );
    -- this is just a wrapper, the logic will be defined internally
    
end arch;