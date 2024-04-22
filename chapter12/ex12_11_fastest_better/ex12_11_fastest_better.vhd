-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity other is port(
    a: in std_logic_vector(3 downto 0)
); end other;

entity barrel_shifter is port (
    a: in std_logic_vector(7 downto 0);
    amt: in std_logic_vector(2 downto 0);
    dir: in std_logic;
    y: out std_logic_vector(7 downto 0)
); end barrel_shifter;


architecture Behavioral of barrel_shifter is begin 

end Behavioral;

entity trail_zero_counter is port (
    a: in std_logic_vector(7 downto 0);
    y: out std_logic_vector(3 downto 0)
); end trail_zero_counter;

architecture Behavioral of trail_zero_counter is begin end Behavioral;


entity gcd is port (
    clk, reset: in std_logic;
    start: in std_logic;
    a_in, b_in: in std_logic_vector(7 downto 0);
    ready: out std_logic;
    r: out std_logic_vector(7 downto 0) 
); end gcd;

architecture Behavioral of gcd is 
    type state_type is (idle, swap, sub, shifta, shiftb);
    signal state_reg, state_next: state_type;
    signal a_reg, a_next: unsigned(7 downto 0);
    signal b_reg, b_next: unsigned(7 downto 0);
    signal a_zero_reg, a_zero_next: unsigned(3 downto 0);
    signal n_reg, n_next: unsigned(3 downto 0);
    -- consider the input signal for each of the functions units that will be used
    signal trail_zero_counter_a_in: std_logic_vector(7 downto 0);
    signal trail_zero_counter_y_out: std_logic_vector(3 downto 0);
    signal barrel_dir_in: std_logic;
    signal barrel_a_in: std_logic_vector(7 downto 0);
    signal barrel_y_out: std_logic_vector(7 downto 0);
    signal barrel_amt_in: std_logic_vector(3 downto 0);
    signal min_barrel_y_a_zero_count: std_logic_vector (3 downto 0);
    -- add other signals if you feel that you need them
    begin
        -- state and data registers
        process(clk, reset)
            begin
                if (reset = '1') then -- reset all regs to default values
                    state_reg <= idle; 
                    a_reg <= (others => '0');
                    b_reg <= (others => '0');
                    a_zero_reg <= (others => '0');   
                    n_reg <= (others => '0');
                elsif (clk'event and clk = '1') then
                    state_reg <= state_next;
                    a_reg <= a_next;
                    b_reg <= b_next;
                    a_zero_reg <= a_zero_next;
                    n_reg <= n_next;
                end if;
            end process;
        
        -- next values logic, data path, and routing
        process(state_reg, a_reg, b_reg, a_zero_reg, n_reg, a_in, b_in, start)
            begin
                -- default values
                a_next <= a_reg;
                b_next <= b_reg;
                n_next <= n_reg;
                a_zero_next <= a_zero_reg;

                -- non register next values
                -- these are inputs and outputs of the barrel shifter and the counter
                -- the inputs can be mapped to zero with no problem
                -- the outputs can be left unconnected default
                -- we can assign a value that will be used later
                trail_zero_counter_a_in <= a_reg;
                -- trail_zero_counter_y_out; cab be left unconnected
                -- note that the way we treat inputs is not the same way with outputs
                barrel_dir_in <= '0'; -- right by default
                barrel_a_in <= a_reg;
                -- barrel_y_out;
                barrel_amt_in <= trail_zero_counter_y_out;
                min_barrel_y_a_zero_count <= (others => '0');
                -- the above signals can be changed based on the current state         
                -- consider the different states
                case state_reg is 
                    when idle => 
                        if (start = '1') then 
                            -- take the values in
                            a_next <= a_in;
                            b_next <= b_in;
                            n_next <= (others => '0');
                            a_zero_next <= (others => '0');
                            -- go to swap state
                            state_next <= swap;
                        else
                            state_next <= idle;
                        end if;
                    
                        when swap =>
                            -- this state decides where to go based on the values in the registers
                            if (a_reg = b_reg) then
                                if (n_reg = 0) then
                                    state_next <= idle;
                                else
                                    state_next <= res;
                                end if;
                            else 
                                if (a_reg(0) = '1' and b_reg(0) = '1') then -- both are odd
                                    state_next <= sub;
                                    if (a_reg < b_reg) then
                                        a_next <= b_reg;
                                        b_next <= a_reg;
                                    end if;
                                else
                                    if (a_reg(0) = '0') then
                                        state_next <= shifta;
                                    else 
                                        state_next <= shiftb;
                                    end if;
                                end if;
                            end if;
                        
                        when sub => 
                            a_next <= a_reg - b_reg;
                            state_next <= swap;
                        
                        when shifta =>
                            -- save the count of zeros
                            -- configure the trail zero counter for a
                            trail_zero_counter_a_in <= a_reg;
                            -- configure the barrel shifter fora a
                            if (b_reg(0) = '0') then -- save just in the case we will go the shiftb next
                                a_zero_next <= trail_zero_counter_y_out;
                            end if;
                            barrel_shifter_amt_in <= trail_zero_counter_y_out;
                            a_next <= barrel_shifter_y_out;
                            state_next <= swap;

                            

                        
                        when shiftb =>
                            state_next <= swap;
                            
                            -- configute the trail zero counter for b_reg
                            trail_zero_counter_a_in <= b_reg;

                            -- confiture the barrel shifter for the b reg
                            barrel_shifter_a_in <= b_reg;
                            barrel_shifter_amt_in <= trail_zero_counter_y_out;
                            -- the direction is by default to the right
                            
                            -- calculate the min value that
                            -- the trail zero counte produces
                            if (trail_zero_counter_y_out < a_zero_reg) then
                                min_barrel_y_a_zero_count <= trail_zero_counter_y_out;
                            else
                                min_barrel_y_a_zero_count <= a_zero_reg;
                            end if;

                            -- increment m with the minimum value between
                            -- z_zero_count and b_zero_count (actual value of TRAIL ZERO counter output)
                            n_next <= n_reg + min_barrel_y_a_zero_count;
                            a_zero_next <= (others => '0');
                        when res =>
                            state_next <= idle;
                            -- configure the barrel shifter for the a register
                            -- the shifting is to the left
                            -- with the amount stored in the n_reg
                            barrel_shifter_amt_in <= n_reg;
                            barrel_shifter_a_in <= a_reg;
                            barrel_shifter_dir_in <= '1'; -- to the left
                            a_next <= barrel_shifter_y_out; -- output of the barrel shifter
                end case;
            end process;
        
        -- port mapping the trail_zero_counter and barrel shifter

        shifter: entity work.barrel_shifter(Behavioral)
            port map (a => barrel_a_in, amt => barrel_amt_in, dir => barrel_dir_in, y => barrel_y_out);
        counter: entity work.trail_zero_counter(Behavioral)
            port map (a => trail_zero_counter_a_in, y => trail_zero_counter_y_out);
        
            -- some non timed mapping that need to be done
            -- the inputs and outputs of the above units
            -- 
        r <= a_reg;
        ready <= '1' when state_reg = idle else '0';
        
    end Behavioral;
    -- thta is it, we will check the design when we learn about the UVM methodology;
