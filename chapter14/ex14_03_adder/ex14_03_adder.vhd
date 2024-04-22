library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise(14.3): 
-- Repeat Problem 14.2. but create the l-bit incrementor cell as a component and use
-- component instantiation in the loop body.

-- the inc unit: 
entity adder_unit is port(
    a, cin: in std_logic;
    s, cout: out std_logic
); end adder_unit;

architecture arch of adder_unit is
    begin
        s <= a xor cin;
        cout < a and cin;
    end arch;

-- end of the incrementor uni

-- the actual solution to the exercise:
entity param_adder is 
    generic(
        WIDTH: natural
    );
    port(
        cin: in std_logic;
        a: in std_logic_vector(WIDTH-1 downto 0);
        s: out std_logic_vector(WIDTH-1 downto 0);
        cout: out std_logic
    );
end param_adder;

architecture arch of param_adder is
    signal carry_in_vector, carry_out_vector: std_logic_vector(WIDTH-1 downto 0);
    begin
    
        -- generating the adder units and wiring with inputs and outputs
        adder_unit_generator: 
        for i in 0 to WIDTH-1 generate
            adder_unit: entity work.adder_unit(arch)
                port map(
                    cin => carry_in_vector(i), 
                    a => a(i),
                    s => s(i), 
                    cout => carry_out_vector(i)
                );
        end generate;

        -- after generating the adder units comes the time of
        -- wiring the carry out of earch units to the carry in of the next unit
        carry_wire_generator:
        for i in 1 to WIDTH-1 generate
            carry_in_vector(i) <= carry_out_vector(i-1);
        end generate;

        -- for the first carry in signal and the last carry out signal:
        -- we treat the case independently        
        carry_in_vector(0) <= cin;
        cout <= carry_out_vector(WIDTH-1)

    end arch;
    
    -- WE SHOULD BE DONE WITH THE DESIGN
    