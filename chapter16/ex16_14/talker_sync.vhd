library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker_sync is 
    port (
        clk, reset: in std_logic; 
        data_in: in std_logic; 
        ack_in: in std_logic; 
        req_out: out std_logic;
        data_out: out std_logic_vector(15 downto 0);
        pull_out: out std_logic;
        addr_out: out std_logic_vector(3 downto 0)
    );
end talker_sync;

architecture arch of talker_sync is 
    signal ack_sync: std_logic;
begin
    -- syncronizer instance
    syncronizer_unit: 
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset,  
            a_in => ack_in, a_out => ack_sync
        );
    
    -- talker instance 
    talker_unit:
    entity work.talker_sync(arch)
        port map (
            clk => clk, reset => reset , 
            data_in => data_in, data_out => data_out,
            ack_in => ack_sync, req_out => req_out, 
            pull_out => pull_out, 
            addr_out => addr_out
        );
        
end arch;