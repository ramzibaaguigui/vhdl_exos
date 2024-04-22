library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise(14.6): 
-- Repeat Problem 14.2, but apply the clever-use-of-array techniques discussed in
-- Section 14.4. No for generate or for loop statement is allowed.


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

--  

-- the above architecture is based on the clever-array-usage
-- we accomplish the same goal as with using a generator for loop
    
architecture arch of incrementor is
    signal cout_vector, cin_vector: std_logic_vector(WIDTH-1 downto 0);
    begin
        s <= a xor cin_vector;
        cout_vector <= a and cin_vector;
        cin_vector <= cout_vector(WIDTH-2 downto 0) & cin;
        cout <= cout_vector(WIDTH-1);
    end arch;

    -- we should be done with ex 14.6.