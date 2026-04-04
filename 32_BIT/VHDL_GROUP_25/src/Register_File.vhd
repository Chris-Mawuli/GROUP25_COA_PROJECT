library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           rs : in STD_LOGIC_VECTOR (4 downto 0);
           rt : in STD_LOGIC_VECTOR (4 downto 0);
           write_reg : in STD_LOGIC_VECTOR (4 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           reg_write : in STD_LOGIC;
           read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
           read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
end Register_File;

architecture Behavioral of Register_File is
type reg_file_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal registers : reg_file_type := (others => (others => '0'));
begin
    -- Read ports (asynchronous)
    read_data1 <= registers(to_integer(unsigned(rs)));
    read_data2 <= registers(to_integer(unsigned(rt)));

    -- Write port (synchronous)
    process(clk, reset)
    begin
        if reset = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = '1' and to_integer(unsigned(write_reg)) /= 0 then
                registers(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;
end Behavioral;
