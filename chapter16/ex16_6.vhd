library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- repeat problem 16.5 but with a moore output
entity listener_fsm is 
    port (
        clk, reset: in std_logic;
        req_sync: in std_logic;
        ack_out: out std_logic;
        pulse_out: out std_logic
    );
end listener_fsm;

architecture mealy_arch of listener_fsm is 
    type state_type is (s_ack0, s_pulse, s_ack1);
    signal state_reg, state_next: state_type;
    signal ack_buf_reg, ack_buf_next;
    signal pulse_buf_reg, pulse_buf_next;
begin
    process(clk, reset) 
    begin
        if (reset = '1') then 
            state_reg <= s_ack0;
            ack_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
            ack_buf_reg <= ack_buf_next;
        end if;
    end process;

    -- next state logic
    process(start, state_reg, req_sync)
    begin
        -- default values
        state_next <= state_reg;
        ack_buf_next <= ack_buf_reg;

        case state_reg is 
            when s_ack0 => 
                if (req_sync = '1') then 
                    state_next <= s_pulse;
                end if;
    
            when s_pulse =>
            state_next <= s_ack1;
            
            when s_ack1 => 
                if (req_sync = '0') then 
                    state_next <= s_ack0;
                end if;
        end case;
    end process;

    -- LOOKAHEAD OUTPUT
    process(state_next)
    begin
        pulse_buf_next <= '0';
        ack_buf_reg <= '0';
        case state_next is 
            when s_ack0 => 

            when s_pluse =>
                pulse_buf_next <= '1';
            when s_ack1 =>
                ack_buf_next <= '1';
        end case;
    end process;
end mealy_arch;

-- We should be done with Ex 16.6
