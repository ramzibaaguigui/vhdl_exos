library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ex 16.5:
-- We want to regenerate the enable pulse in the listener’s clock domain using the
-- four-phase handshaking protocol. In this scheme, the listener has an output signal that is
-- asserted once during the handshaking process.
-- (a) Revise the listener ASM chart of Figure 16.16 to add a Mealy output signal.
-- (b) Modify the VHDL code to reflect the revised ASM chart.

entity talker_fsm is 
    port (
        clk, reset: in std_logic;
        start, ack_sync: in std_logic;
        ready, req_out: out std_logic
    );
end talker_fsm;

architecture arch of talker_fsm is 
    type state_type is (idle, s_req1, s_req0);
    signal state_reg, state_next: state_type;
    signal req_buf_reg, req_buf_next: std_logic;

begin

    -- state register and output buffers
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            state_reg <= idle;
            req_buf_reg <= '0';
        elsif (clk'event and clk='1') then 
            state_reg <= state_next;
            req_buf_reg <= req_buf_next;
        end if;
    end process;

    -- next state logic 
    process(state_reg, start, ack_sync)
    begin
        ready <= '0';
        state_next <= state_reg;
        case state_reg is
            when idle =>
                if start = '1' then 
                    state_next <= s_req1;
                else 
                    state_next <= idle;
                end if;

            when s_req1 => 
                if ack_sync = '1' then 
                    state_next <= s_req0;
                end if;
            
            when s_req0 => 
                if ack_sync = '0' then 
                    stat_next <= idle;
                end if;
        end case;
    end process;

    -- lookahead output logic
    process(state_next) 
    begin
        case state_next is
            when idle => 
                req_buf_next <= '0';
            when s_req1 => 
                req_buf_next <= '1';
            when s_req0 => 
                req_buf_next <= '0';
        end case;
    end process;

    req_out <= req_buf_reg;
end arch;

-- now that we have considered the talkder FSM with no syncronizers, 
-- this is the time to consider the listener FSM with no syncronizers as well 
-- note that no syncronizer here means that the the signals are all supposed to be syncronized
-- we will consider adding syncronizers later as just an interface to the external world
-- and bundle the entire staff in a single entity

entity listener_fsm is 
    port (
        clk, reset: in std_logic;
        req_sync: in std_logic;
        ack_out: out std_logic
    );
end listener_fsm;

architecture arch of listenere_fsm is 
    type state_type is (s_ack0, s_ack1);
    signel state_reg, stat_next: state_type;
    
    signal ack_buf_reg, ack_buf_next: std_logic;

begin
    -- state register and buffers
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            stat_reg <= s_ack0;
            ack_buf_reg <= '0'
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
            ack_buf_reg <= ack_buf_next;
        end if;
    end process;

    -- next state logic
    process(state_reg, req_sync) 
    begin
        state_next <= state_reg;
        case state_reg is
            when s_ack0 => 
                if (req_sync = '1') then 
                    state_next <= s_ack1;
                end if;
            when s_ack1 => 
                if (req_sync = '0') then 
                    state_next <= a_ack0;
                end if;
        end case;
    end process;

    -- lookahead output logic 
    process(state_next)
    begin
        case state_next is 
            when s_ack0 =>
                ack_buf_next <= '0';
            when s_ack1 => 
                ack_buf_next <= '1';
        end case;
    end process;

    -- output
    ack_out <= ack_buf_reg;
end arch;

