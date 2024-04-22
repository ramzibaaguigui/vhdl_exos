library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity talker is 
    port (
        op_a, op_b: in std_logic_vector(7 downto 0);
        start: in std_logic;
        clk, reset: in std_logic;
        ack_in: in std_logic;
        req_out: out std_logic;
        data_inout: inout std_logic_vector (15 downto 0);
        ttl_granted, ltt_granted: in std_logic;
        result: out std_logic_vector(15 downto 0);
        is_ready: out std_logic
    );
end talker;

architecture arch of talker is 
    type state_type is (idle, requesting, getting, ready);
    signal state_reg, state_next: state_type;
    
    signal r_reg, r_next: std_logic_vector(15 downto 0);
    alias ru_reg,: std_logic_vector(7 downto 0) is r_reg(15 downto 8);
    alias ru_next,: std_logic_vector(7 downto 0) is r_next(15 downto 8);
    alias rl_reg: std_logic_vector(7 downto 0) is r_reg(7 downto 0);
    alias rl_next: std_logic_vector(7 downto 0) is r_next(7 downto 0);

    
    signal data_in, signal data_out: std_logic_vector(15 downto 0);
    signal en_data_in, en_data_out: std_logic;

    signal req_out_buf, req_out_next: std_logic;

begin

    -- infer as registers
    process(clk, reset)
    begin
        if reset = '1' then 
            -- reset all to default value
            req_out_buf <= '0';
            r_reg <= (others => '0');
            state_reg <= idle;
        elsif
            req_out_buf <= req_out_next;
            r_reg <= r_next;
            state_reg <= state_next;
        end if;
    end process;

    -- next state, routing and other staff
    process(state_reg, start, op_a, op_b)
    begin
        -- values by default
        state_next <= state_reg; 
        r_next <= r_reg;
        is_ready <= '0';
        case state_reg is 
            when idle => 
                -- when sensing the start signal: 
                -- get the data in and go to the requesting state
                if start = '1' then 
                    -- get the data in
                    rl_next <= op_a;
                    ru_next <= op_b;
                    state_next <= requesting;
                end if;

            when requesting => 
                -- do later: determine the output, here or in another place
            
                -- wait for the ack signal
                if ack_in = '1' then
                    -- put the register content on the bus
                    state_next <= getting;

                end if;

            when getting => 
                -- the next state logic and output for the waiting state
                -- no logic here, the next state will be ready 
                state_next <= ready; 
                -- recover the results to the internal registers
                r_next <= data_in; -- the port should be configured in the input mode
            
            when ready => 
                -- the next state logic and output for the waiting state
                -- expose the result to the outer world
                is_ready <= '1';

        end case;
    end process;

    -- configuring the data_inout to function in both modes (input and output) exclusively
    -- the output is always exposing the content of the register if enabled
    
    data_inout <= data_out when en_data_out = '1' else (others => 'Z');
    data_in <= data_inout when en_data_in = '1' else (others => 'Z');

    en_data_in <= ltt_granted;  -- from the listener to the talker
    en_data_out <= ttl_granted; -- from the talker to the listener

    -- expose the content of the r register to both the outputs either from the listener side
    -- or the from the side that initiated the request to the talker in the first place
    data_out <= r_reg;
    result <= r_reg;

    -- look-ahead output buffer for the request signal
    process(state_next) 
    begin
        req_out_next <= '0';
        case state_next is 
            when idle => 
                req_out_next <= '0';
            when requesting =>  
                req_out_next <= '1';
            when getting =>
                req_out_next <= '1'; -- todo: consider retaking a look on this to confirm the value
            when ready => 
                req_out_next <= '0';
        end case;
    end process;

end;

