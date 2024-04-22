library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.12
-- Repeat Problem 15.1 1, but modify the adder-based multiplier of Listing 15.17.


package util is
    
    
    
end package util;

package body util is
    
    
end package body util;

entity multn is
    generic (
        -- N: natural;
        WIDTH_A: natural;
        WIDTH_B: natural;
        WITH_PIPE: natural;
        PIPE_STAGES: natural
    );
    port (
        clk, reset: std_logic;
        a: in std_logic_vector(WIDTH_A-1 downto 0);
        b: in std_logic_vector(WIDTH_B-1 downto 0);
        y: out std_logic_vector(WIDTH_A + WIDTH_B-1 downto 0)
    );
end multn;

    -- we suppose that B is the smallest
    
architecture n_stage_pipe_arch of multn is 
    constant WIDTH_MIN: natural := min(WIDTH_A, WIDTH_B);
    constant WIDTH_MAX: natural := max(WIDTH_A, WIDTH_B);

    ------
    type std_aoa_n_type is
        array(N-2 downto 1) of std_logic_vector(N-1 downto 0);
    
    type std_aoa_min_type is 
        array(WIDTH_MIN-2 downto 1) of std_logic_vector(WIDTH_MIN-1 downto 0);
    
    type std_aoa_max_type is 
        array(WIDTH_MIN-2 downto 1) of std_logic_vector(WIDTH_MAX-1 downto 0);
    -- 

    type std_aoa_2n_type is
        array(N-1 downto 0) of unsigned(2*N-1 downto 0);

    type std_aoa_2m_type is 
        array(WIDTH_MIN-1 downto 0) of unsigned(WIDTH_MAX+WIDTH_MIN-1 downto 0);
    
    -- signal a_reg, a_next, b_reg, b_next: std_aoa_n_type;
    signal a_reg, a_next: std_aoa_max_type;
    signal b_reg, b_next: std_aoa_min_type;

    -- signal bp, pp_reg, pp_next: std_aoa_2n_type;
    signal bp, pp_reg, pp_next: std_aoa_2m_type;
    
    signal a_augmented: std_logic_vector(WIDTH_MAX-1 downto 0);
    signal b_augmented: std_logic_vector(WIDTH_MIN-1 downto 0);

    -- we should be done;
begin


    -- wiring augmented a and augmented b
    -- augmented a is the input signal that has max width
    -- augmented b is the input signal that has min width
    
    -- if the width(a) > width(b)
    if(a'width > b'width) generate 
        a_augmented <= a;
        b_augmented <= b;
    end generate;

    -- if width(b) >= width(a)
    if ((a'width = b'width) or (b'width > a'width)) generate
        a_augmented <= b;
        b_augmented <= a;
    end generate;

    -- part 1
    -- without pipeline buffers
    g_wire:
    if (WITH_PIPE /= 1) generate 
        a_reg <= a_next;
        b_reg <= b_next;
        pp_reg(WIDTH_MIN-1 downto 1) <= pp_next(WIDTH_MIN-1 downto 1);
    end generate;

    -- most of the work will be done on this block
    -- in order to control the number of pipeline blocks that will be inferred in the design
    -- we need to explicit the below part

    -- with pipeline buffer
    if (WITH_PIPE = 1) generate 
        
        -- NOTE: In some way, we transformed the below code into a more loopy explicit code (show above)
        -- there is one special case for pp_reg(N-1): its code is written explcitly
        process(clk, reset)
        begin
            if (reset = '1') then 
                a_reg <= (others => (others => '0'));
                b_reg <= (others => (others => '0'));
                pp_reg(N-1 downto 1) <= (others => (others => '0'));
            elsif(clk'event and clk = '1') then
                a_reg <= a_next;
                b_reg <= b_next;
                pp_reg(WIDTH_MIN-1 downto 1)  <= pp_next(WIDTH_MIN-1 downto 1);
            end if;
        end process;
    end generate;


    -- part 2:
    -- bit product generation
    process(a, b, a_reg, b_reg)
    begin
        -- bp(0) and bp(1)
        for i in 0 to 1 loop
            bp(i) <= (others => '0');
            for j in 0 to WIDTH_MAX-1 loop
                bp(i)(i+j) <= a_augmented(j) and b_augmented(i);
            end loop;
        end loop;   

        
        -- regular bp
        for i in 2 to (WIDTH_MIN-1) loop
            bp(i) <= (others => '0');
            
            for j in 0 to (WIDTH_MAX-1) loop
                bp(i)(i+j) <= a_reg(i-1)(j) and b_reg(i-1)(i);
            end loop;   
        end loop;
    end process;

    -- part 3:
    -- addition of the first stage:
                
    pp_next(1) <= bp(0) + bp(1);
    a_next(1) <= a_augmented;
    b_next(l) <= b_augmented;

    -- addition of the middle stages:
    -- the number of stages will be MIN_WIdt - 1
    g1:
    for i in 2 to (WIDTH_MIN-2) generate
        pp_next(i) <= pp_reg(i-1) + bp(i);
        a_next(i) <= a_reg(i-1);
        b_next(i) <= b_reg(i-1);
    end generate;

    -- addition of the last stage
    pp_next(WIDTH_MIN-1) <= pp_reg(WIDTH_MIN-2) + bp(WIDTH_MIN-1);

    -- rename output
    y <= std_logic_vector(pp_reg(N-1));
                
end n_stage_pipe_arch;


-- WE SHOULD BE DONE WITH THIS EXERCISE
-- we consider that a represents the signal that has the max width
-- b represents the signal that has min width

-- In the first place, we rout a and b to a_augmented and b_augmented
-- and then any further processing will be done on a augmented and b augmented

-- for better performance, the number of stages will be f(WIDTH_MIN) to minimize the propagation delay
-- 
-- The challenge of this exercise was to decide to replace N with.
-- Since in the intial code , we had both a and b having the same length, the usage of N in the code is 
-- sometimes dependent on a and other times dependent on b
-- and thus now, after having each one represented with its own width
-- we can make the difference
-- this exercise should be done.