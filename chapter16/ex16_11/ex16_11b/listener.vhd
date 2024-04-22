library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic;
        ack_out: out std_logic;
        data_inout: data_inout std_logic_vector(15 downto 0);
        ttl_granted, ltt_granted: in std_logic
    );
end listener;


architecture arch of listener is 
    type state_type is (idle, requesting, waiting, acknowledging, ready);
    signal state_reg, state_next: state_type;

    signal start_internal, ready_internal: std_logic;
    signal a_internal, b_internal: std_logic_vector(7 downto 0);
    signal r_internal: std_logic_vector(15 downto 0);

    -- for the bidirectional data port
    signal data_in: std_logic_vector(15 downto 0);
    signal data_out: std_logic_vector(15 downto 0);
    signal en_data_in, en_data_out: std_logic;

    signal ack_out_buf, ack_out_next: std_logic;
begin

    -- create an instance of the sequential multiplier inside
    mult_unit:
    entity work.seq_mult(add_shift_arch)
        generic map (
            WIDTH => 16, COUNTER_WIDTH => 4, COUNTER_INIT => "1000"
        )
        port map (
            reset => reset, clk => clk, 
            start => start_internal,
            a_in => a_internal, b_in => b_internal,
            ready => ready_internal, r => r_internal
        );
    
    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default
            state_reg <= idle;
            ack_out_buf <= '0';
        elsif (clk'event and clk = '1') then 
            -- next value
            state_reg <= state_next;
            ack_out_buf <= ack_out_next;
        end if;
    end process;


    -- bidirectional input port handling    
    -- ttl_granted => input_enabled
    -- ltt_granted => output_enabled
    en_data_in <= ttl_granted;
    en_data_out <= ltt_granted;
    
    -- tristate buffer inferring for input and output
    data_in <= data_inout when en_data_in = '1' else (others => 'Z');
    data_inout <= data_out when en_data_out = '1' else (others => 'Z');

    -- wire the ready signal of the multiplier
    
    -- next value, data path routing...
    process(state_reg, req_in) 
    begin
        -- default values
        state_next <= state_reg;
        start_internal <= '0'; -- the start internal is not asserted by default

        data_out <= (others => 'Z');

        case state_reg is 
            when idle => 
                -- waiting for the req signals
                if req_in = '1' then
                    -- get to the requesting state
                    state_next <= requesting;
                else 
                    -- rest in the same state
                    state_next <= idle;
                end if;
            
            when requesting => 
                -- wait for the ready signal coming from the multiplier unit
                -- assert the start value to '1'
                start_internal <= '1';
                state_next <= waiting;

            when waiting => 
                -- wait for the ready signal to be asserted
                if ready_internal = '1' then 
                    state_next <= acknewledging;
                else
                    -- remain in the same state
                    state_next <= waiting;
                end if;
            
            when acknowledging => 
                -- the ack signal is handled in the look-ahead buffering process
                -- expose the result to the outer world
                -- wait for the req to become '0'
                if (req_in = '0') then
                    state_next <= ready;
                else
                    state_NEXT <= acknowledging;
                end if;

            when ready => -- consider the start signal as well here
                    -- expose the multiplication result to the outer world
                    -- the wirint is handled from the other side
                    if req_in = '1' then
                        -- get to the requesting state
                        state_next <= requesting;
                    else 
                        -- rest in the same state
                        state_next <= ready;
                    end if;

        end case;
    end process;

    -- look-ahead buffering
    process(state_next) 
    begin
        -- there are many more buffers to consider
        ack_out_next <= ack_out_buf;

        case state_next  is 
            when acknowledging => 
                ack_out_next <= '1';
            
            when others =>
                ack_out_next <= '0';
            
        end case;
    end;

    -- the input is always wired to the input of the multiplier
    a_internal <= data_in(7 downto 0);
    b_internal <= data_in(15 downto 0);
    
    -- the result is always wired to the output of the listener
    data_out <= r_internal;
end arch;

-- just some discussion here
-- the different that the system passes through are like the following
-- in the first place, we are in the idle state
-- waiting for the req signal
-- once receiving the request signal, generate the start pulse to the internal multiplier
-- wait for the ready signal to be asserted
-- send the ack
-- put the result on the bus
-- 

-- overall, the general functionalities are covered here,
-- the simulation will show us more details that we might not have considered in the first place
