library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker is 
    port (
        clk, reset: in std_logic;
        ack_in: in std_logic; 
        req_out: out std_logic;
        pull_out: out std_logic; -- '1' when the op is pull, '0' when push 
        data_inout: inout std_logic_vector(7 downto 0); 
        addr_out: out std_logic_vector(2 downto 0)
    );
end talker;

architecture arch of talker is 
    -- type state_type is (req_low, req_high);
    type state_type is (idle, working);
    signal state_reg, state_next: state_type; 
    
    signal addr: std_logic_vector(2 downto 0); 
    signal command: std_logic;
    
    signal read_data_reg, read_data_next: std_logic_vector(7 downto 0); 
    signal written_data_reg, written_data_next: std_logic_vector(7 downto 0);

    signal start: std_logic;

    -- bidirectional signals control 
    signal data_in_enabled, data_out_enabled: std_logic; 
    signal data_in, data_out: std_logic_vector(7 downto 0);

begin

    -- the command is always exposed to the external world
    pull_out <= command;

    -- expose the address as well =
    addr_out <= addr_reg;

    -- bidirectional control 
    data_in_enabled <= '1' when command = COMMAND_PULL else '0'; 
    data_out_enabled <= '1' when command = COMMAND_PUSH else '0';

    data_in <= data_inout when (data_in_enabled = '1') else (others => 'Z');
    data_inout <= data_out when (data_out_enabled = '1') else (others => 'Z');

    data_out <= written_data_reg;

    -- inferring registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default
            state_reg <= idle; 
            req_buf_reg <= '0';
            read_data_reg <= (others => '0'); 
            written_data_reg <= (others => '0'); 
            addr_reg <= (others => '0'); 

        elsif (clk'event and clk = '1') then 
            -- take the next value
            state_reg <= state_next;
            req_buf_reg <= req_buf_next;
            read_data_reg <= read_data_next; 
            written_data_reg <= written_data_next;
            addr_reg <= addr_next;
        end if; 
    end process;


    process(state_reg, start, addr, command, read_data_reg, written_data_reg)
    begin
        -- default values
        read_data_next <= read_data_reg;
        written_data_next <= written_data_reg;

        case state_reg is 
            when idle => 
                -- wait for the start signal to get asserted,
                -- all the data is available in the register
                if start = '1' then 
                    state_next <= working; 
                    req_buf_next <= not req_buf_reg;
                end if;


            when working => 
                -- send the data to the external world
                

                -- wait for ack signal to be equal to the current value of the req
                -- recover data and go back to the idle state
                case command is 
                    when COMMAND_PULL => 
                        if ack_in = req_buf_reg then -- there is a response from the other side 
                            -- recover the data
                            read_data_next <= data_in;
                            -- go to the idel state
                            state_next <= idle;
                        else 
                            state_next <= working;
                        end if;

                    when COMMAND_PUSH => 
                        if (ack_in = req_buf_reg) then 
                            state_next <= idle;
                        else 
                            state_next <= working;
                        end if;
                end case;
        end case;
    end process;
end arch;

