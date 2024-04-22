library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The operation and design of a CAM was discussed in Section 9.3.3. Follow the
-- design procedure in Section 15.4.5 to derive VHDL code for a parameterized CAM


entity encoder_param is 
    generic(
        WIDTH_OUTPUT: natural
    );
    port (
        code_in: in std_logic_vector(2**WIDTH_INPUT-1 downto 0);
        code_out: out std_logic_vector(WIDTH_INPUT-1 downto 0)
    );
end encoder_param;

architecture arch of encoder_param is

begin
    -- the logic of the encoder goes here, 
    -- in most cases, we create a base decoder unit and expand it dynamically in 
    -- a tree like structure with generics
end arch;

-- let's first consider rewriting the code that has been written there
-- and then see what can be parametrized

entity key_file is 
    generic (
        WIDTH_ADDRESS: natural;
        WIDTH_KEY: natural
    );
    port (        
        clk, reset: in std_logic;
        wr_en: in std_logic;

        -- key_in: in std_logic_vector(15 downto 0);
        key_in: in std_logic_vector(WIDTH_KEY-1 downto 0);

        hit: out std_logic;

        -- addr_out: out std_logic_vector(1 downto 0);
        addr_out: out std_logic_vector(WIDTH_ADDRESS-1 downto 0);

    );
end key_file;

architecture arch of key_file is 
    constant WORD: natural := 2;
    constant BIT: natural := 16;
    type reg_file_type is array(2**WIDTH_ADDRESS-1 downto 0) of std_logic_vector(WIDTH_KEY-1 downto 0);

    signal array_reg: reg_file_type;
    signal array_next: reg_file_type;
    signal en: in std_logic_vector(2**WIDHT_ADDRESS-1 downto 0); -- one hot
    signal match: out std_logic_vector(2**WIDTH_ADDRESS-1 downto 0); -- one hot 
    
    signal rep_reg, rep_next: unsigned(WIDTH_ADDRESS-1 downto 0); -- replacement register
    signal addr_match: std_logic_vector(WIDTH_ADDRESS-1 downto 0); -- the address of the match
    
    signal wr_key, hit_flag: std_logic;
    constant ZERO_ALL: std_logic_vector(2**WIDTH_ADDRESS-1 downto 0);

begin
    -- registers
    -- process(clk, reset)
    -- begin
    --     if (reset = '1') then 
    --         for i in 3 downto 0 loop 
    --             array_reg(i) <= (others => '0');
    --         end loop;
    --     elsif(clk'event and clk = '1') then 
    --         for in in 3 downto 0 loop 
    --             array_reg(i) <= array_next(i);
    --         end loop;
    --     end if;
    -- end process;
    
    -- We change the above to a simple process
    process(clk, reset)
    begin
        if (reset = '1') then
            array_reg <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then 
            array_reg <= array_next;
        end if;
    end process;

    -- enable logic for registers
    -- if the enable signal is asserted for a certain address
    -- then its next value should take the key in
    process(array_reg, en, key_in) 
    begin
        -- default values for next
        -- for i in 3 downto 0 loop
        --     array_next(i) <= array_reg(i);
        -- end loop;

        -- for i in 3 downto 0 loop
        --     if (en(i) = '1') then 
        --         array_next(i) <= key_in;
        --     end if;
        -- end loop;
        array_next <= array_reg;
        for i in (2**WIDTH_ADDRESS-1 downto 0) loop
            if (en(i) = '1') then 
                array_next(i) <= key_in;
            end if;
        end loop;
    end process;

    -- decoding for write address 
    wr_key <= '1' when (wr_en = '1' and hit_flag = '0') else '0';

    process(wr_key, rep_reg) 
    begin
        if (wr_key = '0') then 
            en <= (others => '0');
        else
            -- case rep_reg is
            --     when "00" => en <= "0001";
            --     when "01" => en <= "0010";
            --     when "10" => en <= "0100";
            --     when others => en <= "1000";
            -- end case; 
            
            -- make it behavioral
            -- we could have the choice to create a decoder
            -- and configure its inputs and outputs according to the needs
            -- but in this case, we will use a behavioral description
            -- it becomes the responsibility of the synthesis tool to dervie 
            -- the component from the component library
            en <= (to_integer(rep_reg) => '1', others => '0')
        end if;
    end process;


    -- replacement pointer
    process(clk, reset)
    begin
        if (reset = '1') then 
            rep_reg <= (others => '0');
        elsif (clk'event and clk='1') then 
            rep_reg <= rep_next;
        end if;
    end process;

    rep_next <= rep_reg + 1 when wr_key = '1' else rep_reg;

    -- key comparison
    process(array_reg, key_in) 
    begin
        match <= (others => '0');
        for i in (2**WIDTH_ADDRESS-1) downto 0 loop
            if (key_in = array_reg(i)) then
                match(i) <= '1';
            end if;
        end loop;
    end process;

    -- encoding 
    -- with match select
    --         addr_match <= "00" when "0001",
    --                       "01" when "0010",
    --                       "10" when "0100",
    --                       "11" when others;
    -- an alternative design decision is to create an instance of an encoder and wire
    -- its input to match, and its output to addr_match
    encoder_instance: entity work.encoder_param
                generic map(
                    WIDTH_OUTPUT => WIDHT_ADDRESS
                )
                port map(
                    code_in => match,
                    code_out => addr_match;
                );

    -- hit flag
    hit_flag <= '1' when match /= ZERO_ALL else '0';

    -- output 
    hit <= hit_flag;
    addr_out <= addr_match when (hit_flag = '1') else 
                std_logic_vector(rep_reg);
end arch;

-- int the first place, we need to discuss all the generic to be supported by this CAM
-- the first two that are obvious is:
-- (1) B: width of the key
-- (2) W: width of the address (log2(word count in CAM))

-- the design is fully parametrized, so we are done