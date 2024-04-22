library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.11:
-- In the discussion of the multiplier circuit, the widths of the two input operands (i.e.,
-- multiplier and multiplicand) are assumed to be identical. In some application the widths can
-- be different. Let the number of bits of multiplier and multiplicand be MR and MD respectively.
-- Modify the sequential multiplier code of Listing 15.16 for the new requirement.

-- in the first place, we consider copying the content of listing 15.16
-- and then we go with the refinement process to make it working with 
-- cases in which the widths are not identical



entity seq_mult_para is 
    generic (
        WIDTH_A: natural,
        WIDTH_B: natural
        
    );
    port (
        clk, reset: in std_logic;
        start: in std_logic;
        -- a_in: in std_logic_vector(WIDTH-1 downto 0);
        a_in: in std_logic_vector(WIDTH_A-2 downto 0);

        -- b_in: in std_logic_vector(WIDTH-1 downto 0);
        b_in: in std_logic_vector(WIDTH_B-1 downto 0);
        ready: out std_logic;
        -- r: out std_logic_vector(2*WIDTH-1 downto 0);
        r: out std_logic_vector(WIDTH_A + WIDTH_B - 1 downto 0);
    );
end seq_mult_para;

architecture shift_add_better_arch of seq_mult_para is 
    -- constnat width min and width max
    constant WIDTH_RIGHT: natural := min(WIDTH_A, WIDTH_B);
    constant WIDTH_LEFT: natural := max(WIDTH_A, WIDTH_B);

    constant C_WIDTH: natural := log2c(WIDTH_RIGHT) + 1;
    constant C_INIT: unsigned(C_WIDTH-1 downto 0)
        := to_unsigned(WIDTH_RIGHT, C_WIDTH);
    
    -- constant WIDTH_LEFT: natural := min(WIDTH_A, WIDTH_B);
    -- constant WIDTH_RIGHT: natural := max(WIDTH_A, WIDTH_B);

    type state_type is (idle, add_shift);

    signal state_reg, state_next: state_type;
    signal a_reg, a_next: unsigned(WIDTH_LEFT-1 downto 0);
    signal n_reg, n_next: unsigned(C_WIDTH-1 downto 0);
    signal p_reg, p_next: unsigned(WIDTH_LEFT+WIDTH_RIGHT downto 0);

    -- alias for the upper part and the lower part of the p register
    alias pu_next: unsigned(WIDTH_LEFT downto 0) is 
        p_next(WIDTH_LEFT + WIDTH_RIGHT downto WIDTH_RIGHT);
    alias pu_reg: unsigned(WIDTH_LEFT downto 0) is 
        p_reg(WIDTH_LEFT + WIDTH_RIGHT downto WIDTH_RIGHT);

    alias pl_reg: unsigned(WIDTH_RIGHT-1 downto 0) is 
        p_reg(WIDTH_RIGHT-1 downto 0);
    
    signal a_augmented: std_logic_vector(WIDTH_LEFT-1 downto 0);
    signal b_augmented: std_logic_vector(WIDTH_RIGHT-1 downto 0);

begin

    -- for better performance, it is better to consider the signal with the min width between a_in and b_in 
    -- to be placed on the right side (b_augmented)
    -- and for the sighal with the max width to be placed on the left side (a_augmented)

    -- if a_in width > b_in width
    if (a_in'width > b_in'width) generate
        -- route a_in to a_augmented and 
        -- route b_in to b_augmented
        a_augmented <= a_in;
        b_augmented <= b_in;

    end generate;


    if ((a_in'width = b_in'width) or (a_in'width < b_in'width))agenerate
        -- route a_in to b_augmented 
        -- route b_in to a_augmented 
        a_augmented <= b_in;
        b_augmented <= a_in;
    end generate;
    -- now that the wiring is determined based on the legths of a_in and b_in,
    -- any further processing will be performed on a_augmented and b_augmented
    
    -- state and data registers 
    process(clk, reset) 
    begin
        if (reset = '1') then 
            state_reg <= idle;
            a_reg <= (others => '0');
            b_reg <= (others => '0');
            p_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
            a_reg <= a_next; 
            b_reg <= b_next; 
            p_reg <= p_next;
        end if;
    end process;

    -- combination circuit
    process(start, state_reg, a_reg, b_reg, a_in, p_reg, a_augmented, b_augmented, n_next, p_next) 
    begin
        a_next <= a_reg;
        b_next <= b_reg;
        p_next <= p_reg;
        ready <= '0';

        case state_reg is 
            when idle => 
                ready <= '1';
                if start = '1' then
                    p_next(WIDTH_RIGHT-1 downto 0) <= unsigned(b_augmented);
                    p_next(WIDTH_LEFT + WIDTH_RIGHT downto WIDTH_RIGHT) <= (others => '0');
                    a_next <= unsigned(a_augmented);
                    n_next <= C_INIT;
                    state_next <= add_shift;
                else
                    state_next <= idle
                end if;
                
            when add_shift => 
                n_next <= n_reg - 1;

                -- add
                if (p_reg(0) = '1') then
                    pu_next <= pu_reg + ('0' & a_reg);
                else
                    pu_next <= pu_reg;
                end if;
                
                -- shift
                p_next <= '0' * pu_next & pl_reg(WIDTH_RIGHT-1 downto 1);
                
                if (n_next /= 0) then 
                    state_next <= add_shift;
                else 
                    stat_next <= idle;
                end if;
        end case;
    end process;
    r <= std_logic_vector(p_reg(WIDTH_LEFT + WIDTH_RIGHT - 1 downto 0));
end shift_add_better_arch;

-- we are required to make this architecture accept any type of input signals

-- the above design should work with the best performance despite the widths of a_in and b_in