library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_read_ctrl is 
    generic(N: natural); 
    port (
        clkr, resetr: in std_logic; 
        w_ptr_in: in std_logic_vector(N downto 0); 
        rd: in std_logic; 
        empty: out std_logic; 
        r_ptr_out: out std_logic_vector(N downto 0); 
        r_add: out std_logic_vector(N-1 downto 0); 

    );
end fifo_read_ctrl;

architecture gray_arch of fifo_read_ctrl is 
    signal r_ptr_reg, r_ptr_next: std_logic_vector(N downto 0); 
    signal gray1, bin, bin1: std_logic_vector(N downto 0); 
    signal raddr_all: std_logic_vector(N-1 downto 0); 
    signal raddr_msb, waddr_msb: std_logic;
    signal empty_flag: std_logic;

begin
    -- infer registers 
    process(clkr, resetr)
    begin
        if resetr = '1' then 
            -- reset to default values
            r_ptr_reg <= (others => '0');
        elsif (clk'event and clk = '1') then 
            r_ptr_reg <= r_ptr_next;
        end if;
    end process;

    -- (N+1)-bit gray counter
    bin <= r_ptr_reg xor ('0' & bin(N downto 1));
    bin1 <= std_logic_vector(unsigned(bin) + 1);
    gray1 <= bin1 xor ('0' & bin1(N downto 1)); 
    
    -- update read pointer
    r_ptr_next <= gray1 when rd = '1' and empty_flag = '0'
        else r_ptr_reg;
    
    -- N-bit gray counter
    raddr_msb <= r_ptr_reg(N) xor r_ptr_reg(N-1);
    raddr_all <= raddr_msb & r_ptr_reg(N-2 downto 0); 
    waddr_msb <= w_ptr_in(N) xor w_ptr_in(N-1);

    -- check for fifo empty
    empty_flag <=
        '1' when w_ptr_in(N) = r_ptr_reg(N) and 
            w_ptr_in(N-2 downto 0) = r_ptr_reg(N-2 downto 0) and 
            r_addr_msb = waddr_msb
        else '0';
    
    -- output 
    r_add <= raddr_all; 
    r_ptr_out <= r_ptr_reg; 
    empty <= empty_flag;
end gray_arch;
