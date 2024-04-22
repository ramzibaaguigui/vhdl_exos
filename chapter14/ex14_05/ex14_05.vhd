library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 14.5 Repeat Problem 14.2, but use the for loop statement.
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
    signal cin_vector, cout_vector: std_logic_vector(WIDTH-1 downto 0);

    begin
        process(cin, a)
            begin
                -- generate the remaining parts
                cin(0) <= cin;
                cout <= cout_vector(WIDTH-1);

                for i in 1 to WIDTH-1 loop
                    cin_vector(i) <= cout_vector(i-1);
                end loop;

                for i in 0 to WIDTH-1 loop
                    s(i) <= cin_vector(i) xor a(i);
                    cout_vector(i) <= cin_vector(i) and a(i);
                end loop;
            end process;
    end arch;
    
    -- they all seem to do the same thing
    