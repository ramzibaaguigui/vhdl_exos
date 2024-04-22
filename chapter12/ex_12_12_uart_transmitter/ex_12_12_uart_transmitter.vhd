library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_transmitter is port(
    clk, reset: in std_logic;
    d_in: in std_logic_vector(7 downto 0);
    en_in: in std_logic;
    start: in std_logic;
    y: out std_logic;
    ready: out std_logic
); end uart_transmitter;


architecture Behavioral of uart_transmitter is 
    type state_type is (idle, send);
    signal state_reg, state_next: state_type;

    -- the register holding the data we are about to send;
    signal d_reg, d_next: std_logic_vector(9 downto 0);
    signal n_reg, n_next: unsigned(3 downto 0);
    signal c_reg, c_next: unsigned(9 downto 0);

    begin
        -- state and data registers
        process(clk, reset)
            begin
                if (reset = '1') then -- reset all to default
                    state_reg <= idle;
                    d_reg <= (others => '0');
                    n_reg <= (others => '0');
                    c_reg <= (others => '0');
                elsif (clk'event and clk = '1') then
                    state_reg <= state_next;
                    d_reg <= d_next;
                    n_reg <= n_next;
                    c_reg <= c_next;
                end if;
            end process;
        
        -- next state, routing, datapath, and functional units
        process(state_reg, n_reg, c_reg, d_reg, start, en_in)
            begin
                -- default values
                n_next <= n_reg;
                d_next <= d_reg;
                c_next <= c_reg;

                case state_reg is 
                    when idle => 
                        if (en_in = '1') then -- program the d register
                            d_next <= '1' & d_in & '0';
                            state_next <= idle;
                        else
                            if (start = '1') then -- start sending
                                state_next <= send;
                                n_next <= (others => '0');
                                c_next <= (others => '0');
                            else
                                state_next <= idle;
                            end if;
                        end if;
                    when send => 
                        -- the value might be put as a param above
                        if (c_reg = 833) then
                            c_next <= (others => '0');
                            if (n_reg = 9) then -- means: all bits are sent
                                state_next <= idle;
                                n_next <= (others => '0');
                            else
                                -- shift the d register to the right
                                state_next <= send;
                                d_next <= d_reg (0) & d_reg(9 downto 1);
                                n_next <= n_reg + 1;
                            end if;
                        else -- if count < 833
                        -- increment the counter
                        c_next <= c_reg + 1;
                        state_next <= send;
                        end if;
                end case;
            end process;

        -- output logic
        ready <= '1' when state_reg = idle else '0';
        y <= d_reg(0) when state_reg = send else '1'; 
        -- one is the default value in uart
    end Behavioral;