library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener_fsm is 
    port (
        clk, reset: in std_logic;
        req_sync: in std_logic;
        pulse_out: out std_logic;
        ack_out: out std_logic
    );
end listener_fsm;

architecture arch of listener_fsm is
    type state_type is (s_ack0, s_pulse0, s_ack1, s_pulse1);
    signal state_reg, state_next: state_type;
    signal pulse_internal: std_logic
    signal ack_buf_reg, ack_buf_next: std_logic;

begin
    -- registers
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            state_reg <= s_ack0;
            ack_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
            ack_buf_reg <= ack_buf_next;
        end if;
    end process;

    -- next state
    process(state_reg, req_sync) 
    begin
        -- default values
        state_next <= state_reg; 
        pulse_internal <= '0';
        case state_reg is
            when s_ack0 => 
                if (req_sync) then 
                    state_next <= s_pulse0;
                end if;

            when s_pulse0 => 
                state_next <= s_ack1;
                pulse_internal <= '1';

            when s_ack1 => 
                if (req_sync = '0') then 
                    state_next <= s_pulse1;
                end if;

            when s_pulse1 =>
                state_next <= s_ack0;
                pulse_internal <= '1';
        end case;
    end process;

    -- Look-ahead output buffer
    process(state_next) 
    begin
        case state_next is 
            when s_ack1 => 
                ack_buf_next <= '1'
            when others => 
                ack_buf_next <= '0';
        end case;
    end process;

    -- output logic
    pulse_out <= pulse_internal;
    ack_out <= ack_buf_reg;
end arch;
-- DONE WITH EX 16.8