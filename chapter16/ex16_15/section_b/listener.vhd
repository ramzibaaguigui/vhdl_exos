library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (
        clk, reset: in std_logic; 
        data_in: in std_logic_vector(15 downto 0); 
        addr_in: in std_logic_vector(3 downto 0); 
        req_in: in std_logic
    );
end listener;

architecture arch of listener is 
    type state_type is (idle, done_1, done_2, done_a, done_b, done_c, done_d); -- consider working on this later 
    signal state_reg, state_next: state_type; 

    signal array_reg, array_next: array (3 downto 0, 15 downto 0) of std_logic; 
    
begin
    -- infer registers 
    process(clk, reset) 
    begin
        if reset = '1' then -- reset all to default
            state_reg <= idle;
            array_reg <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next; 
            array_reg <= array_next;
        end if;
    end process;

    -- next state, routing data path logic 
    process(state_reg, ack_in, addr_in, data_in)
    begin
        -- default values
        state_next <= state_reg;
        array_next <= array_reg;
        
        case state_reg is 
            when idle => 
                if req_in = '1' then 
                    array_next(to_integer(unsigned(addr_in)), 15 downto 0) <= data_in;
                    state_next <= done_1;
                else
                    -- rest in the same state 
                    state_next <= idle; 

                end if;
            
            when done_1 => 
                state_next <= done_2; 
            
            when done_2 => 
                state_next <= done_a;
            when done_a => 
                state_next <= done_b; 
            when done_b => 
                state_next <= done_c; 
            when done_c => 
                state_next <= done_d;
            when done_d => 
                state_next <= idle;
        end case;

    end process;
end arch;
    