library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- the above package contains the util functions needed
use work.util.all;
-- this is the code for the param encodern in Section 15.3.4
entity binary_encoder is 
    generic(N: nautral);
    port (
        a: in std_logic_vector(N-1 downto 0);
        bcode: out std_logic_vector(log2c(N)-1 downto 0)
    );
end binary_encoder;

architecture arch of binary_encoder is
    
 
    type mask_2d_type is array(log2c(N) - 1 downto 0) of 
        std_logic_vector(N-1 downto 0);
    signal mask: mask_2d_type;

    function gen_or_mask return mask_2d_type is
        variable or_mask: mask_2d_type;
    begin
        for i in (log2c(N)-1) downto 0 loop
            for k in (N-1) downto 0 loop
                if (k/(2**i) mod 2 = 1) then
                    or_mask(i)(k) := '1';
                else
                    or_mask(i)(k) := '0';
                end if;
            end loop;
        end loop;
        return or_mask;
    end function;

begin 
   
    mask <= gen_2d_mask;
    process(mask, a)
    begin
    
    end process;
end architecture arch;