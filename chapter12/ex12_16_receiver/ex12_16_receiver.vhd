-- Problem statement for this exercise:
-- Consider a UART that can communicate at four baud rates: 1200, 2400, 4800
-- and 9600 baud. Assume that the actual baud rate is unknown but the transmitter always
-- sends a "11111111" data byte at the beginning of the session. Design a circuit that can
-- automatically determine the baud rate and derive the VHDL code.

-- ===============================
-- this is the design of a UART that can automatically detect the
-- baud rate at which the sender is operating
-- ///////////////////////////////////////////
-- we use the same principle as before
-- first we edit the design so that the configuration signals becomes stored internally
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_receiver is port(
    clk, reset: in std_logic;
    rx: in std_logic;
    ready: out std_logic;
    pout: out std_logic_vector(7 downto 0)
); end uart_receiver;

architecture arch of uart_receiver is 
    type state_type is (idle, start, data, stop, config);
    signal state_reg, state_next: state_type;
    signal clk16_next, clk16_reg: unsigned(5 downto 0);
    signal s_reg, s_next: unsigned(3 downto 0);
    signal n_reg, n_next: unsigned(2 downto 0);
    signal b_reg, b_next: std_logic_vector(7 downto 0);
    signal s_pulse: std_logic;
    
    -- this register will be used to store the current baud rate
    -- 00 for 1200 -- 01 for 2400
    -- 10 for 4800 -- 11 for 9600
    signal dvsr_reg, dvsr_next: unsigned(5 downto 0);
    signal conf_done_reg, conf_done_next: std_logic;
    signal c_reg, c_next: unsigned(9 downto 0);
    constant DVSR_1200: integer := 52;
    constant DVSR_2400: integer := 26;
    constant DVSR_4800: integer := 13;
    constant DVSR_9600: integer := 7;

    constant CLK_9600: integer := 156;
    constant CLK_4800: integer := 312;
    constant CLK_2400: integer := 624;
    

    -- the exercise states that the configuration will be done at the beginning
    -- of the session, which means that we need a register to record whether the
    -- configuration has bee done previously or not

    begin
        -- free running mod-52 counter, 
        -- independent of FSMD
        process(clk, reset)
            begin
                if (reset = '1') then
                    clk16_reg <= (others => '0');
                elsif (clk'event and clk = '1') then
                    clk16_reg <= clk16_next;
                end if;
            end process;
            
            -- next state output logic
            clk16_next <= (others => '0') when clk16_reg = (dvsr_reg - 1)
                        else clk16_reg + 1;
            s_pulse <= '1' when clk16_reg = 0 else '0';

            -- state and data registers
    
            process(clk, reset)
                begin
                    if (reset = '1') then
                        -- reset to default states
                        state_reg <= idle;
                        s_reg <= (others => '0');
                        n_reg <= (others => '0');
                        b_reg <= (others => '0');
                        c_reg <= (others => '0');
                        -- reset the configation to default state
                        conf_done_reg <= '0';
                    elsif (clk'event and clk = '1') then
                        state_reg <= state_next;
                        s_reg <= s_next;
                        n_reg <= n_next;
                        b_reg <= b_next;
                        c_reg <= c_next;
                        conf_done_reg <= conf_done_next;
                    end if;
                end process;
            
            
            -- next state logic & data path functional units
            process(state_reg, s_reg, n_reg, b_reg, s_pulse, rx)
                begin
                    s_next <= s_reg;
                    n_next <= n_reg;
                    b_next <= b_reg;
                    c_next <= c_reg;
                    conf_done_next <= conf_done_reg;
                    ready <= '0';

                    case state_reg is
                        when idle =>
                            if (rx = '0') then
                                if (conf_done_reg = '1') then
                                    -- the config is already done, go to start
                                    state_next <= start;
                                else
                                    state_next <= config;
                                    c_next <= (others => '0');
                                end if;
                            else
                                state_nxet <= idle;
                            end if;
                            ready <= '1';
                        
                            when config =>
                                -- count the number of clock cycles or sampling instants
                                -- for the which the rx is zero
                                if (s_pulse = '0') then -- still not the time
                                    state_next <= config;

                                else
                                    if (rx = '0') then -- rx is still zero
                                        c_next <= c_reg + 1;
                                    else
                                        -- the rx is no longer zero
                                        -- this is the time we should 
                                        -- sample the configuration
                                        -- the s_reg contains the number 
                                        -- of instants counted from the beginning
                                        -- of the config state
                                        -- based on the s_reg, we define the config
                                        if (s_reg < CLK_9600) then -- 9600 baud rate
                                            dvsr_next <= DVSR_9600;
                                        elsif (s_reg < CLK_4800) then -- 4800 baud rate
                                            dvsr_next <= DVSR_4800;
                                        elsif (s_reg < CLK_2400) then -- 2400 baud rate
                                            dvsr_next <= DVSR_2400;
                                        else
                                            dvsr_next <= DVSR_1200;
                                        end if;
                                        c_next <= (others => '0');
                                        s_reg <= 7;
                                        state_next <= data;
                                        -- in the data state, the config
                                        -- is confirmed only if the the received data is all 1's
                                    end if;
                        
                        when start => 
                            if (s_pulse = '0') then 
                                state_next <= start;
                            else
                                if (s_reg = 7) then
                                    state_next <= data;
                                    s_next <= (others => '0');
                                else
                                    state_next <= start;
                                    s_next <= s_reg + 1;
                                end if;
                            end if;
                        
                        when data =>
                            if (s_pulse = '0') then
                                state_next <= data;
                            else
                                if (s_reg = 15) then
                                    s_next <= (others => '0');
                                    b_next <= rx & b_reg (7 downto 1);
                                    if (n_reg = 7) then
                                        state_next <= stop;
                                        n_next <= (others => '0');
                                    else
                                        state_next <= data;
                                        n_next <= n_reg + 1;
                                    end if;
                                else
                                    state_next <= data;
                                    s_next <= s_reg + 1;
                                end if;
                            end if;
                        
                        when stop =>
                            if (s_pulse = '0') then
                                state_next <= stop;
                            else
                                if (s_reg = 15) then
                                    state_next <= idle;
                                    s_next <= (others => '0');

                                    -- if the received data is all ones
                                    -- and the receiver is not configured previously
                                    -- confirm the configuration
                                    if (b_reg = "11111111" and not conf_done_reg) then
                                        conf_done_next <= '1';
                                    else
                                        conf_done_next <= '0';
                                    end if;
                                else
                                    state_next <= stop;
                                    s_next <= s_reg + 1;
                                end if;
                            end if;
                    end case;
                end process;
                -- OUTPUT LOGIC
                pout <= b_reg;
    end arch;
-- Problem statement for this exercise:
-- Consider a UART that can communicate at four baud rates: 1200, 2400, 4800
-- and 9600 baud. Assume that the actual baud rate is unknown but the transmitter always
-- sends a "11111111" data byte at the beginning of the session. Design a circuit that can
-- automatically determine the baud rate and derive the VHDL code.
-- ================================================================

-- we should be all done with the exercises concerning the UART
