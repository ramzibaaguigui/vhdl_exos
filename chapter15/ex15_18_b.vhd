library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The operation of a stack was discussed in Problem 9.1 1. Follow the design procedure
-- dure in Section 15.4.5 to derive VHDL code for a parameterized stack

-- the stack can have many parameters
-- (1) the word size in bits
-- (2) the address size in bits
-- (3) address order generation

-- all the utils that we need will be included here



entity stack_param is 
    generic (
        W: natural; -- width of the address port
        B: natural; -- width of the data word
        USE_LFSR: natural -- 1 => use LFSR counter, other => use binary counter (INCREMENT-DECREMENT based)
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
    
    
    -- the value could be changed later to accomodate the needs=
    constant FIRST_ADDRESS: std_logic_vector(W-1 downto 0) := (others => '0'); 
    -- the value could be changed later to accomodate the needs
    constant LAST_ADDRESS: std_logic_vector(W-1 downto 0) := (others => '1');
    constant FIRST_PATTERN: std_logic_vector(W-1 downto 0) := generateFirstPatternForWidth(WIDTH);
    constant LAST_PATTER: std_logic_vector(W-1 downto 0):= generateLastPatternForWidth(WIDTH);
    
    
    signal array_reg, array_next: reg_file;
    
    signal is_full_reg, is_full_next: std_logic;
    signal is_empty_reg, is_empty_next: std_logic;

    signal r_addr_reg, r_addr_next: std_logic_vector(W-1 downto 0);
    signal w_addr_reg, r_addr_next: std_logic_vector(W-1 downto 0);

    -- these values will be calculated according to the selected mode
    signal r_addr_next_up, r_addr_next_down: std_logic_vector(W-1 downto 0);
    signal w_addr_next_up, r_addr_next_down: std_logic_vector(W-1 downto 0);

    signal addr_first: std_logic_vector(W-1 downto 0);
    signal addr_last: std_logic_vector(W-1 downto 0);

    function generateMaskForWidth(index: natural) return std_logic_vector(N-1 downto 0) is 
        constant MASK_ARRAY: tap_array_type := 
        (
            2 => (1|0=>'1', others => '0'),
            3 => (1|0=>'1', others => '0'),
            4 => (1|0=>'1', others => '0'),
            5 => (2|0=>'1', others => '0'),
            6 => (1|0=>'1', others => '0'),
            7 => (3|0=>'1', others => '0'),
            8 => (4|3|2|0=>'1', others => '0')
        ); 
        variable result: std_logic_vector(N-1 downto 0);
    begin
        -- we suppose that the user gives a N withing the range of the allowed values
        result := MASK_ARRAY(index)(W-1 downto 0);
        return result;
    end function;

    -- functions:
    function generateNextPatternUp(current: std_logic_vector(W-1 downto 0)) return std_logic_vector(W-1 downto 0) is
        variable mask, qualified: std_logic_vector(W-1 downto 0);
        variable tmp: std_logic;
    begin
        mask := generateMaskForWidth(W);
        qualified := current and mask;
        tmp := '0';
        for i in 0 to W-1 loop
            tmp := tmp xor qualified(i);
        end loop;
        return tmp;
    end function;

    function generateNextPatternDown(current: std_logic_vector(W-1 downto 0)) return std_logic_vector(W-1 downto 0) is
        variable mask_tmp, mask, qualified: std_logic_vector(W-1 downto 0);
        variable tmp: std_logic;
    
    begin
        
        mask_tmp := generateMaskForWidth(W);
        mask := mask_tmp(0) & mask_tmp(W-1 downto 1);
        qualified := mask and current;

        tmp := '0';
        for i in 0 to W-1 loop
            tmp := tmp xor qualified(i);
        end loop;
        return (current(W-2 downto 0) & tmp);
    end function;
begin

    -- Fixing the vlaues for the first and the last addresses or patterns
    LFSR_GEN:
    if (USE_LFSR = 1) generate
        addr_first <= FIRST_PATTERN;
        addr_last <= LAST_PATTERN;
         -- calculating the next addresses up and down for the read and write
        r_addr_next_up   <= generateNextPatternUp(r_addr_reg);
        r_addr_next_down <= generateNextPatternDown(r_addr_reg);

        w_addr_next_up   <= generateNextPatternUp(w_addr_reg);
        w_addr_next_down <= generateNextPatternDown(w_addr_reg);
    
    end generate;

    NON_LFSR_GEN:
    if (USE_LFSR /= 1) generate
        addr_first <= FIRST_ADDRESS;
        addr_last  <= LAST_ADDRESS;

        r_addr_next_up   <= std_logic_vector(unsigned(r_addr_reg) + 1);
        r_addr_next_down <= std_logic_vector(unsigned(r_addr_reg) - 1);
        w_addr_next_up   <= std_logic_vector(unsigned(w_addr_reg) + 1);
        w_addr_next_down <= std_logic_vector(unsigned(w_addr_reg) - 1);
    end generate;

    -- regsiters and register file
    process(clk, reset) 
    begin
        if (reset = '1') then 
            -- reset all to default
            is_empty_reg <= '1';
            is_full_reg <= '0';
            array_reg <= (others => (others => '0'));
            r_addr_reg <= addr_first;
            w_addr_reg <= addr_first;
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
            if (to_integer(unsigned(r_addr_reg)) /= addr_first) then
                r_addr_next <= r_addr_next_down;
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
            if (w_addr_reg /= addr_last) then
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


-- the changes that we made should be enough to support LFSR mode and non-LFSR mode
-- that is all
-- consider fixing values for the constants that you have used 
-- MAKE SURE TO KEEP THE DESIGN AS DESCRIPTIVE AS POSSIBLE
-- Some best practices should be respected here as well
-- keep it up

-- there might be some details that we did not consider here, but overall,
-- it is all clear


