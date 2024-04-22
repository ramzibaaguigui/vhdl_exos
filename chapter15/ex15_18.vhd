library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The operation of a stack was discussed in Problem 9.1 1. Follow the design procedure
-- dure in Section 15.4.5 to derive VHDL code for a parameterized stack

-- the stack can have many parameters
-- (1) the word size in bits
-- (2) the address size in bits
-- (3) address order generation

entity stack_param is 
    generic (
        W: natural; -- width of the address port
        B: natural  -- width of the data word
    );
    port (
        clk, reset: in std_logic;
        rd, wr: in std_logic; -- command signals
        data_in: in std_logic_vector(B-1 downto 0); -- data to write port
        data_out: out std_logic_vector(B-1 downto 0); -- read data port
        full, empty: out std_logic; -- status signals
    );
end stack_param;

architecture Behavioral of stack_param is
    type reg_file is array(2**W-1 downto 0) of std_logic_vector(B-1 downto 0);
    
    signal array_reg, array_next: reg_file;
    
    signal is_full_reg, is_full_next: std_logic;
    signal is_empty_reg, is_empty_next: std_logic;

    signal r_addr_reg, r_addr_next: std_logic_vector(W-1 downto 0);
    signal w_addr_reg, r_addr_next: std_logic_vector(W-1 downto 0);

    -- these values will be calculated according to the selected mode
    signal r_addr_next_up, r_addr_next_down: std_logic_vector(W-1 downto 0);
    signal w_addr_next_up, r_addr_next_down: std_logic_vector(W-1 downto 0);

    -- the value could be changed later to accomodate the needs=
    constant FIRST_ADDRESS: std_logic_vector(W-1 downto 0) := (others => '0'); 

    -- the value could be changed later to accomodate the needs
    constant LAST_ADDRESS: std_logic_vector(W-1 downto 0) := (others => '1');

begin

    -- regsiters and register file
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            is_empty_reg <= '1';
            is_full_reg <= '0';
            array_reg <= (others => (others => '0'));
            r_addr_reg <= (others => '0');
            w_addr_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            is_empty_reg <= is_empty_next;
            is_full_reg <= is_full_next;
            array_reg <= array_next;
            r_addr_reg <= r_addr_next;
            w_addr_reg <= w_addr_next;
        end if;
    end process;

    -- we need to have some information about the accurate timing of stack memories
    -- what to get the data in and when to get the data out
    -- in addition to many other aspects
    -- that should all be taken into consideration
    -- we consider that the word pointed by r_addr_reg is always exposed to the outer environment, SO:
    -- the data_out is a replication of the word that is currently pointed by the r_addr_reg


    -- exposing the word pointed by the r_addr_reg
    data_out <= array_reg(to_integer(unsigned(r_addr_reg)));

    -- calculating the next addresses up and down for the read and write
    r_addr_next_up <= std_logic_vector(unsigned(r_addr_reg) + 1);
    r_addr_next_down <= std_logic_vector(unsigned(r_addr_reg) -1);

    w_addr_next_up <= std_logic_vector(unsigned(w_addr_reg) + 1);
    w_addr_next_down <= std_logic_vector(unsigned(w_addr_reg) - 1);
    
    
    -- next values for the internal registers
    process(rd, wr, data_in)
    begin
        r_addr_next <= r_addr_reg;
        w_addr_next <= r_addr_reg;
        array_next <= array_reg;
        is_empty_next <= is_empty_reg;
        is_full_next <= is_full_reg;

        -- in case we have a read operation
        if (rd = '1' and is_empty_reg /= '1') then 
            -- this means that the read is successful, do all the necessary updates
            is_full_next <= '0';
            -- next read address 
            -- decrement the address only if the next status is not empty
            if (to_integer(unsigned(r_addr_reg)) /= FIRST_ADDRESS) then
                r_addr_next <= r_addr_down;
            else
                is_empty_next <= '1'
            end if;

            -- next write address
            -- decrement the WRITE address only if the current status is not full
            if (is_full_reg /= '1') then
                w_addr_next <= w_addr_next_down;
            end if;

        elsif (wr = '1' and is_full_reg /= '1') then 
            -- WRITE SUCCESSFUL, no longer empty
            is_empty_next <= '0';

            -- pass the data in to the register file
            array_next(to_integer(unsigned(w_addr_reg))) <= data_in;
            -- next write address
            if (w_addr_reg /= LAST_ADDRESS) then
                w_addr_next <= w_addr_next_up;
            else
                is_full_next <= '1';
            end if;
            
            -- next read address
            -- if the stack is not currently empty, then increase the read address as well
            if (is_empty_reg /= '1') then 
                r_addr_next <= r_addr_next_up;
            end if;

            -- next status signals
        end if;

    end process;

    -- status signals
    full <= is_full_reg;
    empty <= is_empty_reg;

end Behavioral;


-- Overall, this is how to think about the stack memory
-- The control signals are there to control pop and push operations
-- Note that the word pointed by r_addr_reg is always exposed on the data_out port
-- If we want to read the top of the stack, it is already there on the data_out port
-- SIGNAL (rd) will be asserted only when we want to discard the content of that word
-- and pass the reading address to the lower part






-- NOW THAT WE HAVE COMPLETED THE FIRST STEPS, WE CAN FURTHER CONSIDER THE MORE
-- PARAMETRIZED VERSION OF THE STACK, WHERE THE COUNTING MODE WILL BE INTRODUCED AS A GENERIC AS WELL
-- GO TO THE NEXT FILE to see the result