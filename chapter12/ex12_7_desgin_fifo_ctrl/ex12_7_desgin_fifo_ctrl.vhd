
-- the changes that will be made will be commented
-- we will consider the same params as in the template design 
-- 20 bit address and 1 bit data
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sram_ctrl is port(
    d: inout std_logic;
    reset, clk: in std_logic;
    -- mem, rw: in std_logic;
    -- we no longer need these, they will be replaced with rd, wr
    rd, wr: in std_logic;
    
    -- addr: in std_logic_vector(19 downto 0);
    -- the address is no longer needed, this will be held internally
    
    -- equivalent for the data_in
    data_m2s: in std_logic;

    -- these will be conserved with the same logic as before
    we, oe: out std_logic;

    -- this will be conserved as well with the same logic as before
    ready: out std_logic;

    -- equivalent to the data_out
    data_s2m: out std_logic;

    -- the outgoing address to the sram
    ad: out std_logic_vector(19 downto 0);

    -- we will add the status signals
    full, empty: out std_logic

    -- we should be done with all the inputs
); end sram_ctrl;
-- making some refinements to become compatible with 
-- the FIFO controller
architecture archi of sram_ctrl is
    -- nothing will be changed concerning the states
    type state_type is (idle, r1, r2, r3, r4, r5, w1, w2, w3, w4, w5);
    signal state_reg, state_next: state_type;
    
    -- nothing will be changed concerning these as well
    signal data_m2s_reg, data_m2s_next: std_logic;
    signal data_s2m_reg, data_s2m_next: std_logic;

    -- the value of addr_reg is no longer coming from the outside
    -- we support it with two additional registers:
    -- read_ptr_reg, write_ptr_reg
    -- the value of addr_reg will be taken either from: 
    -- read_ptr_reg or write_ptr_reg
    signal addr_reg, addr_next: unsigned(19 downto 0);
    signal read_ptr_reg, read_ptr_next: unsigned(19 downto 0);
    signal write_ptr_reg, write_ptr_next: unsigned(19 downto 0);

    -- nothing will be changed concerning this
    signal tri_en_buf, we_buf, oe_buf: std_logic;
    signal tri_en_reg, we_reg, oe_reg: std_logic;
    
    -- we will consider buffering the output of: 
    -- empty, full signals
    signal is_empty_reg, is_empty_buf: std_logic;
    signal is_full_reg, is_full_buf: std_logic;
