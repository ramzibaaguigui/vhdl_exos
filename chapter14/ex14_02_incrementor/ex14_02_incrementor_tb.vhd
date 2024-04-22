library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity incrementor_tb is
end incrementor_tb;

architecture tb_arch of incrementor_tb is
    -- Constants
    constant WIDTH: natural := 4; -- Set the width for testing

    -- Signals
    signal cin_tb   : std_logic := '0';
    signal a_tb     : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal s_tb     : std_logic_vector(WIDTH-1 downto 0);
    signal cout_tb  : std_logic;

    -- Component instantiation
    component incrementor
        generic(
            WIDTH: natural
        );
        port(
            cin: in std_logic;
            a: in std_logic_vector(WIDTH-1 downto 0);
            s: out std_logic_vector(WIDTH-1 downto 0);
            cout: out std_logic
        );
    end component;

begin
    -- Instantiate the incrementor
    uut: incrementor
        generic map(
            WIDTH => WIDTH
        )
        port map(
            cin => cin_tb,
            a => a_tb,
            s => s_tb,
            cout => cout_tb
        );

    -- Stimulus process
    stimulus_proc: process
    begin
        -- Test 1: All zeroes, cin = 0
        a_tb <= (others => '0');
        cin_tb <= '0';
        wait for 10 ns;

        -- Test 2: All ones, cin = 0
        a_tb <= (others => '1');
        cin_tb <= '0';
        wait for 10 ns;

        -- Test 3: Alternating bits, cin = 1
        a_tb <= "1010";
        cin_tb <= '1';
        wait for 10 ns;

        -- Additional tests can be added as required

        wait;
    end process stimulus_proc;

end tb_arch;
