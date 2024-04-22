library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- integrate the entire system 
entity fifo_async_control is 
    generic (DEPTH: natural);
    port(
        clkw, resetw: in std_logic; 
        wr: in std_logic; 
        full: out std_logic; 
        w_addr: out std_logic_vector(DEPTH-1 downto 0); 
        clkr, resetr: in std_logic; 
        rd: in std_logic; 
        empty: out std_logic; 
        r_addr: out std_logic_vector(DEPTH-1 downto 0)
    );
end fifo_async_control;

architecture str_arch of fifo_async_control is 
    signal r_ptr_in: std_logic_vector(DEPTH downto 0); 
    signal r_ptr_out: std_logic_vector(DEPTH downto 0); 
    signal w_ptr_in: std_logic_vector(DEPTH downto 0); 
    signal w_ptr_out: std_logic_vector(DEPTH downto 0); 

begin

    -- READ CONTROL 
    read_ctrl: fifo_read_ctrl(gray_arch)
        generic map (N => DEPTH)
        port map (
            clkr => clkr, resetr => resetr, rd => rd, 
            w_ptr_in => w_ptr_in, empty => empty, 
            r_ptr_out => r_ptr_out, r_addr => r_addr
        );
    
    -- WRITE CONTROL 
    write_ctrl: fifo_write_ctrl(gray_arch)
        generic map (N => DEPTH) 
        port map(
            clkw => clkw, resetw => resetw, wr => wr, 
            r_ptr_in => r_ptr_in, full => full, 
            w_ptr_out => w_ptr_out, w_addr => w_addr
        );

    -- write SYNCRONIZER 
    sync_w_ptr: syncronizer_g(two_ff_arch)
        generic map (
            N => DEPTH + 1
        )
        port map(
            clkw => clkw, resetw => resetw, 
            in_async => w_ptr_out, out_sync => w_ptr_in
        );

    -- read SYNCRONIZER
    sync_r_ptr: syncronizer_g(two_ff_arch)
        generic map (
            N => DEPTH + 1
        )
        port map(
            clkr => clkr, resetr => resetr, 
            in_async => r_ptr_out, out_sync => w_ptr_in
        );
end str_arch;

-- this is the entire design
