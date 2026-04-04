library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Data_Memory is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR (31 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           mem_read : in STD_LOGIC;
           mem_write : in STD_LOGIC;
           read_data : out STD_LOGIC_VECTOR (31 downto 0));
end Data_Memory;

architecture Behavioral of Data_Memory is
type data_mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
signal data_memory : data_mem_type := (others => (others => '0'));
begin
    -- Read port (asynchronous)
    read_data <= data_memory(to_integer(unsigned(address(9 downto 2)))) when mem_read = '1' else x"00000000";

    -- Write port (synchronous)
    process(clk, reset)
    begin
        if reset = '1' then
            data_memory <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if mem_write = '1' then
                data_memory(to_integer(unsigned(address(9 downto 2)))) <= write_data;
            end if;
        end if;
    end process;
end Behavioral;
