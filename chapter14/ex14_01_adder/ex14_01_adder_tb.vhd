library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_tb is end adder_tb;

architecture sim of adder_tb is
    -- the simulation signals
    signal a, s, cin, cout: std_logic;
    begin
        -- init the device under test
        -- link the inputs and outputs
        dut:
        entity work.adder_unit(arch)
            port map(
                s => s, a => a, cin => cin, cout => cout
            );

        -- no clock is needed
        stimulus:
        process
            begin
                -- test the different values for a and cin
                -- and check the output of the unit
                cin <= '0'; a <= '0';
                wait for 50 ns;

                a <= '1';
                wait for 50 ns;

                cin <= '1';
                wait for 50 ns;

                a <= '0'; 
                wait for 50 ns; 

                wait;

            end process;
        

    end sim;