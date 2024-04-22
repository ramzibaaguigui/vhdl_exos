library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arbiter is 
    port (
        clk, reset: in std_logic;
        ack_in, req_in: std_logic;
        ttl_granted, ltt_granted: out std_logic
    );
end arbiter;

architecture arch of arbiter is 
    type state_type is (wating_op1, waiting_op2, waiting_result_1, waiting_result_2);
    signal state_reg, state_next: state_type;
    signal ttl_granted_buf, ttl_granted_next: std_logic;
    signal ltt_granted_buf, ltt_granted_next: std_logic;

begin

    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            state_reg <= waiting_op1;
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
        end if;
    end process;

    -- infer buffers 
    process(clk, reset)
    begin
        if reset = '1' then
            -- reset buffers to default values
            ttl_granted_reg = '1';
            ltt_granted_reg = '0';
        elif (clk'event and clk = '1') then 
            ttl_granted_reg <= ttl_granted_next; 
            ltt_granted_reg <= ltt_granted_next; 
        end if;
    end process;

    -- look-aheader buffering of ttl_granted and ltt_granted
    process(state_next)
    begin
        case state_next is 
            when waiting_op_1|waiting_op_1 => 
                ttl_granted_next <= '1';
                ltt_granted_next <= '0'


            when waiting_result_1|waiting_result_2 => 
                ltt_granted_next <= '1';
                ttl_granted_next <= '0';
            
        end case;
    end process;

    -- next state logic
    process(ack_in, ack_out) 
    begin
        -- default next value
        state_next <= state_reg;
        case state_reg is 
            when waiting_op_1 => 
                
                if req_in = '1' then 
                    state_next <= waiting_op_2;
                end if;

            when waiting_op_2 => 
                if req_in = '0' then
                    state_next <= waiting_result_1;
                end if;
            
            when waiting_result_1 => 
                if ack_in = '1' then
                    state_next <= waiting_result_2;
                end if;
            when waiting_result_2 => 
                    if ack_in = '0' then 
                        state_next <= waiting_op_1;
                    end if;
            
        end case;
    end process;
end arch;

