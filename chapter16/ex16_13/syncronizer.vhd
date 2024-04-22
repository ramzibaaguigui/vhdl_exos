library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity syncronizer is 
    generic (
        DEFAULT_VALUE: std_logic
    );
    port (
        reset, clk: in std_logic;
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
            -- reset all to default value
            aa_reg <= DEFAULT_VALUE; 
            aaa_reg <= DEFAULT_VALUE;
        elsif (clk'event and clk = '1') then 
            aa_reg <= aa_next; 
            aaa_reg <= aaa_next;
        end if;
    end process;

    -- internal wirings between registers
    aa_next <= a_in;
    aaa_next <= aa_reg; 
    a_out <= aaa_reg;
end two_flop_arch;