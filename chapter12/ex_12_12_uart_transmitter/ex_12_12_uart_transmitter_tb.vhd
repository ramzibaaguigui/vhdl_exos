library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_transmitter_tb is
end uart_transmitter_tb;

architecture tb_arch of uart_transmitter_tb is
    -- Constants
    constant CLK_PERIOD: time := 10 ns;

    -- Signals
    signal clk_tb     : std_logic := '0';
    signal reset_tb   : std_logic := '0';
    signal d_in_tb    : std_logic_vector(7 downto 0) := (others => '0');
    signal en_in_tb   : std_logic := '0';
    signal start_tb   : std_logic := '0';
    signal y_tb       : std_logic;
    signal ready_tb   : std_logic;

    -- Component instantiation
    component uart_transmitter
        port(
            clk, reset: in std_logic;
            d_in: in std_logic_vector(7 downto 0);
            en_in: in std_logic;
            start: in std_logic;
            y: out std_logic;
            ready: out std_logic
        );
    end component;

begin
    -- Clock process
    process
    begin
        while now < 1000 ns loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_proc: process
    begin
        -- Reset
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for 10 ns;

        -- Send data
        en_in_tb <= '1';
        start_tb <= '1';
        d_in_tb <= "10101010";
        wait for 100 ns;

        -- Additional tests can be added here

        wait;
    end process stimulus_proc;

    -- Instantiate the uart_transmitter
    uut: uart_transmitter
        port map(
            clk => clk_tb,
            reset => reset_tb,
            d_in => d_in_tb,
            en_in => en_in_tb,
            start => start_tb,
            y => y_tb,
            ready => ready_tb
        );

end tb_arch;
