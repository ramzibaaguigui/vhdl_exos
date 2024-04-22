library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_sync is 
    port (
        clk, reset: in std_logic; 
        req_in: in std_logic; 
        addr_in: in std_logic_vector(3 downto 0); 
        data_in: in std_logic_vector(15 downto 0)
    );
end listener_sync; 

architecture arch of listener_sync is 
    signal req_sync: std_logic;
begin
    -- the listener instance
    listener_unit: 
    entity work.listener(arch)
        port map (
            clk => clk, reset => reset, 
            req_in => req_sync, 
            data_in => data_in, 
            addr_in => addr_in
        );
    
    -- sync unit
    syncronizer_unit: 
    entity work.syncronzier(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => req_in, a_out => req_sync
        );
        
end arch;