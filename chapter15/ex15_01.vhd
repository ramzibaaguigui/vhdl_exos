library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise (15.1):
-- Consider the parameterized binary decoder in Section 15.3.2. Derive the VHDL
-- code for a l-to-2 decoder with an enable signal and rewrite the code using a generate
-- statement and component instantiation.

-- First, without taking into considerating the VHDL code in Section 15.3.2, 
-- we write the VHDL code for the 1-to-2 decoder with an enable signal 

entity decoder1_2 is
    port (
        en: in std_logic;
        index_in: in std_logic;
        y_out: out std_logic_vector(1 downto 0)
    );
end decoder1_2;

architecture arch of decoder1_2 is
    signal intermediate: std_logic_vector(1 downto 0);
begin
    -- the enable mask
    -- determines whether to take into account the intermediate result
    en_mask = en & en;
    y_out <= intermediate when en = '1' else "00";
end arch;

package util is
    
    type std_logic_2d is array(natural range <>, natural range <>) of std_logic;
    
end package util;

-- this was the implementation of this simple circuit:

-- now we consider the design in Section 15.3.2
-- base on the given VHDL code, and generate another architecture that is 
-- mainly based on the instantiation of the above circuit

entity param_decoder is
    generic(
        WIDTH: natural
    );

    port (
        a: in std_logic_vector(WIDTH-1 downto 0);
        en: in std_logic;
        code: out std_logic_vector(2**WIDTH-1 downto 0);
    );
end param_decoder;

-- this is the architecture of the above code
architecture tree_arch of param_decoder is 
    constant STAGE_COUNT: natural := WIDTH;
    signal stage_out_vector: std_logic_2d(STAGE_COUNT-1 downto 0, 2**WIDTH-1 downto 0);
    signal stage_in_vector: std_logic_2d(STAGE_COUNT-1 downto 0, 2**WIDTH-1 downto 0);
begin

    -- wiring the output of the last stage to the out code vector
    code <= stage_out_vector(STAGE_COUNT-1);

    -- iterating through the stages except the first stage
    for i in STAGE_COUNT-1 downto 0 generate
        -- each stage i will comprise 2**i decoders
        -- generating for the higher stages
        if i > 0 generate
            for j in 2**i-1 to 0 generate
                decoder_unit: entity work.decoder1_2(arch)
                    port map(
                        index_in => a(WIDTH-1-i), -- a(WIDTH-1-i) of the input index
                        en => stage_out_vector(i-1, j),
                        y_out => stage_out_vector(i, 2*j+1 downto 2*j)
                    );
            end generate;
        end generate;

        if i = 0 generate
            -- for the first stage only
            decoder_unit0: entity work.decoder1_2(arch)
                port map(
                    index_in => a(WIDTH-1),
                    en => en, -- wire to the enable of the entire tree arch decoder
                    y_out => stage_out_vector(0, 1 downto 0);
                );
        end generate;
    end generate;
end tree_arch;

-- we should be done 