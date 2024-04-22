library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 16.10 In a handshaking protocol, we like to include a ready signal in talker to indicate
-- that the system is idle and ready to accept another operation. Revise the talker ASM chart
-- of the two-phase handshaking protocol of Figure 16.19 to include the ready output signal.

-- we will consider almost the same thing
-- there are some slight changes that need to be made

entity talker_fsm is 
    port (
        clk, reset: in std_logic;
        start: in std_logic;
        ack_sync: in std_logic;
        ready: out std_logic;
        req_out: out std_logic
    );
end talker_fsm;

architecture arch of talker_fsm is 
    type state_type is (idle, s_req0, s_req1);
    signal state_reg, state_next: state_type;
    signal ready_reg, ready_next: std_logic;
    signal req_buf_reg, req_buf_next: std_logic;

begin
    -- state and data registers
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            state_reg <= idle;
            ready_reg <= '1';
            req_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
            ready_reg <= ready_next;
            req_buf_reg <= req_buf_next;
        end if;
    end process;

    -- next state
    process(state_reg, ack_sync, start)
    begin
        -- default values
        state_next <= state_reg;
        ready_next <= ready_reg;
        ack_buf_next <= ack_buf_reg;

        case state_reg is 
            when idle => 
                if (start = '1') then 
                    ready_next <= '0';
                    state_next <= s_ack1;
                end if;

            when s_req1 => 
                if (ack_sync = '1') then 
                    if (start = '1') then 
                        state_next <= s_req0;
                        ready_next <= '0';
                    else
                        state_next <= s_req1;
                        ready_next <= '1';
                    end if;
                else 
                    -- return to s_req1 state
                    -- do nothing 
                    state_next <= s_req1;
                end if;
                
            when s_req0 => 
                if (ack_sync = '0') then 
                    if (start = '1') then 
                        ready_next <= '0';
                        state_next <= s_req1;
                    else
                        -- rest in same state
                        -- change the value of ready to '1'
                        state_next <= s_req0;
                        ready_next <= '1'
                    end if;
                else 
                    -- do nothing 
                    -- remain in same state
                    state_next <= s_req0;
                end if;
        end case;
    end process;    


    -- Look-ahead output buffer
    process(state_next) 
    begin
        case state_next is 
            when idle => 
                req_buf_next <= '0';
            when s_req0 => 
                req_buf_next <= '0';
            when s_req1 => 
                req_buf_next <= '1';
        end case;
    end process;

    -- output logic
    ready <= ready_reg;
    req_out <= req_buf_reg;

end arch;

-- This covers all the rquirements in ex 16.10