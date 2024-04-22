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
        N: natural,
        WITH_ZERO: natural,
        M: natural
    );
    
    port (
        clk, reset: in std_logic;
        q: out std_logic_vector(N-1 downto 0)
    );
end lfsr;

architecture para_arch of lfsr is 
    constant MAX_N: natural := 8;
    constant SEED: std_logic_vector(N-1 downto 0)
        := (0 => '1', others => '0');
    
    type tap_array_type is array (2 to MAX_N) of
        std_logic_vector(MAX_N-1 downto 0);

    constant TAP_CONSTANT_ARRAY: tap_array_type := 
        (
            2 => (1|0=>'1', others => '0'),
            3 => (1|0=>'1', others => '0'),
            4 => (1|0=>'1', others => '0'),
            5 => (2|0=>'1', others => '0'),
            6 => (1|0=>'1', others => '0'),
            7 => (3|0=>'1', others => '0'),
            8 => (4|3|2|0=>'1', others => '0')
        );
    
    signal r_reg, r_next: std_logic_vector(N-1 downto 0);
    signal regular_feedback, zero, fzero: std_logic;

    function generateMaskForWidth(w: natural) return std_logic_vector(N-1 downto 0) is 
        constant MASK_ARRAY: tap_array_type := 
        (
            2 => (1|0=>'1', others => '0'),
            3 => (1|0=>'1', others => '0'),
            4 => (1|0=>'1', others => '0'),
            5 => (2|0=>'1', others => '0'),
            6 => (1|0=>'1', others => '0'),
            7 => (3|0=>'1', others => '0'),
            8 => (4|3|2|0=>'1', others => '0')
        ); 
        variable result: std_logic_vector(N-1 downto 0);
    begin
        -- we suppose that the user gives a N withing the range of the allowed values
        result := MASK_ARRAY(W)(N-1 downto 0);
        return result;
    end function;
begin
    -- register
    process(clk, reset) 
    begin
        if (reset = '1') then 
            r_reg <= SEED;
        elsif (clk'event and clk = '1') then
            r_reg <= r_next;
        end if;
    end;

    -- regular next state logic
    process(r_reg)
        variable mask: std_logic_vector(N-1 downto 0);
        variable qualified: std_logic_vector(N-1 downto 0);
        
        variable tmp: std_logic;
    begin
        mask := generateMaskForWidth(N);
        qualified := mask and r_reg;

        tmp := '0';
        for i in 0 to (N-1) loop
            tmp : = tmp xor qualified(i);
        end loop;
        regular_feedback <= tmp;
    end process;

    -- with all zeros state
    gen_zero:
    if (WITH_ZERO=1) generate
        zero <= '1' when r_reg(N-1 downto 1) = (
            r_reg(N-1 downto 1)'range => '0'
        ) else '0';

        fzero <= zero xor fb;
    end generate;

    -- without all zero state
    if (WITH_ZERO /= 1) generate
        fzero <= regular_feedback;
    end generate;

    r_next <= fzero & r_reg (N-1 downto 1);

    -- output logic
    q <= r_reg;
end para_arch;

-- while solving this exercise, we will just change the point of view from which we are approaching the problem
-- since not all bits are making contribution to the next state logic, 
-- we need to declare a mask generating function, which takes the number of input bits in and returns 
-- the mask that should be used for that number of bits

