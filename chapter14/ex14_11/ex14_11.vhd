-- 14.11 Consider the population counter code of Listing 14.27. Rewrite the code using a
-- for generate statement.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity popu_counter is
    generic(
        WIDTH: natural
    );

    port(
        a: in std_logic_vector(WIDTH-1 downto 0);
        count: out std_logic_vector (log2c(WIDTH)-1 downto 0)
    );
end popu_counter;

architecture loop_linear_arch of popu_counter is 
begin
    process(a)
        variable sum: unsigned(log2c(WIDTH)-1 downto 0);
    begin
        sum := 0;
        for i in 0 to WIDTH-1 loop
            if (a(i) = '1') then
                sum := sum + 1;
            end if;
        end loop;
        count <= std_logic_vector(sum);
    end process;
end;

-- The required in this exercises is to convert the previous architecture to
-- a more suitable one using the for generate

arch loop_gen_arch of popu_counter is
    constant B: natural := log2c(WIDTH);
    signal stage_in_vector, state_out_vector is 
        array (0 to WIDTH-1) of std_logic_vector(B-1 downto 0);
    
    -- stage zero generator
    stage_in_vector(0) <= (std_logic_vector(to_unsigned(0, B)));

    -- wiring all the stages:
    stage_gen:
    for i in 0 to WIDTH-1 generate
        stage_out_vector(i) <= std_logic_vector(unsigned(stage_in_vector(i)) + 1) 
            when a(i) = '1' else stage_in_vector(i);
    end generate;

    count <= stage_out_vector(WIDTH-1);
begin

end loop_gen_arch;
-- we shoudl be done with ex