library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_sync is 
    port (
        clk, reset: in std_logic; 
        data_out: out std_logic_vector(15 downto 0); 
        addr_in: in std_logic_vector(3 downto 0);
        req_in: in std_logic
    );
end listener_sync;

architecture arch of listener_sync is 
    signal req_sync: std_logic;
begin
    sync_unit: 
    entity work.syncronizer(two_flop_arch)
        generic map (
            DEFAULT_VALUE => '0'
        )
        port map (
            clk => clk, reset => reset, 
            a_in => req_in, a_out => req_sync;
        );
        
    listener_unit: 
    entity work.listener_sync(arch)
        port map (
            clk => clk, reset => reset, 
            data_out => data_out, req_in => req_sync, 
            addr_in => addr_in
        );
    


end arch;