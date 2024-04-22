library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker is 
    port (
        clk, reset: in std_logic; 
        ack_in: in std_logic;
        data_in: in std_logic_vector(15 downto 0); 
        req_out: out std_logic;
        data_out: out std_logic_vector(15 downto 0);
        addr_out: out std_logic_vector(3 downto 0);
        pull_out: out std_logic
    );
end talker;


architecture arch of talker is 
    type state_type is (idle, working); 
    signal state_reg, state_next: state_type;

    -- Suppose that the control registers are existing but controlled by another entity, 
    -- in our code, we will just consider reading them, not modifying them
    signal start: std_logic;
    signal addr_reg, addr_next: std_logic;
    signal pull_reg, pull_next: std_logic;
    signal data_export_reg, data_export_next;
    signal data_import_reg, data_import_next;
    signal req_buf_reg, req_buf_next: std_logic;
begin

    -- static wiring
    -- the pull register is always exposed to the exeternal world
    pull_out <= pull_reg;

    -- the addr is always exposed to the external world
    addr_out <= addr_reg;

    -- the data export register is always exposed to the external wrold 
    data_out <= data_export_reg;

    -- THE req signal is always exposed to the external world
    req_out <= req_buf_reg;

    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default =
            state_reg <= idle; 
            addr_reg <= (others => '0');
            pull_reg <= '0'; 
            data_export_reg <= (others => '0'); 
            data_import_reg <= (others => '0'); 
            req_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next; 
            addr_reg <= addr_next; 
            pull_reg <= pull_next; 
            data_export_reg <= data_export_next; 
            data_improt_reg <= data_import_next;
            req_buf_reg <= req_buf_next;
        end if;
    end process;

    -- next state, routing datapath
    process(state_reg, ack_in, data_in, data_import_reg, addr_reg, start, ) 
    -- consider taking a look on the sensitivity list if to check all=
    begin
        -- default values for next nvalues
        state_next <= state_reg;
        addr_next <= addr_reg;
        pull_next <= pull_reg;
        data_export_next <= data_export_reg;
        data_import_next <= data_import_reg;
        req_buf_next <= req_buf_reg;

        case state_reg is 
            when idle => 
                -- wait for the start signal to get checked
                if start = '1' then 
                    -- go to the state doing the world
                    state_next <= working;
                    -- get the command and the data
                    -- we are supposing that the data is already available at 
                    -- those registers
                    -- so, we move to the next state only

                    else 
                    -- rest in the same state 
                    state_next <= idle; 
                end if;

            when working => 
                -- invert the req signal
                req_buf_next <= not req_buf_reg;
                state_next <= idle;
                
        end case;
    end process;

end arch;
-- we should be done with the entire design
