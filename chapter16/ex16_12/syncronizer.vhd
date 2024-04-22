library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity syncronizer is 
    generic(
        DEFAULT_VALUE: std_logic
    );
    port (
        clk, reset: in std_logic;
        a_in: in std_logic;
        a_out: out std_logic
    );
end syncronizer;

architecture two_flop_arch of syncronizer is 
    signal a_reg, a_next, aa_reg, aa_reg: std_logic;
begin
    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default
            a_reg <= DEFAULT_VALUE;
            aa_reg <= DEFAULT_VALUE;
        elsif (clk'event and clk = '1') then 
            -- get the next value
            a_reg <= a_next;
            aa_reg <= aa_next;
        end if;
    end process;

    -- wiring the input to the output with register
    a_next <= a_in;
    aa_next <= a_reg; 
    a_out <= aa_reg;
end;


