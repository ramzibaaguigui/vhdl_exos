library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_m_n is 
    generic (
        M: natural; N: natural; W: natural
    );
    port (
        clk, reset: in std_logic;
        en: in std_logic;
        q: out std_logic_vector(WIDTH - 1 downto 0);
        pulse: out std_logic
    );
end counter_m_n;

architecture Behavioral of counter_m_n is
    signal r_reg, r_next: unsigned(WIDTH - 1 downto 0);
    begin
        -- regisers 
        process(clk, reset) 
            begin
                if (reset = '1') then --  reset to default
                    r_reg <= M;
                elsif (clk'event and clk = '1') then
                    r_reg <= r_next;
                end if;
            end process;
        
        -- next value logic
        process(en, r_reg) 
            begin
                if (en = '0') then -- do noting
                    r_next <= r_reg;
                else
                    if (r_reg = N) then -- reset to M
                        r_next <= M;
                    else   
                        r_next <= r_reg + 1;
                    end if;
                end if;
            end process;
        
        -- OUTPUT
        q <= r_reg;
        pulse <= '1' when r_reg = N else '0';
    end Behavioral;

    -- dONE WITH EX 13.4
    