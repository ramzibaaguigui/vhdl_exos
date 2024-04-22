library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bus_arbiter is 
    port (
        req_in, ack_in: in std_logic;
        
        -- ltt signifies listener to talker
        -- ttl signifies talker to listener
        ltt_granted, ttl_granted: out std_logic
    );
end bus_arbiter;

architecture arch of bus_arbiter is 
    
begin
    -- the talker to listener path is given priority
    -- for the req ack signals, we have four possible states
    --   ACK  --|--  REQ  --|-- bus direction       : -- |
    --    0   --|--   0   --|--     disconnted           |
    --    0   --|--   1   --|--     talker to listener   |
    --    1   --|--   1   --|--     listener to talker   |
    --    1   --|--   0   --|--     disconnted           |
    ltt_granted <= ack_in and req_in;
    ttl_granted <= '1' when (req_in = '1' and ack_in = '0') else '0';
end arch;