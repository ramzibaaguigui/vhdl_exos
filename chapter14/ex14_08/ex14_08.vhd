-- EXERCISE 14.8:
-- Follow the technique of the reduced-and circuit of Listing 14.4.2, and derive a
-- parameterized VHDL code for the reduced-or circuit.

--- Here is the content of the Listing 14.4.2 ------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity reduced_xor is port (
    a: in std_logic_vector;
    y: out std_logic
); end reduced_xor;

architecture array_arch OF reduced_xor is
    
    constant WIDTH: natural := a'length;
    signal tmp : std_logic_vector(WIDTH - 1 DOWNTO 0);

    begin
    tmp <= (tmp(WIDTH - 2 downto 0) & '0') xor a;
    -- we can think of the above statement as
    -- tmp(i) <= tmp(i-1) xor a(i)
    -- when thinking in terms of vectors, we can write
    -- tmp(WIDTH-1 downto 0) <= (tmp(WIDTH-2 downto 0) & '0') xor a
    y <= tmp(WIDTH - 1);
END array_arch;

-- The beginning of the solution to EX14.8

entity reduced_and is
    port(
        a: in std_logic_vector;
        y: out std_logic
    );
end reduced_and;

architecture arch of reduced_and is 
    constant WIDTH: natural := a'length;
    signal tmp: std_logic_vector(WIDTH-1 downto 0);
    begin
        tmp <= (tmp(WIDTH-2 downto 0) & '1') and a;
        y <= tmp(WIDTH-1);
    end arch;

    -- end of ex 14.8
    