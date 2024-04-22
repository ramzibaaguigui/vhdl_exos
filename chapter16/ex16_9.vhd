library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ex 16.9:
-- 16.9 Revise the talker ASM chart of the two-phase handshaking protocol of Figure 16.19
-- to eliminate the idle state.

entity talker_fsm is 
    port (
        clk, reset: in std_logic;
        start: in std_logic;
        ack_sync: in std_logic;
        req_out: out std_logic
    );
end talker_fsm;

architecture arch of talker_fsm is 
    type state_type is (s_req0, s_req1);
    signal state_reg, state_next: state_type;
    signal req_buf_reg, req_buf_next: std_logic;
begin
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            state_reg <= s_req0;
            req_buf_reg <= '0';
        elsif 
            -- take next values
            state_reg <= state_next;
            req_buf_reg <= req_buf_next;
        end if;
    end process;

    -- STATE NEXT
    process(state_reg, start, ack_sync)
    begin
        state_next <= state_reg;
        req_out <= '0';

        case state_reg is 
            when s_req0 => 
                if (ack_sync = '0') then 
                    if (start = '1') then 
                        state_next <= s_req1;
                    end if;
                end if;

            when s_req1 => 
                if (ack_sync = '1') then 
                    if (start = '1') then 
                        state_next <= s_req1;
                    end if;
                end if;
        end case;
    end process; 
    
    -- Look-ahead output buffer
    process(state_next) 
    begin
        case state_next is 
            when s_req0 => 
                req_buf_next <= '0';
            when s_req1 => 
                req_buf_next <= '1';
        end case;
    end process;

    -- output logic
    req_out <= req_buf_reg;
end arch;

-- We transformed the ASMD chart in Figure 16.19 to an equivalent one with less states 
