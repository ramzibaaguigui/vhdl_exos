library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic;
        ack_out: out std_logic;
        data_in: in std_logic_vector(15 downto 0); 
        pull_in: in std_logic;
        data_out: out std_logic_vector(15 downto 0);
        addr_in: in std_logic_vector(3 downto 0)
    );
end listener; 

architecture arch of listener is 
    constant COMMAND_PULL: std_logic := '1';
    constant COMMAND_PUSH: std_logic := '0';

    type array_type is array(3 downto 0, 15 downto 0) of std_logic;
    signal array_reg, array_next: array_type;

    type state_type is (idle, working);

    signal ack_buf_reg, ack_buf_next: std_logic;
    signal command_reg, command_next: std_logic;

    -- data registers for input and outpu
    signal exoprt_reg, export_next: std_logic_vector(15 downto 0); 
    signal import_reg, import_next: std_logic_vector(15 downto 0);
    
begin

    -- wire the export register to the data out
    data_out <= export_reg;
    ack_out <= ack_buf_reg;
    
    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then
            -- reset all to default values
            state_reg <= idle; 
            array_reg <= (others => (others => '0'));
            ack_buf_reg <= '0';
        elsif (clk'event and clk = '1') then 
            -- take next values 
            state_reg <= state_next;
            array_reg <= array_next;
            ack_buf_reg <= ack_buf_next;
        end if;
    end process;

    -- next state, routing data paths
    process(state_reg, data_in, req_in, addr_in)
    begin
        -- default values
        state_next <= state_reg;
        command_next <= command_reg;
        addr_next <= addr_reg;
        array_next <= array_reg;
        ack_buf_next <= ack_buf_reg;
        import_next <= import_reg; 
        export_next <= export_reg;

        case state_reg is 
            when idle => 
                -- wait for a signal with a value different from the current value of the ack
                if ack_buf_reg = req_in then
                    -- stay in the same state
                    state_next <= idle;
                else 
                    state_next <= working;
                    command_next <= pull_in;
                    -- take the necessary values in: (command and addr)
                    import_next <= data_in;
                    addr_next <= addr_in; 

                end if;

            when working => 
                state_next <= idle; 
                ack_buf_next <= not ack_buf_reg; 

                case command_reg is 
                    when COMMAND_PULL => 
                        -- pull means reading from the register
                        -- expose the target world
                        export_next <= array_reg(to_integer(unsigned(addr_reg)), 15 downto 0);

                    when COMMAND_PUSH => 
                        array_next(to_integer(unsigned(addr_reg)), 15 downto 0) <= import_reg;
                end case;
        end case;

    end process;
end arch;
