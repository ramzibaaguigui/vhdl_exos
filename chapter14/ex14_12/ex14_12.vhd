library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 14.12 Consider the reduced-and code of Listing 14.28. Follow the conceptual implementation
-- procedure discussed in Section 14.8.3 to replace the exit statement with flag
-- signals.
-- (a) Derive the VHDL code.
-- (b) Draw the conceptual diagram.
-- (c) Prove that the conceptual diagram actually performs the reduced-and operation

-- THIS IS THE CODE OF THE LISTING 14.28:
entity reduced_and is
    generic (
        WIDTH: natural
    );
    port (
        a: in std_logic_vector(WIDTH-1 downto 0);
        y: out std_logic
    );
end reduced_and;

architecture exit_arch of reduced_and is
begin  
    process(a)
        variable tmp: std_logic;
    begin
        tmp := '1';
        for i in 0 to WIDTH-1 loop
            if a(i) = '0' then
                tmp := '0';
                exit;
            end if;
        end loop;
        y <= tmp;
    end process;

end exit_arch;

architecture flag_arch of reduced_and is
    signal bypass: std_logic_vector(WIDTH downto 0);

begin
    process(a, bypass) 
        variable result: std_logic;
    begin
        result := '1';
        bypass(WIDTH) = '0';

        for i in WIDTH-1 downto 0 loop
            if a(i) = '1' then
                bypass(i) <= '1';
            else 
                bypass(i) <= bypass(i+1);
            end if;
        end loop;

        for i in WIDTH-1 downto 0 loop
            if bypass(i) = '0' then 
                if a(i) = '0' then 
                    result := '0';
                end if;
            end if;
        end loop;
        y <= result;
    end process;
end flag_arch;

-- following the same style of the references example,
-- the code should be correct
-- Even though we can do it much simpler, the goal of the exercise is to 
-- to introduce this method of thinking

