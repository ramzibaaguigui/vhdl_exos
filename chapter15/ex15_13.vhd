library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.13:
-- Repeat Problem 15.11, but modify the cell-base carry-ripple multiplier of Listing 15.19.

entity mult_array is 
    generic (
        -- N: natural;
        WIDTH_A: natural;
        WIDTH_B: natural
    );

    port(
        a_in: in std_logic_vector(WIDTH_A-1 downto 0);
        b_in: in std_logic_vector(WIDTH_B-1 downto 0);
        y: out std_logic_vector(WIDTH_A+WIDTH_B-1 downto 0)
    );
end mult_array;

architecture ripple_carry_arch of mult_array is 

    -- the thing that makes this exercise easy is that the choice of a and b to be considered as a controller
    -- for row or for columns does not make difference in the propagation delay of the final resulting circuit

    -- we observe from the design that
    -- we add these to parametrize the entire stuff
    constant ROW_COUNT: natural := WIDTH_A; -- depends on the width of A;
    constant COL_COUNT: natural := WIDTH_B; -- depends on the width of B;

    type two_d_type is 
        array (ROW_COUNT-1 downto 0) of std_logic_vector(COL_COUNT downto 0);
    
    signal ab, c, s: two_d_type;
    
    component fa
        port (  
            ai, bi, ci: in std_logic;
            so, co: out std_logic
        );  
    end component;

begin
    -- bit product
    g_ab_row:
    for i in 0 to ROW_COUNT-1 generate
        g_ab_col:
        for j in 0 to (COL_COUNT-1) generate
            ab(i)(j) <= a_in(j) and b_in(j);
        end generate;
    end generate;

    -- leftmost and rightmost column
    g_0_N_col:
    
    for i in 1 to (ROW_COUNT-1) generate
        c(i)(0) <= '0';
        s(i)(N) <= c(i)(N); -- left most column
    end generate;

    -- top row:
    s(0) <= ab(0);
    ab(0)(COL_COUNT) <= '0';

    -- middle rows: 
    g_fa_row:
    for i in 1 to (ROW_COUNT-1) generate -- rows
        g_fa_column:
        for j in 0 to (COL_COUNT-1) generate -- for columns
            u_middle: fa
                port map(
                    ai => ab(i)(j), bi => (i-1)(j+1), ci => c(i)(j),
                    so => s(i)(j), co => c(i)(j+1);
                );
        end generate;
    end generate;

    -- bottom row and output
    g_out:
    for i in 0 to (ROW_COUNT-2) generate
        y(i) <= s(i)(0);
    end generate;
    y(ROW_COUNT+COL_COUNT-1 downto ROW_COUNT-1) <= s(ROW_COUNT-1);

end ripple_carry_arch;

-- IT SHOULD BE OKAY FOR THIS EXERCISE