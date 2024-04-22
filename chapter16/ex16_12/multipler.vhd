library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this file contains the code for the sequential multiplier in section 11.6 

entity seq_mult is  
    generic (
        WIDTH: integer;
        COUNTER_WIDTH: integer;
        COUNTER_INIT: unsigned(COUNTER_WIDTH-1 downto 0)
    );
    port (
        clk, reset: in std_logic;
        start: in std_logic;
        take_a_in, take_b_in: in std_logic;
        a_in, b_in: in std_logic_vector(WIDTH-1 downto 0);
        ready: out std_logic;
        r: out std_logic_vector(2*WIDTH-1 downto 0)
    );
end seq_mult;

architecture add_shift_arch of seq_mult is 
    constant WIDTH: integer := 8;
    constant COUNTER_WDITH: integer := 4;
    constant COUNTER_INIT: unsigned(COUNTER_WDITH-1 downto 0) := "1000";
    
    type state_type is (idle, add, shift);
    signal state_reg, state_next: state_type;
    signal b_reg, b_next: std_logic_vector(WIDTH-1 downto 0);
    signal a_reg, a_next: std_logic_vector(2*WIDTH-1 downto 0);
    signal c_reg, c_next: std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal p_reg, p_next: std_logic_vector(2*WIDTH-1 downto 0);
    
begin

    -- state and data registers
    process(clk, reset)
    begin
        if (reset = '1') then 
            -- reset all to default
            b_reg <= (others => '0');
            a_reg <= (others => '0');
            n_reg <= (others => '0');
            p_reg <= (others => '0');
        elsif (clk'event and clk = '1') then 
            b_reg <= b_next;
            a_reg <= a_next;
            n_reg <= n_next;
            p_reg <= p_next;
        end if;
    end process;

    -- Combinational circuit
    process(start, state_reg, b_reg, a_reg, n_reg, p_reg, b_in, a_in, n_next, a_next)
    begin
        a_next <= a_reg;
        b_next <= b_reg;
        n_next <= n_reg;
        p_next <= p_reg;
        ready <= '0';

        case state_reg is 
            when idle => 
                -- the new bus width required us to perform a modification on the multiplier level, 
                -- so that we can get the values to the internal registers of the multipler one by one
                ready <= '1';
                if (start = '1') then
                    n_next <= C_INIT;
                    p_next <= (others => '0');
                    if (b_in(0) = '1') then 
                        state_next <= add;
                    else 
                        state_next <= shift;
                    end if;
                else
                    state_next <= idle;    
                    
                    -- take b in
                    if take_b_in = '1' then 
                        b_next <= unsigned(b_in);
                    end if;

                    if take_a_in = '1' then 
                        -- take the value of a into the registers
                        a_next(2*WIDTH-1 downto WIDTH) <= (others => '0');
                        a_next(WIDTH-1 downto 0) <= unsigned(a_in);                    
                    end if;
                end if;

            when add => 
                p_next <= p_reg + a_reg;
                state_next <= shift;
            
            when shift => 
                n_next <= n_reg -1 ;
                b_next <= '0' & b_reg(WIDTH-1 downto 1);
                a_next <= a_reg(2*WIDTH-2 downto 0) & '0';
                if (unsigned(n_next) /= 0) then 
                    if (a_next(0) = '1') then 
                        state_next <= add;
                    else
                        state_next <= shift;
                    end if;
                else
                    state_next <= idle;
                end if;
        end case;
    end process;

    -- output
    r <= std_logic_vector(p_reg);
end add_shift_arch;

-- WE ARE DONE WITH THE MULTIPLIER  