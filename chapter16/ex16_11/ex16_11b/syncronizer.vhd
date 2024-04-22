library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity syncronizer is 
    generic (
        DEFAULT_VALUE: std_logic := '0'
    );

    port (
        clk, reset: in std_logic;
        a_in: in std_logic;
        a_out: out std_logic;
    );
end syncronizer;


architecture two_flop_arch of syncronizer is
    signal a_reg, b_reg, a_next, b_next: std_logic;
begin
    a_next <= a_in;
    b_next <= a_reg;
    a_out <= b_reg;

    process(clk, reset) 
    begin
        if reset = '1' then 
            -- reset all registers to the default value
            a_reg <= DEFAULT_VALUE;
            b_reg <= DEFAULT_VALUE;
        elsif (clk'event and clk = '1') then 
            a_reg <= a_next;
            b_reg <= b_next;
        end if;
    end process;
end two_flop_arch;