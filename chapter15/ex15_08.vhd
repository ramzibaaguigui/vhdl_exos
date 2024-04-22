library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exerise 15.8: 
-- The VHDL code in Listing 15.15, the number of input bits of the parallel-prefix
-- reduced-xor-vector circuit is limited a power of 2. Revise the code so that the number of
-- input bits can be any arbitrary number.


package util is
    
    type std_logic_2d is array(natural range <>, natural range <>) of std_logic;
    function log2c(n: natural) return natural;
    
end package util;

package body util is
    
    function log2c(n: natural) return natural is
        variable p, m: natural;
    begin
        m := 0; p := 1;
        while (n > p) loop 
            m := m + 1;
            p := p * 2;
        end loop;
        return m;
    end function;
    
end package body util;
entity reduced_xor_vector is 
    generic (
        N: natural
    );

    port (
        a: in std_logic_vector(N-1 downto 0);
        y: out std_logic_vector(N-1 downto 0)
    );
end reduced_xor_vector;

architecture para_prefix_arch of reduced_xor_vector is
    constant ST: natural := log2c(N);
    constant N_REGULAR: natural := 2**ST;
    -- signal p: std_logic_2d(ST downto 0, N-1 downto 0);
    -- we consider the N regular instead of N
    signal p: std_logic_2d(ST downto 0, N_REGULAR-1 downto 0);
    signal augmented_a: std_logic_vector(N_REGULAR-1 downto 0);
begin

    -- The goal of this exercise is to make the circuit compatible with all sizes of input
    -- we can just augment the input and map it to an internal signal whose width is necessarily a power of 2

    -- augmenting the input
    augmented_a(N-1 downto 0) <= a;

    padding: -- padding the input with zero (the neutral element of the xor operation)
    if augmented_a'width > a'width generate 
        augmented_a(N_REGULAR-1 downto N) <= (others => '0'); 
    end generate;

    process(a, p)
    begin
        -- rename input
        -- for i in 0 to (N-1) loop
        -- we should consider the N_REGULAR instead of N
        for i in 0 to (N_REGULAR-1) loop
            p(0, i) <= a(i);
        end loop;   

    
        -- main structure
        for s in 1 to ST loop
            for k in 0 to (2**(ST-s)-1) loop
                -- first half: pass through boxes
                for i in 0 to (2**(s-1)-1) loop
                    p(s, k*(2**s)+i) <= p(s-1, k*(2**s) + i);
                end loop;

                -- 2nd half: xor gats:
                for i in (2**(s-1)) to (2**s-1) loop
                    p(s, k*(2**s)+i) <=
                        P(s-1, k*(2**s + i)) xor
                        p(s-1, k*(2**s)+2**(s-1)-1)
                end loop;
            end loop;
        end loop;

        -- rename output:
        -- for the output, the width is supposed to be the same as the width of the initial input
        -- So, there is nothing to change here
        -- in case N is not regular, the remaining wires will be ignored 
        -- and automatically removed by the synthesis software
        for i in 0 to N-1 loop
            y(i) <= p(ST, i);
        end loop;
    end process;    
end architecture para_prefix_arch;

-- We shoud be done with this exercise
            