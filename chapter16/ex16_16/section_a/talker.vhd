
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker is 
    port (
        clk, reset: in std_logic; 
        data_in: in std_logic_vector(15 downto 0);
        addr_out: out std_logic;
        req_out: std_logic
    );
end talker;

architecture arch of talker is 
    type state_type is (idle, r1, r2, r3, r4, r5, done);
    signal state_reg, state_next: state_type;

    signal data_import_reg, data_import_next: std_logic_vector(15 downto 0); 
    signal addr_reg, addr_next: std_logic_vector(3 downto 0); 
    signal start: std_logic; -- how this is generate?
    signal req_buf_reg, req_buf_next: std_logic;
begin
    -- infer registers
    process(clk, reset) 
    begin
        if reset = '1' then 
            -- reset all to default value
            state_reg <= idle; 
            data_import_reg <= (others => '0'); 
            addr_reg <= (others => '0'); 
            req_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
            data_import_reg <= data_import_next; 
            addr_reg <= addr_next;
            addr_buf_reg <= addr_buf_next;
        end if;
    end process;

    -- next state, data routing logic 
    process(state_reg, start, data_in, ...)
    begin
        -- default values 
        state_next <= state_reg; 
        addr_next <= addr_reg; 
        req_buf_next <= req_buf_reg;
        addr_next <= addr_reg;
        data_import_next <= data_import_reg;
        
        case state_reg is 
            when idle => 
                -- wait for the start signal 
                if start = '1' then 
                    -- go to the next state to handle transfer of data
                    req_buf_next <= '1';
                    state_next <= r1;
                else 
                    -- rest in the same state 
                    state_next <= idle; 
                end if;
            when r1 => 
                state_next <= r2; 
            
            when r2 => 
                state_next <= r3; 

            when r3 => 
                state_next <= r4;
            when r4 => 
                state_next <= r5;
            when r5 => 
                req_buf_next <= '0';
                data_import_next <= data_in;
                state_next => done;

            when done => 
                state_next <= idle;

        end case;

    end process;
end arch;