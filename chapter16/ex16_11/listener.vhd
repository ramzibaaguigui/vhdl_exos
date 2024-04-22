library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this file will contain the listener
-- the coming requests to this listener are supposed to be in the same clock domain

entity listener is 
    port (
        clk, reset: in std_logic;
        req_sync: in std_logic;
        ack_out: out std_logic;
        
    )