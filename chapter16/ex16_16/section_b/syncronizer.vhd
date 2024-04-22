
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity syncronizer is 
    generic (
        DEFAULT_VALUE: std_logic
    );
    port (
        clk, reset: in std_logic; 
        a_in: in std_logic; 
        a_out: out std_logic
    );
end syncronizer; 

architecture two_flop_arch of syncronizer is 
    signal aa_reg, aa_next, aaa_reg, aaa_next: std_logic; 
begin
    -- infer registers 
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default state 
            aa_reg <= DEFAULT_VALUE; 
            aaa_reg <= DEFAULT_VALUE;
        elsif (clk'event and clk = '1') then 
            aa_reg <= aa_next; 
            aaa_reg <= aaa_next;
        end if;
    end process;

    -- wiring the input and output of registers 
    aa_next <= a_in; 
    aaa_next <= aa_reg;
    a_out <= aaa_reg;

end two_flop_arch;