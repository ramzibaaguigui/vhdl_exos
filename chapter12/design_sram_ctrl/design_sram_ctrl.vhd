library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sram_ctrl is port(
    d: inout std_logic;
    reset, clk: in std_logic;
    mem, rw: in std_logic;
    addr: in std_logic_vector(19 downto 0);
    data_m2s: in std_logic;
    we, oe: out std_logic;
    ready: out std_logic;
    data_s2m: out std_logic;
    ad: out std_logic_vector(19 downto 0)
); end sram_ctrl;
-- this is the declaration of the entity
-- now, we consider declaring the architecture
-- here, we are just copying the content of the exising solution
-- this will be refined to become compatible with the requirements of the FIFO memory
architecture archi of sram_ctrl is
    type state_type is (idle, r1, r2, r3, r4, r5, w1, w2, w3, w4, w5);
    signal state_reg, state_next: state_type;
    signal data_m2s_reg, data_m2s_next: std_logic;
    signal data_s2m_reg, data_s2m_next: std_logic;
    signal addr_reg, addr_next: std_logic_vector(19 downto 0);
    signal tri_en_buf, we_buf, oe_buf: std_logic;
    signal tri_en_reg, we_reg, oe_reg: std_logic;
begin
    -- state & data register
    process(clk, reset) 
        begin
            if (reset = '1') then
                -- reset all to default
                state_reg <= idle;
                addr_reg <= (others => '0');
                data_m2s_reg <= '0';
                data_s2m_reg <= '0';
                tri_en_reg <= '1';
                oe_reg <= '1';
            elsif (clk'event and clk = '1') then
                state_reg <= state_next; 
                addr_reg <= addr_next;
                data_m2s_reg <= data_m2s_next; 
                data_s2m_reg <= data_s2m_next; 
                tri_en_reg <= tri_en_buf;
                oe_reg <= oe_buf;
            end if;
        end process;

        -- next state logic
        -- datapath and function units/ routing logic
        -- data_s2m,
        process(state_reg, mem, rw, d, addr, data_m2s, data_m2s_reg,  data_s2m_reg, addr_reg)
            begin
                addr_next <= addr_reg;
                data_m2s_next <= data_m2s_reg;
                data_s2m_next <= data_s2m_reg;
                ready <= '0';
                case state_reg is 
                    when idle => 
                        if mem = '0' then
                            state_next <= idle;
                        else
                            if rw = '0' then -- write
                                state_next <= w1;
                                addr_next <= addr; -- addr is the input
                                data_m2s_next <= data_m2s; -- the data to be sent to the sram
                            else
                                state_next <= r1;
                                addr_next <= addr; -- the target address in sram
                            end if;
                        end if;
                        ready <= '1';
                    
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

    -- output
    we <= we_reg;
    oe <= oe_reg; 
    ad <= addr_reg;
    d <= data_m2s_reg when tri_en_reg = '1' else 'Z';
    data_s2m <= data_s2m_reg;
end archi;

