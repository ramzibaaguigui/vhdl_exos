library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (    
        clk, reset: in std_logic;
        req_in: in std_logic; 
        ack_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0)
        addr_in: in std_logic_vector(2 downto 0); 
        command_in: in std_logic; -- if the operation is pull or push
    );
end listener;

architecture arch of listener is 
    type array_type is array(7 downto 0, 7 downto 0) of std_logic;
    signal array_reg, array_next: array_type;

    type state_type is (waiting, executing); 
    signal state_reg, state_next: state_type;

    -- for the command type
    constant COMMAND_PUSH: std_logic := '1';
    constant COMMAND_PULL: std_logic := '0';
    type command_type is (pull, push);
    signal command_reg, command_next: command_type;


    -- the internal registers
    signal addr_reg, addr_next: std_logic;


    -- to control the input and output buffers
    signal data_in_enabled, data_out_enabled: std_logic; 
    signal data_in, data_out: std_logic_vector(7 downto 0);
    signal ack_buf_reg, ack_buf_next: std_logic;

begin

    -- buffering the input and the output
    data_in <= data_inout when data_in_enabled = '1' else (others => 'Z');
    data_inout <= data_out when data_out_enabled = '1' else (others => 'Z'); 

    -- expose the value of the target word to the external world
    data_out <= array_reg(to_integer(unsigned(addr_in)), 7 downto 0);

    -- control the input and output buffers
    -- in this case, they are controlled by the pull input (controlled by the talker)
    data_in_enabled <= '1' when command_in = COMMAND_PUSH else '0'; 
    data_out_enabled <= '1' when command_in = COMMAND_PULL else '0';

    -- wiring the ack buffer register to the output ack 
    ack_out <= ack_buf_reg;
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default value
            state_reg <= waiting; -- certain value
            addr_reg <= (others => '0'); 
            ack_buf_reg <= '0';
            command_reg <= pull;
            array_reg <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next; 
            addr_reg <= addr_next;
            ack_buf_reg <= ack_buf_next;
            command_reg <= command_next;
            array_reg <= array_next;
        end if;
    end process;

    process(state_reg, addr_in, req_in, addr_in, command_in, data_inout) 
    begin
        -- default values
        array_next <= array_reg;
        addr_next <= addr_reg;
        command_next <= command_reg;
        ack_buf_next <= ack_buf_reg;
        case state_reg is 
            when waiting => 
                -- witing for the signal to become not equal to the our current ack signal
                if req_in = ack_buf_reg then 
                    state_next <= waiting; 
                else
                    state_next <= executing;
                    addr_next <= addr_in;
                    -- get the command to execute
                    if command_in = COMMAND_PUSH then 
                        command_next <= push;
                    else -- if the command is pull
                        command_next <= pull;
                    end if;
                end if;

            when executing => 
                state_next <= waiting;
                ack_buf_next <= not ack_buf_reg; -- invert the ack to notify the other side
                case command_reg is 
                    when push => 
                        -- write the data to the register at the target address
                        array_next(addr_reg, 7 downto 0) <= data_in;
                    when pull => 
                        -- nothing special, it is all done implicitly in other parts of the code

                end case;
        end case;

    end process;

end arch;

-- hoping that all the things are well done
