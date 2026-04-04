library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Access is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           alu_result : in STD_LOGIC_VECTOR (31 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           write_reg : in STD_LOGIC_VECTOR (4 downto 0);
           mem_read : in STD_LOGIC;
           mem_write : in STD_LOGIC;
           mem_to_reg : in STD_LOGIC;
           branch : in STD_LOGIC;
           reg_write_in : in STD_LOGIC;
           read_data : out STD_LOGIC_VECTOR (31 downto 0);
           alu_result_out : out STD_LOGIC_VECTOR (31 downto 0);
           write_reg_out : out STD_LOGIC_VECTOR (4 downto 0);
           mem_to_reg_out : out STD_LOGIC;
           reg_write_out : out STD_LOGIC);
end Memory_Access;

architecture Behavioral of Memory_Access is
type data_mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
signal data_mem : data_mem_type := (others => (others => '0'));
begin
    -- Data memory read/write
    process(clk, reset)
    begin
        if reset = '1' then
            data_mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if mem_write = '1' then
                data_mem(to_integer(unsigned(alu_result(9 downto 2)))) <= write_data;
            end if;
        end if;
    end process;

    read_data <= data_mem(to_integer(unsigned(alu_result(9 downto 2)))) when mem_read = '1' else x"00000000";

    -- Outputs
    alu_result_out <= alu_result;
    write_reg_out <= write_reg;
    mem_to_reg_out <= mem_to_reg;
    reg_write_out <= reg_write_in;
end Behavioral;
