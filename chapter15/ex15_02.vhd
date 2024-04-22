library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is the 2nd exercise of chapter 15
-- The parametrized binary decoder can also be constructed using using 2-to-4 decoders
-- (a) Derive the VHDL code for 2-to-4 decoder with an enable signal =
-- (b) Derive the VHDL code for parametrized binary decoder using only the 2-to-2 decoders of part (a)

entity decoder_2_4 is port (
    en: in std_logic,
    a: in std_logic_vector(1 downto 0);
    y: out std_logic_vector(3 downto 0)
); end decoder_2_4;

architecture arch of decoder2_4 is 
    signal intermediate: std_logic_vector(3 downto 0);
    signal augmented_enable: std_logic_vector(3 downto 0);
begin
    with a select
        intermediate <= "1000" when "11",
                        "0100" when "10",
                        "0010" when "01",
                        "0000" when others;
    augmented_enable <= en & en & en & en;
    y <= augmented_enable and intermediate;
end arch;

-- done with the architectre of the 2-to-4 decoder

-- (a) Derive the VHDL code for 2-to-4 decoder with an enable signal =
entity param_decoder is
    generic (
        WIDTH: natural
    );
    port (
        en: in std_logic;
        a: in std_logic_vector(WIDTH-1 downto 0);
        y: out std_logic_vector(2**WIDTH-1 downto 0)
    );
end param_decoder;

-- the challenge of this circuit is:
-- in order for everything to be regular 
-- the width of the input needs to be a power of 4: (4, 16, 64, ...)
-- one thing we can do
-- for this purpose, we will create the above package that contains some util functions, that we will be using

package utils is
    type std_logic_2d is array(natural range <>, natural range <>) of std_logic;
    function closer_even(N: natural) return natural;
    
end package utils;

package body utils is
    
    function closer_even(n: natural) return natural is 
        variable result: natural:= 0;
    begin
        if ((n mod 2) = 0) then
            result := n;
        else
            result := n + 1;
        end if;
        return result;
    end function;
    
end package body utils;

entity param_decoder is
    generic (
        WIDTH: natural        
    );
    port (
        en: in std_logic;
        a: in std_logic_vector (WIDTH-1 downto 0);
        y: out std_logic_vector (2**WIDTH-1 downto 0)
    );
end param_decoder;


-- here is the architecture of the param_decoder
architecture arch of param_decoder is 
    constant STAGE_COUNT: natural := (closer_even(WIDTH) / 2);
    -- in the case the width of the input a is not even, we add zero as the MSB,
    -- the additional circuitry will be removed during synthesis
    constant WIDTH_EVEN: natural := closer_event(WIDTH);
    signal augmented_index: std_logic_vector(WIDTH_EVEN-1 downto 0);
    
    signal stage_out_vector: std_logic_2d(STAGE_COUNT-1 downto 0, 4**STAGE_COUNT-1 downto 0);
    signal stage_in_vector: std_logic_2d(STAGE_COUNT-1 downto 0, 4**STAGE_COUNT-1 downto 0);

begin

    -- mapping the input to the augmented_index:
    -- if the input width is even
    if (a'width mod 2) = 0 generate
        augmented_index <= a;
    end generate;

    if (a'width mod 1) = 1 generate
        augmented_index <= '0' & a;
    end generate;

    -- generating the stages
    for stage in STAGE_COUNT-1 downto 0 generate
        -- only applies for the first stage
        if (stage = 0) generate
            decoder_unit: entity work.decoder_2_4(arch)
                port map (
                    en => en, -- to the en of the entire decoder
                    a => augmented_index(WIDTH_EVEN-1 downto WIDTH_EVEN-2), -- the higher two bits of the augmented index vector
                    y => stage_out_vector(i, 3 downto 0);
                );
        end generate;

        -- applies to the remaining stages except the first
        if (stage > 0) generate
                -- each stage (i) will comprise 4**stage 4-to-2 decoders
                for i in 4**stage-1 downto 0 generate
                    decoder2_4: entity work.decoder_2_4(arch)
                        port map(
                            en => stage_out_vector(stage-1, i), -- en will be connected to the previous stage output vector
                            a => augmented_index(WIDTH_EVEN-1-2*stage downto WIDTH_EVEN-1-2*stage-1),
                            y => stage_out_vector(stage, 4*i+3 downto 4*i);
                        );
                end generate;
        end generate;
    end generate;

    -- the thing we considered we considered when we worked with the augmented index should be considered
    -- with the output
    -- If the input index width is even, this means that the last stage output vector will be mapped as it is
    -- to the global output y

    -- otherwise, if the input index width is odd, we need to slide the output y out of the last stage output vector
    --
    
    -- this will apply if the y width is the same as the last layer output vector width
    if (a'width mod 2) = 0 generate
        -- map the output vector of the last stage as it is to the global y output
        y <= stage_out_vector(STAGE_COUNT-1)
    end generate;

    if (a'width mod 2) = 1 generate 
        y <= stage_out_vector(STAGE_COUNT-1, 2**WIDTH-1 downto 0);
    end generate;
end arch;

-- we shoud be done with the entire ex 15.2
-- still need to get verified in some way
