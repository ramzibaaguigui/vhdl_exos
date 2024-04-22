-- 14.4 
-- Repeat Problem 14.2,
-- but use conditional generate statements for the boundary cells.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity incrementor is 
    generic(
        WIDTH: natural
    );
    port(
        cin: in std_logic;
        a: in std_logic_vector(WIDTH-1 downto 0);
        s: out std_logic_vector(WIDTH-1 downto 0);
        cout: out std_logic
    );
end incrementor;


architecture arch of incrementor is
    signal cin_vector: std_logic_vector(WIDTH-1 downto 0);
    signal cout_vector: std_logic_vector(WIDTH-1 downto 0);
    begin
        -- use the VHDL logical operators only
        
        
        generator:
        for i in 0 to WIDTH-1 generate
            s(i) <= cin_vector(i) xor a(i);
            cout_vector(i) <= a(i) and cin_vector(i);
        end generate;

        -- the right most carry in and
        -- the left most carry out
        -- -- -- -- 
        -- the above statements should be removed in Exercise 4 and replaced with 
        -- the conditional generate blocks inside the for generate block
        -- cin_vector(0) <= cin;
        -- cout <= cout_vector(WIDTH-1);
        
        -- the remaining wiring between the carry in and carry out
        wire_generator:
        for i in 1 to WIDTH-1 generate
            -- the right most wirig
            -- the carry in wire
            rightmost:
            if (i = 0) generate
                cin_vector(i) <= cin;
            end generate;

            -- the left most wiring
            -- the carry out logic
            leftmost:
            if (i = WIDTH-1) generate
                cout <= cout_vector(i);
            end generate;

            cin_vector(i) <= cout_vector(i-1);
        end generate;
        
    end arch;
    
    -- FOR THIS EXERCISE, the introduce complexity has no meaning
    -- but just doing it to get familiar with the if generate block
    