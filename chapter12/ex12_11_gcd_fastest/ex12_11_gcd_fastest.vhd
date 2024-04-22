-- in this exercise, we will consider the fastest architecture of the GCD
-- what makes this architecture unique is that the shifting op happens at once if the number of trailing 
-- zeros is greater than one
-- another poing to consider is that the barrel shifter is so complex, that it 
-- is better to use it in a time-multiplexed manner
-- we will figure how to do it

--- we will start with the pseudo-algorithm to solve the problem:
--- begin: if (start = 1) then
---            a <= a_in
---            b <= b_in
---            n <= 0
---            a_zero <= 0
---            b_zero <= 0
---            goto check 
---        else
---            goto begin 
--- 
--- we check against all the possible patters of a and b
--- check: if (a = b) then
---            if (n = 0) then
---                goto begin
---            else
---                goto res
---        else
---            -- if a /= b
---            -- start with a
---            if (a is even) then
---                a <= shift(a, count_trailing_zeros(a))
---                a_zeros <= count_trailing_zeros(a)
---                 
---            else if (b is even) then
---                
--- here is the proposed VHDL code without unit-multiplexing

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gcd is port (
    clk, reset: in std_logic;
    start: in std_logic;
    a_in, b_in: in std_logic_vector(7 downto 0);
    ready: out std_logic;
    r: out std_logic_vector(7 downto 0) 
); end gcd;

-- done with the entity declaration
architecture fastest_arch of gcd is 
    type state_type is (idle, swap, sub, res);
    signal state_reg, state_next: state_type;
    signal a_reg, a_next, b_reg, b_next: unsigned(7 downto 0);
    signal n_reg, n_next, a_zero, b_zero: unsigned(7 downto 0);
begin
    -- data and status registers
    process(clk, reset)
        begin
            if reset = '1' then
                state_reg <= idle;
                a_reg <= (others => '0');
                b_reg <= (others => '0');
                n_reg <= (others => '0');
            elsif (clk'event and clk = '1') then -- rising edge of clk
                state_reg <= state_next;
                a_reg <= a_next;
                b_reg <= b_next;
                n_reg <= n_next;
            end if;
        end process;
    -- next state logic, datapath function units / routing
    process(state_reg, a_reg, b_reg, n_reg, start, a_in, b_in, a_zero, b_zero)
        begin
            -- default outputs
            a_next <= a_reg;
            b_next <= b_reg;
            n_next <= n_reg; 
            a_zero <= (others => '0');
            b_zero <= (others => '0');

            case state_reg is 
                when idle => 
                    if (start = '1') then
                        state_next <= swap;
                        a_next <= a_in;
                        b_next <= b_in;
                        n_next <= (others => '0');
                
                when swap => 
                    if (a_reg = b_reg) then 
                        if (n_reg = 0) then
                            state_next <= idle;
                        else
                            state_next <= res;
                        end if
                    else 
                        if (a_reg(0) = '1' and b_reg(0) = '1') then
                            if (a < b) then
                                a_next <= b_reg;
                                b_next <= a_reg;
                            end if;
                            state_next <= sub;
                        else
                            -- let a_count be the signal that counts the number of trailing zeros in a_reg
                            
        end process;
