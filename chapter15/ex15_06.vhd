-- Ex 15.6:

-- Consider the parameterized binary encoder in Section 15.3.4. Instead of using for
-- loop statements, rewrite the VHDL code with for generate statements.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




package util is
    type std_logic_2d is array(natural range <>, natural range <>) of std_logic;
    function log2c(n: natural) return natural;
    
end package util;

package body util is
    
    function log2c(n: natural) return natural is
        variable m, p: natural;
    begin
        p:= 1; m:= 0;
        while p < n loop
            m := m + 1;
            p := p*2;
        end loop;
        return m;
    end function;
    
end package body util;


entity or_gate is port (
    a: in std_logic_vector(1 downto 0);
    y: out std_logic
); end or_gate;

architecture arch of or_gate is
begin
    y <= a(0) or a(1);
end arch;

entity param_or is 
    generic (
        WIDTH: natural
    )
    port (
        a: in std_logic_vector(WIDTH-1 donwto 0);
        y: out std_logic
    );

end param_or;

architecture arch of param_or is
    constant WIDTH_REGULAR: natural := 2**log2c(WIDTH);
    constant STAGE_COUNT: natural := log2c(WIDTH_REGULAR);
    constant MAX_STAGE_OUT_VECTOR_WIDTH: natural := WIDTH_REGULAR / 2;
    signal augmented_a: std_logic_vector(WIDTH_REGULAR-1 downto 0);
    
    signal stage_out_vector: std_logic_2d(STAGE_COUNT-1 downto 0,  MAX_STAGE_OUT_VECTOR_WIDTH-1 downto 0);

begin
    
    -- wire a to the augmented signal
    augmented_a(WIDTH-1 downto 0) <= a;

    if (augmented_a'width > a'width) generate
        augmented_a(WIDTH_REGULAR-1 downto WIDTH) <= (others => '0');
    end generate;

    -- generating the stages
    -- note that the numbering of the stages is reversed: 
    -- (the one closer to the input takes the values of STAGE_COUNT-1)
    for stage in STAGE_COUNT-1 downto 0 generate
        
        -- applies to the stage closer to the input
        if stage = STAGE_COUNT-1 generate
            -- the number of gates that will be generated in this stage is 2**stage

            for i in 2**stage-1 downto 0 generate
                orgate: entity work.or_gate(arch)
                    port map(
                        a => augmented_a(2*i+1 downto 2*i),
                        y => stage_out_vector(stage, i)
                    );
            end generate;
        end generate;

        -- applies to the remaining stages
        -- the ones except the first stage
        if stage < STAGE_COUNT-1 generate
            for i in 2**stage-1 downto 0 generate
                or_gate: entity work.or_gate(arch)
                    port map(
                        a => stage_out_vector(stage-1, 2*i+1 downto 2*i);
                        y => stage_out_vector(stage, i)
                    );
            end generate;
        end generate;
    end generate;

    -- the stages are all wired with each other
    -- we just need to wire the output of the last stage to the gloabl output
    y <= stage_out_vector(0, 0);
    
end architecture arch;

entity binary_decoder is 
    generic (
        WIDTH: natural
    );
    port (
        a: in std_logic_vector(WIDTH-1 downto 0);
        y: out std_logic_vector (log2c(WIDTH) -1 downto 0)
    );
end binary_decoder;

architecture arch of binary_decoder is

    fun gen_2d_mask(WIDTH) return std_logic_2d is 
        var mask: std_logic_2d(log2c(WIDTH)-1 downto 0, WIDTH-1 downto 0);
    begin
        for stage in log2c(WIDTH)-1 donwto 0 loop
            for k in WIDTH-1 downto 0 loop
                if ((k/(2**stage) mod 2) = 1) then -- if the bit i has contribution in stage 
                    mask(stage, k) := '1';
                else 
                    mask(stage, k) := '0';
                end if;
            end loop;
        end loop;
    end;
    -- REGULAR means width is a power of 2
    constant WIDTH_REGULAR: natural := 2**log2c(WIDTH);
    constant STAGE_COUNT: natural := log2c(WIDTH_REGULAR);
    signal mask: std_logic_2d;
    signal augmented_a: std_logic_vector(WIDTH_REGULAR-1 downto 0);
    signal stage_in_vector: std_logic_2d (STAGE_COUNT-1 downto 0, WIDTH_REGULAR-1 downto 0);
begin
    -- wiring the augmented signal to the input a signal or zeros if remaining
    augmented_a(WIDTH-1 downto 0) <= a;
    if (augmented_a'width > a'width) generate
        augmented_a(WIDTH_REGULAR-1 downto WIDTH) <= (others => '0');
    end generate;

    -- getting the mask ready
    mask <= gen_2d_mask(WIDTH_REGULAR);
    -- any further processing should be performed on the augmented_a signal
    -- for the processing, we need to have a parametrized or 
 

    -- generate the filtered input vector for each stage
    for stage in STAGE_COUNT-1 downto 0 generate
        stage_in_vector(stage) <= mask(state) and augmented_a;
    end generate;

    -- wiring the stage input vector with the or units
    for stage in STAGE_COUNT -1 downto 0 generate
        or_gate: entity work.param_or(arch)
            generic map(
                WIDTH => WIDTH_REGULAR
            )
            port map(
                a => stage_in_vector(stage),
                y => y(stage)
            );
    end generate

end arch;

-- GENERATE DESCRIPTION FOR THE DESIGN
-- we generate a mask in the first place which determines which item contributes in which stage
-- the stages are all going to be identical, BUT
-- the only things that makes difference is the mask element that will be used with that stage
-- so, we generate the stage_in_vector by performing an AND with the mask

-- finally we create the logic elements using parametrized or units,
-- and we should be done