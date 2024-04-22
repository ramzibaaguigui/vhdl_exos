library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Exercise 15.17:
-- The register file of Section 15.4.5 has one read port. We want to revise the design
-- so that the number of read ports can be specified by a parameter. To achieve this, the read
-- ports need to be grouped as a single output with a two-dimensional data type. Use the
-- std-logic-2d data type and derive the VHDL code.

 entity reg_file_para is 
    generic (
        WIDTH: natural;
        B: natural;
        PORT_COUNT: natural
    );
    port (
        clk, reset: in std_logic;
        wr_en: in std_logic;
        w_data: in std_logic_vector (B-1 downto 0);
        w_addr: in std_logic_vector(WIDTH-1 downto 0);
        r_addr: in array(PORT_COUNT-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
        r_data: out array(PORT_COUNT-1 downto 0) of std_logic_vector(B-1 downto 0)
    );

end reg_file_para;

architecture Behavioral of reg_file_para is 
    type reg_file_type is array(2**WIDTH-1 downto 0) of std_logic_vector(B-1 downto 0);
    signal array_reg: reg_file_type;
    signal array_next: reg_file_type;
begin
    -- register array
    process(clk, reset) 
    begin
        if (reset = '1') then 
            array_reg <= (others => (others => '0'));
        elsif(clk'event and clk='1') then 
            array_reg <= array_next;
        end if;
    end process;

    -- next state logic for register array
    process(array_reg, wr_en, w_addr, w_data) 
    begin
        array_next <= array_reg;
        if (wr_en = '1') then 
            array_next(to_integer(unsigned(w_addr))) <= w_data;
        end if;
    end process;

    -- associating address ports to data out ports
    port_gen:
    for i in (PORT_COUNT-1) downto 0 generate
        r_data(i) <= array_reg(to_integer(unsigned(r_addr(i))));
    end generate;
end Behavioral;

-- we turn this into a parametrized desgin from the reading side
-- Nothing changes concerning the write logic
-- There are many things to change from the reading logic side
-- we start by turning the type of the r_addr input into an array of address vectors
-- the same thing is done from the output side
-- Finally, we link the address input ports to the output ports using the for generate block
-- and we are done
-- the exercise proposed to the use the std_logic_2d data type
-- to keep the changes MINIMAL, we use the array of std_logic_vector data type
-- WE SHOULD BE DONE WITH THIS EXERCISE

