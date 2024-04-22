library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.5:
-- Extend the parameterized multiplexer code in Listing 15.3.3 to accommodate twodimensional
-- data. We need to define a three-dimensional data type for the internal signals.
-- (a) Follow the definition of std-logic-2d and define a genuine three-dimensional
-- data type. Derive the VHDL code using this data type.
-- (b) Follow the discussion of the emulated two-dimensional array and define an index
-- function to emulate a three-dimensional array. Derive the VHDL code using this
-- method.


package util is
    type std_logic_2d is array (natural range <>, natural range <>) of std_logic;
    type std_logic_3d is array(natural range <>, natural range <>, natural range <>) of std_logic;

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


-- in the first place, we will create a parametrized 4_to_1 mux

entity mux_4_1_B is
    generic (
        B: natural
    );
    
    port (
        a: array (3 downto 0, B-1 downto 0) of std_logic
        sel: in std_logic_vector(1 downto 0);
        y: array (B-1 downto 0) of std_logic;
    );
end mux_4_1_B;

-- here is the architecture body of the above circuit
architecture arch of mux_4_1_B is
begin
    -- according to the sel signal, we select which signal gets output by the circuit
    with sel select
        y <= a(3) when "11",
             a(2) when "10",
             a(1) when "01",
             a(0) when others;
end;



entity param_mux_B is 
    generic (
        WIDTH: natural, -- the number of elements to be multiplxed (choose one from each)
        B: natural -- the width of each element (the width of the output)
    );

    port (
        -- a: in std_logic_2d(WIDTH-1 downto 0, B-1 downto 0);
        a: in std_logic_vector(WIDTH*B-1 downto 0);
        sel: in std_logic_vector(log2c(WIDTH) - 1 downto 0);
        y: std_logic_vector(B-1 downto 0)
    );
end param_mux_B;

architecture arch of param_mux_B is 
    
    -- REGULAR: it means the number is a power of 4
    constant WIDTH_REGULAR: natural := 4**log4c(WIDTH);
    constant STAGE0_MUX_COUNT: natural := WIDTH_REGULAR / 4;
    -- the number of mux stages to be constructed
    constant STAGE_COUNT: natural := log4c(WIDTH);
    
    -- the width of the vector going out of each stage
    constant STAGE_OUT_VECTOR_WIDTH: natural := WIDTH_REGULAR / 4;

    -- the reformed input vector (0's are added as padding if the width of the input vector is not regular)
    -- signal augmented_a: std_logic_2d(WIDTH_REGULAR-1 downto 0, B-1 downto 0);
    signal augmented_a: std_logic_vector(WIDTH_REGULAR*B-1 downto 0);

    signal augmented_sel: std_logic_vector(log2c(WIDTH_REGULAR) - 1 downto 0);

    -- changed to the three-dim vector
    -- signal stage_out_vector: std_logic_3d(STAGE_COUNT-1 downto 0, STAGE_OUT_VECTOR_WIDTH-1 downto 0, B-1 downto 0);
    signal stage_out_vector: std_logic_vector(STAGE_COUNT*STAGE_OUT_VECTOR_WIDTH*B-1 downto 0);
    --

    -- whenever we find a usage of a mulitdim array, we replace it with the corresponding emulated array

begin
    -- getting all the staff ready for processing 
    -- get augmented_a wired with a and zeros if any
    -- augmented_a(WIDTH-1 downto 0, B-1 downto 0) <= a;
    augmented_a(WIDTH*B-1 downto 0) <= a;

    if augmented_a'width > a'width generate
        -- augmented_a(WIDTH_REGULAR-1 downto WIDTH, B-1 downto 0) <= (others => (others => '0'));
        augmented_a(WIDTH_REGULAR*B-1 downto WIDTH*B) <= (others => (others => '0'));
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
    
     for stage in STAGE_COUNT-1 downto 0 generate
        
        -- applies only to the first stage
        if stage = 0 generate
            -- the mux count in stage 0 is augmented'a width / 4
            for i in STAGE0_MUX_COUNT - 1 downto 0 generate
                -- generate the mux units of the first stage
                mux: entity work.mux_4_1_B(arch)
                    port map(
                        sel => sel(1 downto 0),

                        -- a => augmented_a(4*i+3 downto 4*i, B-1 downto 0),
                        a => augmented_a(4*i*B+3 downto 4*i*B),
                        -- y => stage_out_vector(0, i, B-1 downto 0),
                        y => stage_out_vector(i*STAGE_OUT_VECTOR_WIDTH*B-1 downto 0)
                    );
            end generate;
        end generate;

        -- applies to the remaining stages
        if stage > 0 generate

            -- stage i will contain (4**(STAGE_COUNT-1-stage)) mux units
            for i in 4**(STAGE_COUNT-1-stage)-1 downto 0 generate
                mux_unit: entity work.mux_4_1_B(arch)
                    port map(
                        -- a => stage_out_vector(stage-1, i, B-1 downto 0),
                        a => stage_out_vector((stage-1)*(STAGE_OUT_VECTOR_WIDTH*B)+(B*i)+B-1 downto (stage-1)*(STAGE_OUT_VECTOR_WIDTH*B)+(B*i)),
                        sel => augmented_sel(2*stage+1 downto 2*stage), -- wired to the global sel signal
                        -- y => stage_out_vector(stage, i, B-1 downto 0)-- wired with tht output vector of the current stage
                        y => stage_out_vector((stage-1)*(STAGE_OUT_VECTOR_WIDTH*B)+(B*i)+B-1 downto (stage-1)*(STAGE_OUT_VECTOR_WIDTH*B)+(B*i))
                    );
            end generate;
        end generate;
     end generate;
end arch;

-- Follow the discussion of the emulated two-dimensional array and define an index
-- function to emulate a three-dimensional array. Derive the VHDL code using this
--     method.

-- the above indices should work, it is all about emulating the multidim arrays like an sinel dim array

-- DONE with this ex