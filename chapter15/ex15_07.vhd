-- Exercise 15.7: 
-- We want to extend the parameterized barrel shifter in Section 15.3.5 by adding one
-- additional mode of shift operation, arithmetic shift right. In this mode, the MSB, instead
-- of '0', will be shifted into the left portion of the output. Modify the VHDL code to include
-- this mode

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is the shifter building block that was used in the example 15.3.5
entity fixed_shifter is 
    generic(
        WIDTH: natural;
        S_AMT: natural;
        S_MODE: natural
    );
    port (
        s_in: in std_logic_vector(WIDTH-1 downto 0);
        shift: in std_logic;
        s_out: out std_logic_vector(WIDTH-1 downto 0)
    );
end fixed_shifter;

architecture para_architecture of fixed_shifter is
    constant L_SHIFT: natural := 0;
    constant R_SHIFT: natural := 1;
    constant L_ROTATE: natural := 2;
    constant R_ROTATE: natural := 3;
    constant R_SHIFT_ARITHMETIC := 4;
    signal sh_tmp, zero: std_logic_vector(WIDTH-1 downto 0);
    signal sign_augmented: std_logic_vector(WIDTH-1 downto 0);
begin
    zero <= (others => '0');
    sign_augmented <= (others => s_in(WIDTH-1));
    -- left shit
    left_shifter:
    if (S_MODE = L_SHIFT) generate
        sh_tmp <= s_in(WIDTH-1-S_AMT downto 0) & zero(WIDTH-1 downto WIDTH-S_AMT);
    end generate;

    -- left rotate
    left_rotate:
    if (S_MODE = L_ROTATE) generate 
        sh_tmp <= s_in(WIDTH-1-S_AMT downto 0) & s_in(WIDTH-1 downto WIDTH-S_AMT);
    end generate;

    -- right shift
    right_shifter:
    if (S_MODE = R_SHIFT) generate
        sh_tmp <= zero(S_AMT-1 downto 0) & s_in(WIDTH-1 downto S_AMT);
    end generate;

    -- right rotate
    right_rotate:
    if (S_MODE = R_ROTATE) generate
        sh_tmp <= s_in(S_AMT-1 downto 0) & s_in (WIDTH -1 downto S_AMT) ;
    end generate;

    -- arithmetic shift right
    shift_right_arithemtic:
    if (S_MODE = R_SHIFT_ARITHMETIC) generate
        sh_tmp <= sign_augmented(S_AMT-1 downto 0) & s_in(WIDTH-1 downto S_AMT)
    end generate;

    s_out <= sh_tmp when shift = '1' else s_in;

end para_architecture;

-- we consider first understanding the code that has been written
entity barrel_shifter is
    generic (
        WIDTH: natural;
        S_MODE: natural
    );
    
    port (
        a: in std_logic_vector(WIDTH-1 downto 0);
        amt: in std_logic_vector(log2c(WIDTH)-1 downto 0);
        y: out std_logic_vector(WIDTH-1 downto 0)
    );
end barrel_shifter;


architecture arch of barrel_shifter is
    constant STAGE: natural := log2c(WIDTH);
    type std_aoa_type is array (STAGE downto 0) of std_logic_vector(WIDTH-1 downto 0);
    signal p: std_aoa_type;


begin
    
    p(0) <= a;
    state_gen: 
    for s in 0 to (STAGE-1) generate
        shift_slice: entity work.fixed_shifter(para_architecture)
        generic map (
            WIDTH => WIDTH, S_MODE => S_MODE, S_AMT => 2**s
        )

        port map(
            s_in => p(s), s_out => p(s+1), shift => amt(s)
        );
    end generate;

    y <= p(STAGE);
end arch;


-- we figured out that it is enought to change make the change at the level of the fixed shifter
-- the parametrized parallel architecture will include the change automatically.

-- 

