library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Fetch is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pc_in : in STD_LOGIC_VECTOR (31 downto 0);
           pc_out : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end Instruction_Fetch;

architecture Behavioral of Instruction_Fetch is
signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
type instr_mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
constant instr_mem : instr_mem_type := (
    0 => x"20080005", -- addi $t0, $zero, 5
    1 => x"2009000A", -- addi $t1, $zero, 10
    2 => x"01095020", -- add $t2, $t0, $t1
    3 => x"AD0A0000", -- sw $t2, 0($t0)
    4 => x"8D0B0000", -- lw $t3, 0($t0)
    others => x"00000000"
);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= pc_in;
        end if;
    end process;
    pc_out <= pc;
    instruction <= instr_mem(to_integer(unsigned(pc(9 downto 2))));
end Behavioral;