library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity talker is
    port (
        ttl_granted_in, ltt_granted_in: std_logic;
        clk, reset: in std_logic;
        a_in, b_in: in std_logic_vector(7 downto 0);
        start: in std_logic;
        r_out: out std_logic_vector(15 downto 0);
        ack_in: in std_logic;
        req_out: out std_logic;
        data_inout: inout std_logic_vector(7 downto 0);
    );
end talker;

architecture arch of talker is 

    type state_type is (idle, expose_1, expose_2, recover_1, recover_2, ready);
    state_reg, state_next: state_type;

    signal data_in_enabled, data_out_enabled: std_logic;
    signal data_in, data_out: std_logic_vector(7 downto 0);

    -- register to store the operands or the result
    signal data_reg, data_next: std_logic_vector(15 downto 0);
begin
    -- from the ttl_granted and ltt_granted to enable input and output buffers
    -- this is the talker, so: 
    -- ttl_granted => talker to listener => output enabled
    data_out_enabled <= ttl_granted_in;
    -- ltt_granted => listener to talker => input enabled
    data_in_enabled <= ltt_granted_in;
    ------------------------------------------------

    -- generating the input and output buffers for the data_in and data_out
    data_inout <= data_out when (data_out_enabled = '1') else (others => 'Z');
    data_in <= data_inout when (data_in_enabled = '1') else (others => 'Z');
    ---------------------------------------------------------------------------
    -- The necessary wiring is normally done, consider working on the remaining logic


    -- infer registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default
            data_reg <= (others => '0');
            state_reg <= idle;
        elsif (clk'event and clk = '1') then 
            data_reg <= data_next;
            state_reg <= state_next;
        end if;
    end process;


    -- next state logic, and routing staff
    process(state_reg, a_in, b_in, data_inout, ack_in, start)
    begin
        -- default values
        state_next <= state_reg;
        data_next <= data_reg;

        req_out <= '0';

        case state_reg is
            when idle => 
                -- wait for the start signal to be asserted
                data_next <= b_in & a_in; -- get the operands in
                state_next <= expose_1;

            when expose_1 => 
                req_out <= '1';
                -- expose the first operand to the exernal world
                data_out <= data_reg(7 downto 0);

                -- wait for the ack signal to get asserted
                if ack_in = '1' then -- the other side received the requst
                    -- means that this is the time to expose the second operand
                    state_next <= expose_2;        
                else -- the other side did not yet receive the data
                    -- remain  in the same state
                    state_next <= expose_1;
                end if;

            when expose_2 => 
                req_out <= '0';
                -- expose the second operand to the external world
                data_out <= data_reg(15 downto 8);

                -- wait for the other side to assert the ack signal to '0'
                if ack_in = '0' then 
                    -- move to the state in which to recover the result
                    state_next <= recover_1;
                else    
                    state_next <= expose_2;
                end if;
                
            when recover_1 => 
                -- wait for the ack signal to get asserted from the other side
                req_out <= '0';
                if ack_in = '1' then 
                    data_next(7 downto 0) <= data_in;
                    state_next <= recover_2;
                else -- if the result is not yet exposed
                    -- rest in the same state
                    state_next <= recover_1;
                end if; 

            when recover_2 => 
                req_out <= '1';

                -- wait for the ack signal to become zero
                if ack_in = '0' then 
                    data_next(15 downto 0) <= data_in;
                    state_next <= ready;
                else -- stay in the same stat 
                    state_next <= recover_2;
                end if;
            when ready => 
                req_out <= '0';
                r_out <= data_reg; -- expose the result to the first-place requester
                
        end case;       
    end process;

end arch;

-- the cases should have been considered all, 
-- consider doing the simulation to check the exact behavior