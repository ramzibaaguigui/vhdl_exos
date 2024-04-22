library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Follow the block diagram of Problem 14.1(c) to design a parameterized incrementor
-- in which the width of the input operand is specified by a generic. Derive the VHDL code
-- using the for generate statement. Use a simple signal assignment statement in the loop
-- body, and no VHDL arithmetic operator is allowed.

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
        cin_vector(0) <= cin;
        cout <= cout_vector(WIDTH-1);

        -- the remaining wiring between the carry in and carry out
        wire_generator:
        for i in 1 to WIDTH-1 generate
            cin_vector(i) <= cout_vector(i-1);
        end generate;
        
    end arch;
    
    -- we shoudl be done with the design
    