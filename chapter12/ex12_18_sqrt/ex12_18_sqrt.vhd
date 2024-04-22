library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- in this design, we will consider that the width of the input is 8 bits
-- before starting, we need to define the aboslute value circuit
entity absolute is port (
    a: in std_logic_vector(7 downto 0);
    y: out std_logic_vector(7 downto 0)
); end absolute;

entity  Behavioral of absolute is
    begin
        y <= a when a(7) = '0' -- the value is already positive
        else std_logic_vector(unsigned('11111111' xor a) + 1);
    end Behavioral;
    -- done for the absolute value circuit

entity max is port(
    a, b: in std_logic_vector(7 downto 0);
    y: out std_logic_vector(7 downto 0)
); end max;

architecture Behavioral of max is
    begin
        y <= a when a > b else b;
    end Behavioral;

entity min is port(
    a, b: in std_logic_vector(7 downto 0);
    y: out std_logic_vector(7 downto 0)
); end min;
architecture Behavioral of min is
    begin
        y <= a when a < b else b;
    end Behavioral;

entity sqrt is port(
    clk, reset: in std_logic;
    start: in std_logic;
    a_in: in std_logic_vector(7 downto 0);
    b_in: in std_logic_vector(7 downto 0);
    r: out std_logic_vector(7 downto 0);
    ready: out std_logic;
); end sqrt;

architecture Behavioral of sqrt is
    type state_type is (idle, s1, s2, s3, s4, s5, s6, s7);
    signal state_reg, state_next: state_type;
    
    signal a_reg, a_next: std_logic_vector(7 downto 0);
    signal b_reg, b_next: std_logic_vector(7 downto 0);
    signal c_reg, c_next: std_logic_vector(7 downto 0);
    -- the inputs and outputs for the functional units
    -- min, max, abs
    -- for the abs unit
    signal abs_in, abs_out: std_logic_vector(7 downto 0);

    -- the the max unit
    signal max_in_one, max_in_two, max_out: std_logic_vector(7 downto 0);

    -- for the min unit
    signal min_in_one, min_in_two, min_out: std_logic_vector(7 downto 0);
    begin

        -- the functional units
        unit_abs: entity work.absolute(Behavioral)
            port map(a => abs_in, y => abs_out)
        
        unit_max: entity work.max(Behavioral)
            port map(a => max_in_one, b => max_in_two, y => max_out);
        
        unit_min: entity work.min(Behavioral)
            port map(a => min_in_one, b => min_in_two, y => min_out);
        
        -- state and data registers
        process(clk, reset)
            begin
                if (reset = '1') then -- reset all to default
                    state_reg <= idle;
                    a_reg <= (others => '0');
                    b_reg <= (others => '0');
                    c_reg <= (others => '0');
                elsif (clk'event and clk = '1') then
                    state_reg <= state_next;
                    a_reg <= a_next;
                    b_reg <= b_next;
                    c_reg <= c_next;
                end if;
            end process;

        -- next state logic
        process(state_reg, a_reg, b_reg, a_in, b_in, start)
            begin
                -- default states
                a_next <= a_reg;
                b_next <= b_reg;
                case state_reg is
                    when idle => 
                        if (start = '1') then
                            state_next <= s1;
                            a_next <= a_in;
                            b_next <= b_in;
                        else 
                            state_next <= idle;
                        end if;
                    
                    when s1 =>
                        -- a <= abs(a)
                        abs_in <= a_reg;
                        a_next <= abs_out;
                        state_next <= s2;
                    
                    when s2 =>
                        -- b <= abs(b)
                        abs_in <= b_reg;
                        b_next <= abs_out;
                        state_next <= s3;

                    when s3 =>
                        -- b <= min(a, b)
                        c_next <= min_out;
                        min_in_one <= a_reg;
                        min_in_two <= b_reg;
                        state_next <= s4;

                    when s4 =>
                        -- a = max (a, b)   
                        a_next <= max_out;
                        max_in_one <= a_reg;
                        max_in_two <= b_reg;
                        state_next <= s5;
                        
                    when s5 =>
                        -- b <= a - 0.125 * a
                        b_next <= std_logic_vector(
                            unsigned(a_reg) - unsigned('000' & a_reg (7 downto 3))
                        );
                    when s6 => 
                        -- b <= c * 0.5 + b
                        b_next <= '0' & c_reg(7 downto 1) + b_reg;
                        -- there might be some type errors
                    
                    when s7 =>
                        -- b <= max (a, b)
                        b_next <= max_out;
                        max_in_one <= a_reg;
                        max_in_two <= b_reg;
                        state_next <= idle;
                end case;
            end process;
                            
        -- output logic
        ready <= '1' when state_reg = idle else '0';
        r <= b_reg;
    end Behavioral;

    -- done with Ex 12.18
    --
    -- Exercise statement:
--      -> Repeat Problem 12.17 for the schedule in Figure 12.21. Note that only one arithmetic
--     unit is used in this schedule.
