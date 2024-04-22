library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparator is
    generic(
        N: natural
    );
    port(
    read_ptr, write_ptr: in std_logic_vector(N downto 0);
    y: out std_logic
); end comparator;

architecture empty_arch of comparator is
    begin
        y <= '1' when read_ptr = write_ptr else '0';
    end empty_arch;

architecture full_arch of comparator is
    begin
        y <= '1' when read_ptr(N) /= write_ptr(N) and
                      read_ptr(N-1 downto 0) = write_ptr(N-1 downto 0)
            else '0';
    end full_arch;

entity n_plus_one_binary_counter is
    generic (
        N: natural
    );
    port (
        clk, reset: in std_logic;
        en: in std_logic;
        q_out: std_logic_vector(N downto 0)
    );
end n_plus_one_binary_counter;

architecture Behavioral of n_plus_one_binary_counter is 
        signal r_reg, r_next: unsigned(N downto 0);

        process(clk, reset) 
            begin
                if (reset = '1') then
                    -- reset to default value
                    r_reg <= (others => '0');
                elsif (clk'event and clk = '1') then
                    r_reg <= r_next;
                end if;
            end process;
        
        process(en, r_reg)
            begin
                if (en = '1') then
                    next_r <= r_reg + 1;
                else
                    next_r <= r_reg;
                end if;
            end;
    end architecture;

-- Based on the diagram in figure 9.14,
-- we get the VHDL code for the entire circuit
entity fifo_controller is 
    port(
        clk, reset: in std_logic;
        rd, wr: in std_logic;
        full, empty: out std_logic
    );
end fifo_controller;

architecture Behavioral of fifo_controller is 
        constant N: integer := 3;
        signal w_ptr_out, r_ptr_out: std_logic_vector(N downto 0);
        alias w_addr: std_logic_vector(N-1 downto 0) is w_ptr_out(N-1 downto 0);
        alias r_addr: std_logic_vector(N-1 downto 0) is r_ptr_out(N-1 downto 0);
        begin
            -- the comparison unit on the left
            counter_left: entity work.n_plus_one_binary_counter(Behavioral)
                generic map(N => N)
                port map(clk => clk, reset => reset, en => wr);

            counter_right: entity work.n_plus_one_binary_counter(Behavioral)
                generic map(N => N) 
                port map(clk => clk, reset => reset, en => rd);
            
            full_comp_unit: entity work.comparator(full_arch)
                generic map(N => N)
                port map (read_ptr => r_ptr_out, write_ptr => w_ptr_out, y => full);
            
            empty_comp_unit: entity work.comparator(empty_arch)
                generic map(N => N)
                port map(read_ptr => r_ptr_out, write_ptr => w_ptr_out, y => empty);
            
            
    end Behavioral;

    -- we should be done with Ex 12.5