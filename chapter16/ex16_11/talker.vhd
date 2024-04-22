library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- This file contains the VHDL code of the talker
-- the talker can receive eight bit data from another source
-- it can pass this data on the other side
-- it can generate req signals
-- it can sense the ack 

entity talker is 
    port (
        clk, reset: in std_logic;
        -- used from the requestor side to initiate the process
        start: in std_logic;
        operand_in: in std_logic_vector(7 downto 0);
        result_in: in std_logic(15 downto 0);
        ack_in: in std_logic;
        data_out: out std_logic_vector(7 downto 0);
        req_out: out std_logic
    );
end talker;

-- the data resides in internal signal, 
-- we do not know how it is generated

architecture arch of talker is 
    type state_type is (idle, s_req1, s_req0);
    
    signal state_reg, state_next: state_type;
    signal operand_reg, operand_next: std_logic_vector(7 downto 0);
    signal result_reg, result_next;
    signal req_buf_reg, req_buf_next: std_logic;
    signal ready_buf_reg, ready_buf_next: std_logic;
    -- ADD MORE SIGNALS WHEN NEEDED

begin
    -- REGISTERS 
    process(clk, reset)
    begin
        if (reset = '1') then 
            -- reset all to default
            state_reg <= idle;
            operand_reg <= (others => '0');
            req_buf_reg <= '0';
            result_reg <= (others => '0');
            ready_buf_reg <= '1';
        elsif (clk'event and clk =  '1') then 
            state_reg <= state_next;
            operand_reg <= operand_next;
            req_buf_reg <= req_buf_next;
            result_reg <= result_next;
            ready_buf_reg <= ready_buf_next;
        end if;
    end process;    

    -- next state logic 
    process(start, state_reg, ack_sync) 
    begin
        -- default values
        state_next <= state_reg;
        operand_next <= operand_reg;
        req_buf_next <= req_buf_reg;

        case state_reg is 
            when idle => 
                if (start = '1') then 
                    operand_next <= operand_in;
                    state_next <= s_req1;
                end if;
                -- else do nothing, remain in same state (already by default)
            
            when s_req1 => 
                -- in this state, the req output is asserted
                -- we are waiting for the ack signal
                -- if the ack signal is asserted, means that the data is ready
                -- recover it and go to the next state
                if (ack_sync = '1') then -- data ready 
                    -- get the data into the result register
                    -- go to s_req0 state
                    state_next <= s_req0;
                    result_next <= result_in;
                end if;
                -- else remain in the same state and do nothing
            when s_req0 => 
                -- wait for the ack to become 0
                -- move to the idle state
                if (ack_sync = '0') then 
                    state_next <= idle;
                end if; 
        end case;
    end process;

    -- look-ahead output buffer
    process(state_next) 
    begin
        case state_next is 

            when idle => 
                req_buf_next <= '0';
                ready_buf_next <= '1';

            when s_req0 => 
                ready_buf_next <= '0';
                req_buf_next <= '0';

            when s_req1 => 
                ready_buf_next <= '0';
                req_buf_next <= '1';
        end case;
    end process;    
end arch;