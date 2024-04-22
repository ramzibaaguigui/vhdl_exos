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
            mem, rw: in std_logic;
            addr: in std_logic_vector(19 downto 0);
            data_m2s: in std_logic;
            we, oe: out std_logic;
            ready: out std_logic;
            data_s2m: out std_logic;
            ad: out std_logic_vector(19 downto 0)
        );
    end component;

    -- Signals for testbench
    signal tb_clk: std_logic := '0';
    signal tb_reset: std_logic := '0';
    signal tb_mem, tb_rw: std_logic;
    signal tb_addr: std_logic_vector(19 downto 0);
    signal tb_data_m2s: std_logic;
    signal tb_ready, tb_data_s2m: std_logic;
    signal tb_d: std_logic;
    signal tb_we, tb_oe: std_logic;
    signal tb_ad: std_logic_vector(19 downto 0);

begin

    -- Instantiate the DUT
    DUT: sram_ctrl
        port map (
            d => tb_d,
            reset => tb_reset,
            clk => tb_clk,
            mem => tb_mem,
            rw => tb_rw,
            addr => tb_addr,
            data_m2s => tb_data_m2s,
            we => tb_we,
            oe => tb_oe,
            ready => tb_ready,
            data_s2m => tb_data_s2m,
            ad => tb_ad
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
        tb_mem <= '0';
        tb_rw <= '0';
        tb_addr <= (others => '0');
        tb_data_m2s <= '0';
        wait for 10 ns;
        tb_reset <= '0';
        wait for 10 ns;

        -- Example test sequence
        tb_mem <= '1';  -- Enable memory
        tb_rw <= '0';   -- Write operation
        tb_addr <= "00000000000000000101";  -- Sample address
        tb_data_m2s <= '1';  -- Sample data
        wait for 10 ns;
        tb_mem <= '1';  -- Enable memory
        tb_rw <= '1';   -- Read operation
        tb_addr <= "00000000000000000101";  -- Sample address
        wait for 10 ns;

        -- Add more test sequences as needed

        wait;
    end process;

end testbench;
