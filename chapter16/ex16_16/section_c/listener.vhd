

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic; 
        addr_in: in std_logic_vector(3 downto 0); 
        data_out: out std_logic_vector(15 downto 0)
    );
end listener; 

architecture arch of listener is 
    type array_type is array(3 downto 0, 15 downto 0) of std_logic;
    signal array_reg, array_next: array_type; 

    type state_type is (idle, r1, r2, r3, r4, r5, r6, r7, r8);
    signal state_reg, state_next: state_type;

begin
    -- infer registers 
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default
            state_reg <= idle; 
            array_reg <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next; 
            array_reg <= array_next;
        end if;
    end process;

    -- next state, data path routing logic 
    process(state_reg, req_in) 
    begin
        -- default values
        array_next <= array_reg; 
        state_next <= state_reg;

        case state_reg is 
            when idle => 
                if req_in = '1' then 
                    -- get the address in
                    addr_next <= addr_in;
                    state_next <= r1;
                else 
                    state_next <= idle;
                end if;
            
            when r1 => 
                state_next <= idle;
        end case;
    end process;

    -- exposing the output
    data_out <= array_reg(
        to_integer(unsigned(addr_reg)),
        15 downto 0
    );

end arch;

-- the design should be done