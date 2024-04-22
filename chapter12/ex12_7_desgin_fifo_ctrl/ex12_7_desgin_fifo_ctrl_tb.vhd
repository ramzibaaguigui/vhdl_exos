library IEEE;
use IEEE.std_logic_1164.all;

entity sram_ctrl_tb is
end sram_ctrl_tb;

architecture testbench of sram_ctrl_tb is
    -- Component declaration for the DUT (Design Under Test)
    component sram_ctrl
        port (
            d: inout std_logic;
            reset, clk: in std_logic;
            rd, wr: in std_logic;
            data_m2s: in std_logic;
            we, oe: out std_logic;
            ready: out std_logic;
            data_s2m: out std_logic;
            ad: out std_logic_vector(19 downto 0);
            full, empty: out std_logic
        );
    end component;

    -- Signals for testbench
    signal tb_clk: std_logic := '0';
    signal tb_reset: std_logic := '0';
    signal tb_rd, tb_wr: std_logic;
    signal tb_data_m2s: std_logic;
    signal tb_ready, tb_data_s2m: std_logic;
    signal tb_d: std_logic;
    signal tb_we, tb_oe: std_logic;
    signal tb_ad: std_logic_vector(19 downto 0);
    signal tb_full, tb_empty: std_logic;

begin

    -- Instantiate the DUT
    DUT: sram_ctrl
        port map (
            d => tb_d,
            reset => tb_reset,
            clk => tb_clk,
            rd => tb_rd,
            wr => tb_wr,
            data_m2s => tb_data_m2s,
            we => tb_we,
            oe => tb_oe,
            ready => tb_ready,
            data_s2m => tb_data_s2m,
            ad => tb_ad,
            full => tb_full,
            empty => tb_empty
        );

    -- Clock process
    tb_clk_process: process
    begin
        wait for 5 ns;
        tb_clk <= not tb_clk;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Initialize inputs
        tb_reset <= '1';
        tb_rd <= '0';
        tb_wr <= '0';
        tb_data_m2s <= '0';
        wait for 10 ns;
        tb_reset <= '0';
        wait for 10 ns;

        -- Example test sequence
        tb_rd <= '1';  -- Read operation
        wait for 10 ns;
        tb_wr <= '1';  -- Write operation
        tb_data_m2s <= '1';  -- Sample data
        wait for 10 ns;
        tb_wr <= '0';  -- Stop write operation
        wait for 10 ns;

        -- Add more test sequences as needed

        wait;
    end process;

end testbench;
