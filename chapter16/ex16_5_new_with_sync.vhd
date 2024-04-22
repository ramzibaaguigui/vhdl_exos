library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- it is going to be almost the same thing for the last sync design except some slight
-- changes in the interfacing, where we will consider the pulse output as well

entity talker_str is 
    port (
        clkt, resett: in std_logic;
        ack_in: in std_logic;
        start: in std_logic;
        req_out: out std_logic;
        ready: out std_logic
    );
end talker_str;

architecture str_arch of talker_str is 
    signal ack_sync: std_logic;
begin
    component syncronizer
        port (
            clk, reset: in std_logic;
            in_async: in std_logic;
            out_sync: out std_logic;
        );
    end component;

    sync_unit: syncronizer
        port map(
            clk => clkt, reset => resett, in_async => ack_in, out_sync => ack_sync
        )

    fsm_unit: entity work.talker_fsm(arch)
        port map(
            clk => clkt,
            reset => resett,
            ack_sync => ack_sync,
            req_out => req_out,
            start => start,
            ready => ready
        );
end str_arch;

-- we are with the design of the talkder with syncronizer
-- now is the time to consider the listener with syncronizer

entity str_listener is 
    port (
        clkt, resett: in std_logic;
        req_in: in std_logic;
        ack_out: out std_logic;
        pulse_out: out std_logic
    );
end str_listener;

architecture str_arch of str_listener is 
    signal req_sync:  std_logic;
begin
    component syncronizer 
        port (
            clk, reset: in std_logic;
            in_async: in std_logic;
            out_sync: out std_logic
        );
    end component;
    sync_unit: syncronizer
        port map(
            clk => clkt, 
            reset => resett,
            in_async => req_in, 
            out_sync => req_sync
        );

    fsm_unit: entity work.listener_fsm(arch)
        port map(
            clk => clkt,
            reset => resett,
            req_sync => req_sync, 
            ack_out => ack_out,

            -- this is the line to add in order to consider
            -- the pulse signal as a global output
            pulse_out => pulse_out;
        );
end str_arch;
