library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- Exercise 14.9:
-- For the memory controller FSM circuit in Section 10.7.2, the output signal can be
-- unbuffered or buffered. The buffered output uses the look-ahead output buffer scheme.
-- Derive a VHDL code that includes both schemes and use the BUF generic as a feature
-- parameter to specify which buffer scheme to use.

entity mem_ctrl is
    generic (
        -- BUFFERED = 1 => Use look-ahead output buffer
        -- BUFFERED = 0 => Use normal Moore output
        
        BUFFERED: natural := 0;
    );
    port (
        clk, reset: in std_logic;
        mem, rw, burst: in std_logic;
        oe, we, we_me: out std_logic
    );
end mem_ctrl;

architecture plain_buffer_arch of mem_ctrl is 
    type mc_state_type is (
        idle, read1, read2, read3, read4, write
    );
    signal state_reg, state_next: mc_state_type;
    signal oe_next, we_next, oe_buf_reg, we_buf_reg: std_logic;
begin
    -- state register
    process(clk, reset) 
    begin
        if (reset = '1') then
            state_reg <= idle;
        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
        end if;
    end process;

    -- next state logic
    process(state_reg, mem, rw, burst)
    begin
        case state_reg is 
            when idle => 
                if mem = '1' then
                    if rw = '1' then
                        state_next <= read1;
                    else
                        state_next <= write;
                    end if;
                else
                    state_next <= idle;
                end if;
            
            when read1 =>
                if burst = '1' then
                    state_next <= read2;
                else
                    state_next <= idle;
                end if;
            
            when read2 =>
                state_next <= read3;
            
            when read3 => 
                state_next <= read4;
            
            when read4 =>
                state_next <= idle;
        end case;
    end process;

    
    -- if BUFFERED generic is given the value of 1 consider the above code

    buff_gen:
    if (BUFFERED = 1) generate
    -- output buffer
        process(clk, reset)
        begin
            if (reset = '1') then
                oe_buf_reg <= '0';
                we_buf_reg <= '0';
            elsif(clk'event and clk = '1') then
                oe_buf_reg <= oe_i;
                we_buf_reg <= we_i;
            end if;
        end process;

        -- Look ahead output buffer
        process(state_next)
        begin
            -- default values
            we_next <= '0';
            oe_next <= '0';
            
            case state_next is
                when idle =>
                    -- nothing changes
                when write =>
                    we_next <= '1';
                when read1|read2|read3|read4 =>
                    oe_next <= '1';
            end case;
        end process;

        -- output logic
        we <= we_buf_reg;
        oe <= oe_buf_reg;
    end generate;

    -- if BUFFERED = 0
    -- use the normal moore output
    moore_gen:
    if (BUFFERED = 0) generate
        -- the output oe and we will depend on the actual state only
        process(state_reg)
        begin
            -- default value
            oe <= '0';
            we <= '0';
            case state_reg is
                when idle =>
                    -- nothing changes
                when write =>
                    we <= '1';
                when read1|read2|read3|read4 =>
                    oe <= '1';
            end case;
            
        end process;
    end generate;
                
end plain_buffer_arch;