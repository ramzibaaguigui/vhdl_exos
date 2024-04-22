library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_unit is port(
    a, cin: in std_logic;
    s, cout: out std_logic
); end adder_unit;

architecture arch of adder_unit is
    begin
        s <= a xor cin;
        cout <= a and cin;
    end arch;
-- DONE WITH THIS EXERCISE