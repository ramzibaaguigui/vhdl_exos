-- Multiplication can be implemented by performing additions of shifted bit-products,
-- as discussed in Section 7.5.4. Let p7, p6, . . . , p1, po be the shifted bit-products of an &bit
-- multiplier. The final product can be expressed as
-- y <= p7 + p6 + p5 + ... + p1 + p0

-- (a)Derive the dataflow graph for the expression. Arrange the additions as a tree to
-- (b) Assume that only one adder is provided. Derive a schedule.
-- (c) Derive the ASMD chart for the schedule. Use a minimal number of registers in
--     the chart.
-- (d) derive the VHDL code
-- (e) Discuss the difference between this design and the sequential multiplier in 
--     Section 11.6

-- in this exercises, we will need an adder
-- so we will first define an adder
-- since the multipliers are 8-bit
-- the adder should be 16-bit wide
entity adder is port(
    a, b: in    std_logic_vector(15 downto 0);
    y   : out   std_logic_vector(15 downto 0)
); end adder;

-- the architecture of the adder
architecture Behavioral of adder is
    begin
        y <= std_logic_vector(unsigned(a) + unsigned(b));
    end Behavioral;

-- done with the multipler

entity multiplier is port(
    start: in std_logic;
    a_in, b_in: in std_logic_vector(7 downto 0);
    y   : out std_logic_vector(15 downto 0);
    ready: out std_logic;
)

architecture Behavioral of multiplier is
    type state_type is (idle, s1, s2, s3, s4, s5, s6, s7);
    signal state_reg, state_next: state_type;
    
    -- the internal registers are of 16-bit
    signal a_reg, a_next: std_logic_vector(15 downto 0);
    signal b_reg, b_next: std_logic_vector(15 downto 0);
    signal c_reg, c_next: std_logic_vector(15 downto 0);
    signal d_reg, d_next: std_logic_vector(15 downto 0);

    signal adder_in_one, adder_in_two: std_logic_vector(15 downto 0);
    signal adder_out: std_logic_vector(15 downto 0);
    
    -- the partial products
    signal p0, p1, p2, p3, p4, p5, p6, p7: std_logic_vector(15 downto 0);

    begin
        -- the adder unit
        adder_unit: entity work.adder(Behavioral)
            port map(a => adder_in_one, b => adder_in_two, y => adder_out);
        
        -- state and data registers
        process(clk, reset)
            begin
                if (reset = '1') then -- reset all to default
                    state_reg <= idle;
                    a_reg <= (others => '0');
                    b_reg <= (others => '0');
                    c_reg <= (others => '0');
                    d_reg <= (others => '0');
                elsif(clk'event and clk = '1') then -- take next value
                    a_reg <= a_next;
                    b_reg <= b_next;
                    c_reg <= c_next;
                    d_reg <= d_next;
                end if;
            end process;
        -- done with the data and state registers

        -- a funtion that repeats the input bit 16 times and returns the vector
        function repeat_16(b: std_logic) 
                return std_logic_vector(15 downto 0) is
            variable result: std_logic_vector (15 downto 0) := (others => '0');
            begin
                result := (others => b);
                return result; 
            end repeat_16;
        
        

        -- the assignment of p0, p1, ..., p7
        -- NOTE: Pi <= (a_reg << i) * b(i)
        -- p0
        p0 <= (a_reg(15 downto 0))              and repeat_16(b_reg(0));
        p1 <= (a_reg(14 downto 0) & "0")        and repeat_16(b_reg(1));
        p2 <= (a_reg(13 downto 0) & "00")       and repeat_16(b_reg(2));
        p3 <= (a_reg(12 downto 0) & "000")      and repeat_16(b_reg(3));
        p4 <= (a_reg(11 downto 0) & "0000")     and repeat_16(b_reg(4));
        p5 <= (a_reg(10 downto 0) & "00000")    and repeat_16(b_reg(5));
        p6 <= (a_reg(9  downto 0) & "000000")    and repeat_16(b_reg(6));
        p7 <= (a_reg(8  downto 0) & "0000000")   and repeat_16(b_reg(7));
        -- end of pi assignment    
        
        -- for this part, we need to refer to ASMD chart documentation
        -- and the register mapping for each theorectical variable
        process(state_reg, a_reg, b_reg, c_reg, d_reg, start, a_in, b_in)
            begin
                -- default next values
                a_next <= a_reg;
                b_next <= b_reg;
                c_next <= c_reg;
                d_next <= d_reg;
                
                case state_reg is
                    when idle =>
                        if (start = '1')
                            -- take the values in
                            a_next <= '00000000' & a_in;
                            b_next <= '00000000' & b_in;
                            -- move to s1
                            state_next <= s1;
                        else -- if start /= 1
                            -- rest in idle state
                            state_next <= idle;
                        end if;

                    when s1 =>
                        -- c <= p0 + p1 
                        
                        -- configure the adder to perform this operation
                        -- the p0 and p1 are decalred as signals
                        adder_in_one <= p0;
                        adder_in_two <= p1;
                        c_next <= adder_out;
                        state_next <= s2;

                    when s2 => 
                        -- d <= p3 + p2
                        adder_in_one <= p2;
                        adder_in_two <= p3;
                        d_next <= adder_out;
                        state_next <= s3;
                         
                    when s3 => 
                        -- c <= c + d;
                        adder_in_one <= c_reg;
                        adder_in_two <= d_reg;
                        c_next <= adder_out;
                        state_next <= s4;

                    when s4 => 
                        -- d <= p6 + p7
                        adder_in_one <= p6;
                        adder_in_two <= p7;
                        d_next <= adder_out;
                        state_next <= s5;

                    when s5 =>
                        -- a <= p5 + p4
                        adder_in_one <= p5;
                        adder_in_two <= p4;
                        a_next <= adder_out;
                        state_next <= s6;
                    
                    when s6 =>
                        -- a <= a + d
                        adder_in_one <= a_reg;
                        adder_in_two <= d_reg;
                        a_next <= adder_out;
                        state_next <= s7;
                
                    when s7 =>

                        -- a <= a + d
                        adder_in_one <= a_reg;
                        adder_in_two <= c_reg;
                        a_next <= adder_out;
                        state_next <= idle;
            end process;

        -- output logic
        y <= a_reg;
        ready <= '1' when state_reg = idle else '0';
        -- we should be done
    end Behavioral;