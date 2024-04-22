library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- This will bundle the syncronous talker
-- and provide the necessary interfacing syncronizers

entity talker_async is 
    port (
        clk, reset: in std_logic;
        
    );
end talker_async;