begin
    -- state & data register
    process(clk, reset) 
        begin
            if (reset = '1') then
                -- reset all to default
                -- we reset all the added register to default
                state_reg <= idle;
                addr_reg <= (others => '0');
                read_ptr_reg <= (others => '0');
                write_ptr_reg <= (others => '0');

                data_m2s_reg <= '0';
                data_s2m_reg <= '0';
                
                tri_en_reg <= '1';
                oe_reg <= '1';

                -- we reset the empty and full values as well
                is_full_reg <= '0';
                is_empty_reg <= '1';

            elsif (clk'event and clk = '1') then
                state_reg <= state_next; 
                addr_reg <= addr_next;
                read_ptr_reg <= read_ptr_next;
                write_ptr_reg <= write_ptr_next;

                data_m2s_reg <= data_m2s_next; 
                data_s2m_reg <= data_s2m_next;

                tri_en_reg <= tri_en_buf;
                oe_reg <= oe_buf;

                -- the full and empty status signals
                is_full_reg <= is_full_buf;
                is_empty_reg <= is_empty_buf;
            end if;
        end process;

        -- next state logic
        -- datapath and function units/ routing logic
        -- data_s2m,
        process(state_reg, rd, wr, d, data_m2s, data_m2s_reg,  data_s2m_reg, addr_reg)
            begin
                -- we add these two
                read_ptr_next <= read_ptr_reg;
                write_ptr_next <= write_ptr_reg;

                addr_next <= addr_reg;
                data_m2s_next <= data_m2s_reg;
                data_s2m_next <= data_s2m_reg;
                ready <= '0';
                case state_reg is 
                    when idle =>
                        -- if mem = '0' then
                        if rd = '0' and wr = '0' then -- no read or write
                            state_next <= idle;
                        else
                            -- if rw = '0' then -- write
                            --     state_next <= w1;
                            --     addr_next <= addr; -- addr is the input
                            --     data_m2s_next <= data_m2s; -- the data to be sent to the sram
                            -- else
                            --     state_next <= r1;
                            --     addr_next <= addr; -- the target address in sram
                            -- end if;
                            
                            -- we give the priority to the reading op
                            if (rd = '1') and not (is_empty_reg = '1') then
                                -- begin the read op
                                state_next <= r1;
                                addr_next <= read_ptr_reg;
                                read_ptr_next <= read_ptr_reg + 1;

                            elsif (wr = '1') and not (is_full_reg = '1') then
                                -- begin the write op
                                state_next <= w1;
                                addr_next <= write_ptr_reg;
                                write_ptr_next <= write_ptr_reg + 1;
                                data_m2s_next <= data_m2s;
                            else
                                state_next <= idle;
                            end if;
                            -- this should be the entire logic that
                            -- we need to handle
                        end if;
                        ready <= '1';
                    -- nothing will be changed here
                    when w1 => state_next <= w2;
                    when w2 => state_next <= w3;
                    when w3 => state_next <= w4;
                    when w4 => state_next <= w5;
                    when w5 => state_next <= idle;

                    when r1 => state_next <= r2;
                    when r2 => state_next <= r3;
                    when r3 => state_next <= r4;
                    when r4 => state_next <= r5;
                    when r5 =>
                        state_next <= idle; 
                        data_s2m_next <= d;
                end case;
        
                    
            end process;
    -- lookahead output logic
    process(state_next)
        -- every time the stat_next signal changes
        begin
            tri_en_buf <= '0';
            oe_buf <= '1';
            we_buf <= '1';
            
            case state_next is
                when w1|idle =>
                when w2|w3|w4 =>
                    we_buf <= '0';
                    tri_en_buf <= '1';
                when w5 =>
                    tri_en_buf <= '1';
                when r1|r2|r3|r4|r5 => 
                    oe_buf <= '0';
            end case;
        end process;

    
    ------------------------------------------------------------
    -- the status signals
    -- We should find a way to extrac the value of the full
    -- and the empty status signals from the values of the
    -- the read and write addresses
    -- something to note that led us to this reasoning
    -- if read_ptr = write_ptr -> full or empty
    -- but we should find a way to differentiate between the two cases
    -- So, we consider the problem froma dynamic poing of view
    -- and we adopt the following reasoning
    -- if read_ptr_next = write_ptr_reg => 
    --                              we will attempt to read a mem
    --                              location that is not yet written
    --                              underflow
    --                              which means that the empty_next <= '1'
    -- in the other sense
    -- if write_ptr_next = read_ptr_reg =>
    --                              we will attempt to write a mem
    --                              location that is not yet read
    --                              overflow
    --                              which means that the full_next <= '1'
    -- -- -- 
    -- we code the above logic inside the above process
    process(read_ptr_reg, read_ptr_next, write_ptr_reg, write_ptr_next)
        begin
            -- default values:
            is_full_buf <= '0';
            is_empty_buf <= '0';

            -- is_empty logic
            if (read_ptr_next = write_ptr_reg) then -- underflow
                is_empty_buf <= '1';
            end if;

            -- is_full logic
            if (write_ptr_next = read_ptr_reg) then --= overflow
                is_full_buf <= '1';
            end if;
        end process;

    -- output
    we <= we_reg;
    oe <= oe_reg; 
    ad <= std_logic_vector(addr_reg);
    d <= data_m2s_reg when tri_en_reg = '1' else 'Z';
    data_s2m <= data_s2m_reg;
    

    -- the full and empty status signals:
    full <= is_full_reg;
    empty <= is_empty_reg;
end archi;

-- this should be all done
-- now, we copy the code to the paper 
-- and add the testing code
-- WE should learn the UVM
