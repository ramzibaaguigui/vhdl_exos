library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_sync is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic;
        ack_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0)
    );
end listener_sync;

architecture arch of listener_sync is 
    signal req_in_sync: std_logic;
begin
    -- syncronzier unit for the ack_in signal
    req_syncronizer:
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => req_in, a_out => req_in_sync
        );
    
    -- instance of the listener
    listener_unit: 
    entity work.listener(arch)
        port map(
            clk => clk, reset => reset, 
            req_in => req_in_sync,
            ack_out => ack_out,
            data_inout => data_inout
        );
    
end arch;