library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Write_Back is
    Port ( read_data : in STD_LOGIC_VECTOR (31 downto 0);
           alu_result : in STD_LOGIC_VECTOR (31 downto 0);
           write_reg : in STD_LOGIC_VECTOR (4 downto 0);
           mem_to_reg : in STD_LOGIC;
           reg_write_in : in STD_LOGIC;
           write_data : out STD_LOGIC_VECTOR (31 downto 0);
           write_reg_out : out STD_LOGIC_VECTOR (4 downto 0);
           reg_write_out : out STD_LOGIC);
end Write_Back;

architecture Behavioral of Write_Back is
begin
    write_data <= read_data when mem_to_reg = '1' else alu_result;
    write_reg_out <= write_reg;
    reg_write_out <= reg_write_in;
end Behavioral;
