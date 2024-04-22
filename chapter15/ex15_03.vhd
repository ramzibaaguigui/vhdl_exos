-- Exercise 15.3: 
-- Repeat part (b) of Problem 15.2. Instead of being limited to 240-2~d ecoders, use
-- a 1-to-2l decoder in the leftmost stage if the input of the parameterized decode has an odd
-- number of bits.

-- Even though we have handled this particular case in the previous exercise.
-- We should handle it also from the point of view of this exercise

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package utils is
    
    type std_logic_2d is array (natural range <>, natural range <>) of std_logic;
    
end package utils;


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

-- here starts the code of the parametrized decoder

entity param_decoder is
    generic (
        WIDTH: natural
    );
    port (
        a: in std_logic_vector (WIDTH-1 downto 0);
        en: in std_logic;
        y: out std_logic_vector(WIDTH**2-1 downto 0)
    );
end param_decoder;

architecture arch of param_decoder is
    constant STAGE_COUNT: natural := (WIDTH+1) / 2;
    signal stage_out_vector is std_logic_2d(STAGE_COUNT-1 downto 0, WIDTH**2-1 downto 0); 
begin

    -- we this particular scenario
    for stage in STAGE_COUNT-1 downto 0 generate
        
        -- applies to the left most stage (the one nearest to the input)
        if (stage = 0) generate
            -- can infer a 2_4_decoder or 1_2_decoder depending on the parity of the input a
            if (WIDTH mod 2) = 0 generate
                -- use the 2-to-4 decoder
                decoder2_4: entity work.decoder2_4(arch)
                    port map(
                        en => en, -- wire with the global enable input signal
                        a => a(WIDTH-1 downto WIDTH-2),
                        y => stage_out_vector(3 downto 0)
                    ); 
            end generate;

            if (WIDTH mod 2) = 1 generate
                -- use the 1-to-2 decoder
                decoder1_2: entity work.decoder_1_2(arch)
                    port map(
                        en => en,
                        a => a(WIDTH-1),
                        y => stage_out_vector(1 downto 0)
                    );
            end generate;
        end generate;

        -- applies to the remaining stages
        if (stage > 1) generate
            -- the number of decoder units that will be generated in this stage is calc like this:
            -- unit_count(stage i) <= (2**WIDTH) / (4**(STAGE_COUNT - stage))
            for j in (((2**WIDTH) / (4**(STAGE_COUNT - stage)))-1) downto 0 generate
                decoder2_4_unit: entity work.decoder_2_4(arch)
                    port map (
                        en => stage_out_vector(stage - 1, j), -- wired with the previous stage output vector
                        -- the index range to use in the above is reverse proportional to the stage we are in
                        -- example: last stage takes 1 downto 0
                        --   before last stage takes 3 downto 2
                        -- ... 

                        -- wire with a part from the global input vector a
                        a = > a(2*(STAGE_COUNT-1-stage)+ 1, 2*(STAGE_COUNT-1-stage)), 
                        y => stage_out_vector(stage, 4 * j + 3 downto 4 * j)
                    );
            end generate;
        end generate;
    end generate;

    y <= stage_out_vector(STAGE_COUNT-1);
end arch;

-- this should work