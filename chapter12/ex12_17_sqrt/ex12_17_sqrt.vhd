-- the following circuit calculate the sqrt(a**2 + b**2)
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
    type state_reg is (idle, s1, s2, s3, s4, s5);
    signal state_type: state_reg, state_next;
    signal a_reg, a_next: unsigned(7 downto 0);
    signal b_reg, b_next: unsigned(7 downto 0);
    signal c_reg, c_next: unsigned(7 downto 0);
    signal absolute_in, aboslute_out: std_logic_vector (7 downto 0);

    signal abs_one_in, abs_one_out: std_logic_vector(7 downto 0);
    signal abs_two_in, abs_two_out: std_logic_vector(7 downto 0);
    signal max_in_one, max_in_two: std_logic_vector(7 downto 0);
    signal max_out: std_logic_vector(7 downto 0);
    signal min_in_one, min_in_two: std_logic_vector(7 downto 0);
    signal min_out: std_logic_vector(7 downto 0);

    begin

        -- for the functional units, we have:
        -- 1. two absolute units
        -- 2. one max unit
        -- 3. one min unit
        -- data and state registers
        unit_abs1: entity work.absolute(Behavioral)
            port map(a => abs_one_in, y => abs_one_out);
        
        unit_abs2: entity work.absolute(Behavioral)
            port map(a => abs_two_in, y => abs_two_out);
        
        unit_max: entity work.max(Behavioral)
            port map (a => max_in_one, b => max_in_two, y => max_out);

        unit_min: entity work.min(Behavioral)
            port map(a => min_in_one, b => min_in_two, y => min_out);
        
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
                end if
            end process;

            process(state_reg, a_reg, b_reg, c_reg, start, a_in, b_in)
                begin
                    -- derault values
                    a_next <= a_reg;
                    b_next <= b_reg;
                    c_next <= c_reg;

                    case state_reg is
                        when idle =>
                            if (start = '1') then
                                -- take the vaules inside the registers
                                a_next <= a_in;
                                b_next <= b_in;
                                state_next <= s1;
                            else
                                state_next <= idle;
                            end if;
                        
                        when s1 =>
                            -- a <= abs(a)
                            abs_one_in <= a_reg;
                            a_next <= abs_one_out;

                            -- b <= abs(b)
                            abs_two_in <= b_reg;
                            b_next <= abs_two_out;
                            state_next <= s2;

                        when s2 =>
                            state_next <= s3;
                            -- c = max(a, b)
                            c_next <= max_out;
                            max_in_one <= a_reg;
                            max_in_two <= b_reg;
                        
                        when s3 =>
                            state_next <= s4;
                            -- a = min(a, b)
                            a_next <= min_out;
                            min_in_one <= a_reg;
                            min_in_two <= b_reg;

                            -- b = c - c*0.125
                            b_next <= c_reg - ('000' & c_reg(7 downto 3));
                        
                        when s4 =>
                            -- a <= b + a * 0.5
                            a_next <= b_reg + '0' & a_reg(7 downto 1);
                        
                        when s5 =>
                            -- a <= max(a, c)
                            a_next <= max_out;
                            max_in_one <= a_reg;
                            max_in_two <= c_reg;
                    end case;
                end process;
            -- output logic 
            r <= a_reg;
            ready <= '1' if state_reg = idle else '0';

    end Behavioral;
    -- THE CODE SHOUDL WORK AS EXPECTED
--     -----------
--     12.17 Consider the schedule in Figure 12.20(b).
-- (a) Map the variables into a minimum number of registers.
-- (b) Derive the ASMD chart for the schedule.
--     Recall that two arithmetic units are used in this schedule
-- (c) Derive the VHDL code.