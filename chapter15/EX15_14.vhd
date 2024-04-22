library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.14:

-- Repeat Problem 15.11, but modify the cell-base carry-save multiplier of Listing 15.20

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

architecture carry_save of mult_array is 
    -- b_in is controlling the number of colums
    -- a_in is controlling the number of rows
    constant COL_COUNT: natural := WIDTH_B;
    constant ROW_COUNT: natural := WIDTH_A;

    type two_d_type is
        array(ROW_COUNT-1 downto 0) of std_logic_vector(COL_COUNT-1 downto 0);

    signal ab, c, s: two_d_type;
    -- From figure 15.13, is is clear that rc and rs are f(COL_COUNT)
    signal rs, rc: std_logic_vector(COL_COUNT-1 downto 0);

    component fa 
        port (
            ai, bi, ci: in std_logic;
            so, co: out std_logic
        );
    end component;

begin
    -- bit product:
    g_ab_row:
    for i in 0 to ROW_COUNT-1 generate
        g_ab_col:
        for j in 0 to (COL_COUNT-1) generate
            ab(i)(j) <= a_in(i) and b_in(j);
        end generate;
    end generate;

    -- left most column
    g_N_col:
    for i in 1 to (ROW_COUNT-1) generate
        s(i)(COL_COUNT-1) <= ab(i)(COL_COUNT-1);
    end generate;

    -- top row
    s(0) <= ab(0);
    c(0) <= (others => '0');

    -- moiddle rows
    g_fa_row:
    for i in 1 to (ROW_COUNT-1) generate
        g_fa_col:
        for j in 0 to (COL_COUNT-2) generate
            u_middle: fa
            port map(
                ai => ab(i)(j), bi => s(i-1)(j+1), ci => c(i-1)(j),
                so => s(i)(j), co => c(i)(j)
            );
        end generate;
    end generate;

    -- bottom row ripple adder
    rc(0) <= '0';

    g_acell_N_row:
    for j in 0 to (COL_COUNT-2) generate 
        unit_N_row: fa 
            port map(
                ai => s(N-1)(j+1), bi => c(N-1)(j), ci => rc(j), 
                so => rs(j), co => rc(j+1)
            );
    end generate;

    -- output signal
    g_out:
    for i in 0 to (ROW_COUNT-1) generate 
        y(i) <= s(i)(0);
    end generate;

    y(ROW_COUNT+COL_COUNT-2 downto ROW_COUNT) <= rs(COL_COUNT-2 downto 0);
    y(COL_COUNT+ROW_COUNT-1) <= rc(COL_COUNT-1);
end;

-- we should be done with this exercise as well
