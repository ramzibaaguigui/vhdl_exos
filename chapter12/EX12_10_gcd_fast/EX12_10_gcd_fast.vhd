library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gcd is port (
    clk, reset: in std_logic;
    start: in std_logic;
    a_in, b_in: in std_logic_vector(7 downto 0);
    ready: out std_logic;
    r: out std_logic_vector(7 downto 0) 
); end gcd;

-- done with the entity declaration

architecture fast_arch of gcd is
    type state_type is (idle, op, res);
    signal state_reg, state_next: state_type;
    signal a_reg, a_next: unsigned(7 downto 0);
    signal b_reg, b_next: unsigned(7 downto 0);
    signal n_reg, n_next: unsigned(7 downto 0);
    signal a_op, b_op: unsigned(7 downto 0);
    -- consider adding the a_op, b_op used for subtraction 

    -- state and data registers
begin    
    process(reset, clk)
        begin
            if (reset = '1') then
                -- reset all to default state
                a_reg <= (others => '0');
                b_reg <= (others => '0');
                n_reg <= (others => '0');
            elsif(clk'event and clk = '1') then --rising edge of clk
                a_reg <= a_next;
                b_reg <= b_next;
                n_reg <= n_next;
            end if;
        end process;
    
    -- state next logic, data path, routing logic
    process(state_reg, a_reg, b_reg, start, a_in, b_in, n_next)
        begin
            -- default values
            a_next <= a_reg;
            b_next <= b_reg;
            n_next <= n_reg;
            a_op <= a_reg;
            b_op <= b_reg;
            case state_reg is
                when idle => 
                    if start = '0' then
                        state_next <= idle;
                    else
                        state_next <= op;
                        -- take the input values into the registers
                        a_next <= unsigned(a_in);
                        b_next <= unsigned(b_in);
                        n_next <= (others => '0');
                    end if;
                
                    when op =>
                        if (a = b) then 
                            if (n = 0) then
                                state_next <= idle;
                            else -- if n not null
                                state_next <= res;
                            end if;
                        else -- a /= b
                            state_next <= op;
                            if (a(0) = '0') then -- if a is even
                                 -- a_next shifted to the right
                                 a_next <= '0' & a_reg(7 downto 1);
                                if (b(0) = '0') then
                                    b_next <= '0' & b_reg(7 downto 1);
                                    n_next <= n_reg + 1;
                                end if;
                            else -- if a is odd
                                if (b(0) = 0) then -- if b is even
                                    b_next <= '0' & b_reg (7 downto 1);
                                else
                                    if (a < b) then
                                        a_op <= b_reg;
                                        b_op <= a_reg;
                                    end if;
                                    a_next <= a_op - b_op;
                                end if;

                            end if;
                        end if;
                    
                    when res =>
                        n_next <= n_reg - 1;
                        a_next <= a_reg(6 downto 0) & '0';
                        if (n_next = 0) then 
                            state_next <= idle;
                        else 
                            state_next <= res;
                        end if;
            end case;
        end process;
        -- output logic
        ready <= '1' when state_reg = idle else '0';
        r <= std_logic_vector (a_reg);  
        -- this should be the code with the new version of the circuit
        -- with the swap and sub states merged
    end fast_arch;