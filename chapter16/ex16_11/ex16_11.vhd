library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ex 10.11
-- 16.11 We want to design a four-phase handshaking asynchronous interface for the sequential
-- multiplier in Section 11.6. 
-- (1) The operand width is 8 bits,  and 
-- (2) The data is passed by a 16-bit bidirectional bus.
--  After sensing the start signal:
--  the talker of the sending subsystem places the data on the data bus and
--  activates the handshaking operation.
--  Once the receiving subsystem detects the request:
--  it retrieves the data and performs the multiplication operation.
--  When the operation is completed,
--  the listener of the receiving subsystem places the result on the data bus and
--  asserts the acknowledge signal, and the talker retrieves the
-- result accordingly. 
-- Draw the block diagram and derive VHDL code for this system

-- The block diagram contains all the interacting entities alongside the
-- the order of the operations taking place

-- DONE with drawing the block diagram
-- (1) the listener puts the data on the data bus
-- (2) assert the req signal 
-- (3) the listener senses the req signal, recovers the data in, performs the multiplication
-- (4) put the result of multiplicatoin on the data bus
-- (5) assert the ack signal (to inform the talker that the operation is done, and that the data 
--     can be recovered from the bus)
