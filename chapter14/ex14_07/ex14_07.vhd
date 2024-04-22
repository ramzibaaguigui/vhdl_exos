-- Exercise 14.7:
-- Repeat Problem 14.2, but use no generic. Declare the data type of the input port as
-- std-logic-vector with no explicit range specification. Make sure that the code can work
-- with different formats of specification when the component is instantiated
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity incrementor is 
    port (
        cin: in std_logic;
        a: in std_logic_vector;
        cout: out std_logic;
        s: out std_logic_vector
    );
end incrementor;

architecture arch of incrementor is
    constant WIDTH: integer := a'width;
    signal a_in, s_out: std_logic_vector(WIDTH-1 downto 0);
    signal cin_vector, cout_vector: std_logic_vector(WIDTH-1 downto 0);

    begin
        a_in <= a;
        s <= s_out;

        -- the remaining processing will be done on a_in and s_out
        
        generator:
        for i in 0 to WIDTH-1 generate
            s_out(i) <= cin_vector(i) xor a_in(i);
            cout_vector(i) <= a_in(i) and cin_vector(i);
        end generate;

        -- the right most carry in and
        -- the left most carry out
        cin_vector(0) <= cin;
        cout <= cout_vector(WIDTH-1);

        -- the remaining wiring between the carry in and carry out
        wire_generator:
        for i in 1 to WIDTH-1 generate
            cin_vector(i) <= cout_vector(i-1);
        end generate;
    end arch;
    -- in this exercise, the difference when compared to ex 14.2 is that we 
    -- have added intermediate signals that are wired with the inputs signals
    -- the intermediate signals serve us in removing the confusion concerning 
    -- the index range non-determinism that can happen when signals with different
    -- index ranges are introduced to the architecture

    -- the second thing is to replace all the occurences of the old signals
    -- with the new intermediate signals
    