library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- Exercise 15.16:
-- The parameterized LFSR of Section 15.4.3 can only circulate through 2**N - 1 or
-- 2**N patterns. Modify the design so that the LFSR can circulate through M patterns, where
-- M is a separate parameter and M < 2**N . You can create a function that determines the
-- M-th pattern in the LFSR

entity lfsr is
    generic (
        WIDTH: natural,
        MAX_COUNT: natural := (2**WIDTH - 1),
        WITH_ZERO: natural
    );

    port (
        clk, reset: in std_logic;
        q: out std_logic_vector(WIDTH-1 downto 0)
    );
end lfsr;

architecture arch of lfsr is 
    
    -- generate the mask for the bits that contribute to the next value of the Q register
    -- for example, in cases where WIDTH is in (2, 3, 4), only the indices 0 and 1 are considered 
    -- to generate the feedback bit
    constant MASK_ARRAY: array (MAX_WIDTH downto 2) of std_logic_vector(MAX_WIDTH-1 downto 0)
        := (
            2 => (1|0=>'1', others => '0'),
            3 => (1|0=>'1', others => '0'),
            4 => (1|0=>'1', others => '0'),
            5 => (2|0=>'1', others => '0'),
            6 => (1|0=>'1', others => '0'),
            7 => (3|0=>'1', others => '0'),
            8 => (4|3|2|0=>'1', others => '0')
        );
    

    function generateMaskForWidth(w: natural) return std_logic_vector(WIDTH-1 downto 0) is 
    variable result: std_logic_vector(WIDTH-1 downto 0);
    begin
    if (((w > 2) or (w = 2)) and ((w = 8) or (w < 8))) then 
        result := MASK_ARRAY(w);
    else
        -- result := 
        error "the supported lengths are between 2 and 8";
    end if;
    return result;
    end function;


    function generateNextRegularPattern(current: std_logic_vector(WIDTH-1 downto 0)) return std_logic_vector(WIDTH-1 downto 0) is
        constant MASK: std_logic_vector(WIDTH-1 downto 0) := generateMaskForWidth(WIDTH);
        variable fb_bit: std_logic;
        variable qualified: std_logic_vector(WIDTH-1 downto 0);
    begin
        qualified := current and MASK;
        -- calculating the feedback bit

        fb_bit := '0';
        for i in 0 to WIDTH-1 loop
            fb_bit := fb_bit xor qualified(i);
        end loop;
        return (fb_bit & current(WIDTH-1 downto 1));
    end function;

    function generateMaxPattern(max_count: natural) return std_logic_vector(WIDTH-1 downto 0) is
        variable tmp: std_logic_vector(WIDTH-1 downto 0);
        variable count: natural;
    begin
        count := 1;
        tmp := (0 => '1', others => '0');
        while (count < max_count) loop
            count := count + 1;
            tmp := generateNextRegularPattern(tmp);
        end loop;
        return tmp;
    end function;

    constant SEED: std_logic_vector(WIDTH-1 downto 0) := (0 => '1', others => '0');
    constant ZERO: std_logic_vector(WITH-1 downto 0) := (others => '0');
    constant MAX_PATTERN: std_logic_vector(WIDTH-1 downto 0) := generateMaxPattern(MAX_COUNT);
    constant MAX_WIDTH: natural := 8; -- the max width for which we have included the next value mask
    

    signal q_reg, q_next: std_logic_vector(WIDTH-1 downto 0);
    signal regular_q_next: std_logic_vector(WIDTH-1 downto 0);
    
    signal q_is_max: std_logic;
    
    -- tells whether the current value of q is zero
    -- this should be only used when the WITH_ZERO generic is enabled
    signal q_is_zero: std_logic;


    -- signal regular_fb_bit: std_logic;
    signal q_next_regular: std_logic_vector(WIDTH-1 downto 0);

begin
    -- registers
    process(clk, reset) 
    begin
        if (reset = '1') then 
            q_reg <= SEED;
        elsif (clk'event and clk = '1') then
            q_reg <= q_next;
        end if;
    end process;

    -- The regular feedback bit
    process(q_reg) 
        variable tmp: std_logic;
        
        constant mask: std_logic_vector(WIDTH-1 downto 0) := generateMaskForWidth(WIDTH);
        variable qualified: std_logic_vector (WIDTH-1 downto 0);
    begin
        qualified := mask and q_reg;
        tmp := '0';
        for i in 0 to WIDTH-1 loop
            tmp := tmp xor qualified(i);
        end loop;
        regular_fb_bit <= tmp;
    end process;

    -- THE REGULAR NEXT Q
    q_next_regular <= generateNextRegularPattern(q_reg);

    -- flag that is asserted when q_reg = max_pattern
    q_is_max <= '1' when (q_reg = MAX_PATTERN) else '0';

    -- HERE, WE SHOULD HANDLE THE SPECIAL CASES, like :
    -- with zero 
    -- without zero
    -- max value that can be achieved
    
    -- next q logic
    -- when WITH_ZERO generic is enabled
    g_with_zero:
    if (WITH_ZERO = 1) generate
        q_is_zero <= '1' when (unsigned(q_reg) = 0) else '0';
        
        with (q_is_max & q_is_zero) select
            q_next <= ZERO           when "10" , -- when q_reg is max
                        SEED           when "01", -- when q_reg is zero
                        q_next_regular when others -- the other remaining combinations
        
    end generate;

    -- next q logic
    -- when WITH_ZERO GENERIC is not enabled
    g_without_zero:
    if (WITH_ZERO /= 1) generate 
        q_next <= SEED when (q_is_max = '1') else q_next_regular;
    end generate;
    
    -- output logic
    q <= q_reg;
end;

-- We should be all done with the requirements of the exercise
-- we considered the with zero generic
-- we considered the max count generic as well
-- it should be all done