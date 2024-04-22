library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker is 
    port (
        clk, reset: in std_logic; 
        data_out: out std_logic_vector(15 downto 0); 
        req_out: out std_logic; 
        addr_out: out std_logic_vector(3 downto 0)
    );
end talker; 

architecture arch of talker is 
    type state_type is (idle, waiting_1, waiting_2, waiting_3, recover);
    signal state_reg, state_next: state_type;

    -- control signal that we should consider
    signal start_reg, start_next: std_logic;
    
    signal req_buf_reg, req_buf_next: std_logic;
begin
    -- infer registers 
    process(clk, reset) 
    begin
        if reset = '1' then 
            state_reg <= idle;
            start_reg <= '0';
            req_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            -- take the next values
            state_reg <= state_next;
            start_reg <= start_next;
            req_buf_reg <= req_buf_next;
        end if;

    end process;

    -- next state, data routing, ... 
    process(state_reg, start_reg)
    begin
        -- default values
        state_next <= state_reg; 
        req_buf_next <= req_buf_reg;
        -- there are many things to consider

        case state_reg is 
            when idle => 
                -- wait for the start signal to get asserted
                if start_reg = '1' then 
                    -- there is something to push,
                    -- go to the next state
                    req_buf_next <= '1';
                else
                    -- rest in the same state
                    state_next <= idle;
                end if; 
            when waiting_1 => 
                state_next <= waiting_2;
            when waiting_2 => 
                state_next <= waiting_3;
            when waiting_3 => 
                state_next <= waiting_4;
            when waiting_4 => 
                state_next <= recover;

            when recover => 
                state_next <= idle; 
                req_buf_next <= '0';
                
        end case;
    end process;

end arch;

-- the entire requirements should have been covered