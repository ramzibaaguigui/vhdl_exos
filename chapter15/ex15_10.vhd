library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.09:
-- The code of the adder-based multiplier of Listing 15.17 has a feature parameter to
-- insert pipeline registers to the circuit. The number of stages of the pipeline is the same as
-- the width of the input operand. Modify the code to incorporate an additional parameter that
-- specifies the number of desired pipeline stages.

package util is
    
    function div_ceil(a, b: natural) return natural;
    
end package util;

package body util is
    
    function div_ceil(a, b: natural) return natural is 
        variable m: natural;
    begin
        m := a / b;
        if (m * b < a) then 
            m := m+1;
        end if;
        return m;
    end function;
    
end package body util;

entity multn is
    generic (
        N: natural;
        WITH_PIPE: natural;
        PIPE_STAGES: natural
    );
    port (
        clk, reset: std_logic;
        a, b: in std_logic_vector(N-1 downto 0);
        y: out std_logic_vector(2*N-1 downto 0)
    );
end multn;

architecture n_stage_pipe_arch of multn is 
    type std_aoa_n_type is
        array(N-2 downto 1) of std_logic_vector(N-1 downto 0);
    
    type std_aoa_2n_type is
        array(N-1 downto 0) of unsigned(2*N-1 downto 0);
    
    signal a_reg, a_next, b_reg, b_next: std_aoa_n_type;
    signal bp, pp_reg, pp_next: std_aoa_2n_type;

    -- the function tells whether to generate a register for the stage $stage
    -- consider using the generic values PIPE_STAGES and N
    function canGenerateRegister(stage : natural) return boolean is
        -- it is noted that in normal cases, the number of pipeline stages is N, so:
        -- the number of registers to be inferred N-1 in case the PIPE_STAGES = N
        constant VIRTUAL_REGISTER_COUNT: natural := N-1;
        constant STAGE_COUNT: natural := N;
        constant VIRTUAL_STAGE_COUNT: natural := N;
        constant REGISTER_COUNT: natural := PIPE_STAGES - 1;
        variable distance: natural;
        variable result: boolean;
    begin
        -- this function tells whether to generate registers for $stage stage given the stage
        -- come back later to make it better optimized
        -- for this time i will just consider the first stages as pipelined
        distance := div_ceil(VIRTUAL_REGISTER_COUNT, PIPE_STAGES);
        if ((stage+1) mod distance) = 0 then
            result := true;
        else
            result := false;
        end if;
        return result;
    end function;
    -- we should be done;
begin
    -- part 1
    -- without pipeline buffers
    g_wire:
    if (WITH_PIPE /= 1) generate 
        a_reg <= a_next;
        b_reg <= b_next;
        pp_reg(N-1 downto 1) <= pp_next(N-1 downto 1);
    end generate;

    -- most of the work will be done on this block
    -- in order to control the number of pipeline blocks that will be inferred in the design
    -- we need to explicit the below part

    -- with pipeline buffer
    if (WITH_PIPE = 1) generate 
        for i in (N-2) downto 1 generate
            -- we will generate each of the below parts explicitly
            
            -- for the stages for which we will generate registers
            supports_regsters:
            if (canGenerateRegister(i)) generate
                process(clk, reset)
                begin
                    if (reset = '1') then
                        a_reg(i) <= (others => '0');
                        b_reg(i) <= (others => '0');
                        pp_reg(i) <= (others => '0');
                    elsif (clk'event and clk = '1') then
                        a_reg(i) <= a_next(i);
                        b_reg(i) <= b_next(i);
                        pp_reg(i) <= pp_next(i);
                    end if;
                end process;
            end generate;

            -- for the stages that do not comprise registers
            -- no clk or reset signals will be called
            -- just a wiring between the input and the output of this stage
            -- Note that the name register does no longer make sense here

            if(!canGenerateRegister(i)) generate -- The conditiont to not generate registers for this stage, 
                                   -- the condition should be complementary to the previous one
                -- no reset or clk signals will be considered
                a_reg(i) <= a_next(i); -- takes the value of next without clock constraints
                b_reg(i) <= b_next(i); -- so no flip-flop components will be inferred by the
                pp_reg(i) <= pp_next(i); -- synthesizer
            end generate;

        end generate;

        -- this is for the last stage of pp_reg
        process(clk, reset) 
        begin
            if (reset = '1') then
                pp_reg(N-1) <= (others => '0');
            elsif (clk'event and clk = '1') then
                pp_reg(N-1) <= pp_next(n-1);
            end if;
        end process;

        -- NOTE: In some way, we transformed the below code into a more loopy explicit code (show above)
        -- there is one special case for pp_reg(N-1): its code is written explcitly
        -- process(clk, reset)
        -- begin
        --     if (reset = '1') then 
        --         a_reg <= (others => (others => '0'));
        --         b_reg <= (others => (others => '0'));
        --         pp_reg(N-1 downto 1) <= (others => (others => '0'));
        --     elsif(clk'event and clk = '1') then
        --         a_reg <= a_next;
        --         b_reg <= b_next;
        --         pp_reg(N-1 downto 1)  <= pp_next(N-1 downto 1);
        --     end if;
        -- end process;
    end generate;


    -- part 2:
    -- bit product generation
    process(a, b, a_reg, b_reg)
    begin
        -- bp(0) and bp(1)
        for i in 0 to 1 loop
            bp(i) <= (others => '0');
            for j in 0 to N-1 loop
                bp(i)(i+j) a(j) and b(i);
            end loop;
        end loop;   

        
        -- regular bp
        for i in 2 to (N-1) loop
            bp(i) <= (others => '0');
            
            for j in 0 to (N-1) loop
                bp(i)(i+j) <= a_reg(i-1)(j) and b_reg(i-1)(i);
            end loop;   
        end loop;
    end process;

    -- part 3:
    -- addition of the first stage:
    g1:
    for i in 2 to (N-2) generate
        pp_next(i) <= pp_reg(i-1) + bp(i);
        a_next(i) <= a_reg(i-1);
        b_next(i) <= b_reg(i-1);
    end generate;

    -- addition of the last stage
    pp_next(N-1) <= pp_reg(N-2) + bp(N-1);

    -- rename output
    y <= std_logic_vector(pp_reg(N-1));
                
end n_stage_pipe_arch;
