library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity and_para is 
    generic(
        WIDTH: Integer
    );
    port(
        a, b: in std_logic_vector(WIDTH-1 downto 0);
        y: out std_logic_vector(WIDTH-1 downto 0)
    );
end and_para;

architecture arch of and_para is 
begin
    y <= a and b;
end arch;