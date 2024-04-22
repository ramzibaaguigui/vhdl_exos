-- 15.4 Consider the parameterized multiplexer in Section 15.3.3. Redesign the multiplexer
-- using 4-to-1 multiplexers and derive the VHDL code accordingly.4

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package util is
    type std_logic_2d is array (natural range <>, natural range <>) of std_logic;
    function log2c(n: natural) return natural;
    function log4c(n: natural) return natural;
end package util;

package body util is
    
    function log2c(n: natural) return natural is
        variable m, p: natural;        
    begin
        m := 0; p := 1;
        while p < n loop
            p := 2 * p;
        end loop;
        return m;
    end function;
    
    function log4c(n: natural) return natural is 
        variable m, p: natural;
    begin
        m := 0; p := 1;
        while p < n loop
            p := 4 * p;
        end loop;
        return m;
    end function;
end package body util;

-- in the first place, we consider designing the 4 to one mux
entity mux4_1 is port (
    a: in std_logic_vector(3 downto 0);
    sel: in std_logic_vector(1 downto 0);
    y: out std_logic
); end mux4_1;


architecture arch of mux4_1 is
begin
    with sel select 
        y <= a(3) when "11",
             a(2) when "10",
             a(1) when "01",
             a(0) when others;
end arch;

-- THE END OF THE MUX4_1

entityt param_mux is
    generic (
        WIDTH: natural
    );
    port (
        a: in std_logic_vector(WIDTH-1 downto 0);
        sel: in std_logic_vector(log2c(WIDTH) - 1 downto 0);
        y: out std_logic
    );
end param_mux;

architecture arch of param_mux is

    -- REGULAR: it means the number is a power of 4
    constant WIDTH_REGULAR: natural := 4**log4c(WIDTH);
    constant STAGE0_MUX_COUNT: natural := WIDTH_REGULAR / 4;
    -- the number of mux stages to be constructed
    constant STAGE_COUNT: natural := log4c(WIDTH);
    
    -- the width of the vector going out of each stage
    constant STAGE_OUT_VECTOR_WIDTH: natural := WIDTH_REGULAR / 4;

    -- the reformed input vector (0's are added as padding if the width of the input vector is not regular)
    signal augmented_a: std_logic_vector(WIDTH_REGULAR-1 downto 0);
    signal augmented_sel: std_logic_vector(log2c(WIDTH_REGULAR) - 1 downto 0);

    signal stage_out_vector: std_logic_2d(STAGE_COUNT-1 downto 0, STAGE_OUT_VECTOR_WIDTH-1 downto 0): 
begin
    
    -- get augmented_a wired with a and zeros if any
    augmented_a(WIDTH-1 downto 0) <= a;
    
    if augmented_a'width > a'width generate
        augmented_a(WIDTH_REGULAR downto WIDTH) <= (others => '0');
    end generate;

    
    -- even if the augmented sel with is greated than the sel width, it would be greater with one only
    -- so add a single padding zero
    if augmented_sel'width > sel'width generate
        augmented_sel <= '0' & sel;
    end generate;

    -- if the augmented signal width == sel width, just wire them with each other
    if augmented_sel'width = sel'width generate
        augmented_sel <= sel;
    end generate;

    -- any further processing with be performed on the augmented_a signal
    for stage in STAGE_COUNT-1 downto 0 generate
        -- only applies to the first stage
        if stage = 0 generate
            -- the mux count in stage 0 is augmented'a width / 4
            for i in STAGE0_MUX_COUNT - 1 downto 0 generate
                -- generate the mux units of the first stage
                mux: entity work.mux_4_1(arch)
                    port map(
                        sel => sel(1 downto 0),
                        a => augmented_a(4*i+3 downto 4*i),
                        y => stage_out_vector(0, i),
                    );
            end generate;
        end generate;

        if stage > 0 generate
            -- stage i will contain (4**(STAGE_COUNT-1-stage)) mux units
            for i in 4**(STAGE_COUNT-1-stage)-1 downto 0 generate
                mux_unit: entity work.mux_4_1(arch)
                    port map(
                        a => stage_out_vector(stage-1, i),
                        sel => augmented_sel(2*stage+1 downto 2*stage), -- wired to the global sel signal
                        y => stage_out_vector(stage, i)-- wired with tht output vector of the current stage
                    );
            end generate;
        end generate;
    end generate;
    -- generating the stages
    
    -- mapping the output of the last stage to the global output
    y <= stage_out_vector(STAGE_COUNT - 1, 0);


end arch;