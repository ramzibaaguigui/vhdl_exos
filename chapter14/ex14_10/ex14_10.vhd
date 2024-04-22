-- Exercise 14.10:
-- Consider the priority encoder of Listing 14.24.
-- Rewrite the code using for generate statement

-- here is the code from listing 14.24;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package util_package is
    function log2c(n: natural);
end util_package;

package body util_package is
begin
    function log2c(n: natural) return natural is
    begin
        m := 0;
        p := 1;
        while p < n loop
            m := m + 1;
            p := p * 2;
        end loop;
        return m;
    end function;
end util_package;

entity prio_encoder is
    generic (WIDTH: natural);
    port (
        r: in std_logic_vector(WIDTH-1 downto 0);
        bcode: out std_logic(log2c(WIDTH)-1 downto 0);
        valid: out std_logic
    );
end prio_encoder;

architecture arch of prio_encoder is 
    constant B: natural := log2c(WIDTH);
    signal tmp: std_logic_vector(WIDTH-1 downto 0);
begin

    -- binary code
    process(r)
    begin
        bcode <= (others => '0');
        for i in 0 to WIDTH-1 loop
            if (r(i) = '1') then
                bcode <= std_logic_vector(to_unsigned(i, B));
            end if;
        end loop;
    end process;

    -- reduced-or circuit
    process(r)
    begin
        tmp(0) <= r(0);

        for i in 1 to WIDTH-1 loo
            tmp(i) <= r(i) or tmp(i-1);
        end loop;
    end process;

    -- this will tell whether the output is valid
    valid <= tmp(WIDTH-1);

end arch;

-- Let's rewrite the above architecture with a for generate architecture
architecture for_gen_arch of prio_encoder is
    constant B: natural := log2c(WIDTH);
    signal tmp: std_logic_vector(WIDTH-1 downto 0);

    type WIDTHxB_vector is array (WIDTH-1 downto 0) of std_logic_vector(B-1 downto 0);
    signal sel_vector: std_logic_vector(WIDTH-1 downto 0);
    signal mux_out_vector: WIDTHxB_vector;
    
begin

    tmp(0) <= r(0);
    valid <= tmp(WIDTH-1);
    reduced_or_generator:
    for i in 1 to WIDTH-1 generate
        tmp(i) <= tmp(i-1) or r(i);
    end generate;

    -- for the decoder
    gen2:
    for i in WIDTH-1 downto 1 generate
        higher_gen:
        if (i > 1) generate
            mux_out_vector(i) <= std_logic_vector(to_unsigned(i, B)) 
                when sel_vector(i) = '1' else mux_out_vector(i-1);
        end generate;

        lowest_order:
        if (i = '1') generate
            mux_out_vector(i) <= std_logic_vector(to_unsigned(i, B))
                when sel_vector(i) = '1' else std_logic_vector(to_unsigned(0, B));
        end generate;
    end generate;

    -- the bcode is the output of the higher order mux
    bcode <= mux_out_vector(WIDTH-1);
end for_gen_arch;

    -- the exercise should be done
    -- consider checking more later
    