library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity listener is 
    port (
        clk, reset: in std_logic;
        req_in: in std_logic;
        ttl_granted_in, ltt_granted_in: in std_logic;
        ack_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0)
    );
end listener;

architecture arch of listener is 
    type state_type is (idle, recover_1, recover_2, wait_result, expose_1, expose_2, ready);
    signal state_reg, state_next: state_type;
    -- the multiplier control signals
    signal mult_ready: std_logic;
    signal mult_take_a: std_logic;
    signal mult_take_b: std_logic;
    signal mult_start: std_logic;
    signal mult_a_in: std_logic(7 downto 0);
    signal mult_b_in: std_logic_vector(7 downto 0);
    signal mult_result: std_logic_vector(15 downto 0);
    -- to control the multiplier, we can manipulate these signals

    -- for the bidirectional data port 
    signal data_in, data_out: std_logic_vector(7 downto 0);
    signal data_in_enabled, data_out_enabled: std_logic;
    
begin
    -- instantiate the multipler
    mult_unit: 
    entity work.seq_mult(add_shift_arch)
        generic map(
            WIDTH => 16, 
            COUNTER_WIDTH => 4, 
            COUNTER_INIT => "1000"
        )
        port map (
            clk => clk, reset => reset, 
            start => mult_start, 
            take_a_in => mult_take_a,
            take_b_in => mult_take_b,
            a_in => mult_a_in, 
            b_in => mult_b_in,
            ready => mult_ready, 
            r => mult_result
        );

    -- data_in and data_out enable signals
    -- this is the listener, so:
    -- ttl_enabled => talker to listener enabled =>  input enabled
    data_in_enabled <= ttl_granted_in;

    -- ltt_enabled => listener to talker enabled => output enabled
    data_out_enabled <= ltt_granted_in;

    -- inferring the tristate buffer for the input and the output
    -- the used signals are: data_in, data_out, data_inout.
    data_inout <= data_out when data_out_enabled = '1' else (others => 'Z');
    data_in <= data_inout when data_in_enabled = '1' else (others => 'Z');
    -- further processing will use data_in and data_out 

    -- the data in is always buffered to the inputs of the multiplier
    mult_a_in <= data_in; 
    mult_a_in <= data_in;

    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default value =
            state_reg <= idle;
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
        end if;
    end process; 
    
    -- next state, routing logic 
    process(state_reg, req_in, data_inout, mult_ready, mult_result)
    begin   
        -- defaulv values 

        
        ack_out <= '0';
        mult_take_a <= '0';
        mult_take_b <= '0';
        mult_start <= '0';
        
        -- there might be some missing values, 
        -- we might validate this later

        case state_reg is 
            
            when idle => 
                -- wait for the ack_in signal to be asserted
                ack_out <= '0';
                if req_in = '1' then 
                    state_next <= recover_2; 
                    -- route the input to the input of the multiplier
                    -- tell the multipler to get the operand a in
                    mult_take_a <= '1';
                else 
                    state_next <= idle;
                end if;

            when recover_2 => 
                ack_out <= '1'; 
                -- wait for the req_in to become zero
                if req_in = '0' then 
                    -- take the value of the operand b in 
                    state_next <= launch_mult;
                    mult_take_b <= '1';
                else
                    -- rest in the same state
                    state_next <= recover_2;
                end if;

            when launch_mult => 
                ack_out <= '0';
                -- assert the start signal 
                -- move to the next state, in which to wait the result
                state_next <= wait_result; 
                mult_start <= '1';
            
            when wait_result =>
                ack_out <= '0'; 
                -- wait for the ready signal of the multipler to become asserted
                if mult_ready = '1' then 
                    -- means that the result is exposed at the output of the multiplier
                    state_next <= expose_1;
                else -- the result is not yet computed
                    -- remain in the same state
                    state_next <= wait_result; 

                end if;

            when expose_1 => 
                -- expose the first part of the result register to the data bus 
                data_out <= mult_result(7 downto 0);

                -- assert the ack signal to tell the talker about this 
                ack_out <= '1';
                
                -- wait for the req_in to become one, 
                -- so that we can move to the state in which we expose the second part of the operand
                if req_in = '1' then 
                    -- go to the state in which to exopse the second part
                    state_next <= expose_2;
                else 
                    -- stay in the same state 
                    state_next <= expose_1;

                end if;

            when expose_2 => 
                -- expose the second part of the result
                data_out <= mult_result (15 downto 8); 

                -- set the ack signal to '0' to tell the other side about the availability of the result
                ack_out <= '0';

                -- wait for the ack_in to become zero,
                -- to confirm that the other side has received the result
                if req_in = '0' then 
                    -- the other side received the result, so: 
                    -- go back to the idle state 
                    state_next <= idle;
                else 
                    -- rest in the same state
                    state_next <= expose_2;
                end if;
            
        end case;
    end process;


end arch;

-- ALL THE ASPECTS OF THE DESIGN SHOULD HAVE BEEN COVERED,
-- DONE FOR THIS EXERCISE