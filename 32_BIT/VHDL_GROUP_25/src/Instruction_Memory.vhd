library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================
-- Instruction_Memory — 32-bit MIPS, Task 4 instructions
--
-- Register mapping (per spec: regs 1,3,5,7 are $t0..$t3):
--   $t0 = reg 1  (binary 00001)
--   $t1 = reg 3  (binary 00011)
--   $t2 = reg 5  (binary 00101)
--   $t3 = reg 7  (binary 00111)
--
-- R-format: op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
--
-- Word 0 (byte addr 0x00): add $t0, $t1, $t2
--   rs=$t1=00011  rt=$t2=00101  rd=$t0=00001  funct=100000
--   => 0x00650820
--
-- Word 1 (byte addr 0x04): sub $t2, $t2, $t3
--   rs=$t2=00101  rt=$t3=00111  rd=$t2=00101  funct=100010
--   => 0x00A72822
--
-- Word 2 (byte addr 0x08): and $t1, $t2, $t0
--   rs=$t2=00101  rt=$t0=00001  rd=$t1=00011  funct=100100
--   => 0x00A11824
--
-- Word 3 (byte addr 0x0C): or $t2, $t3, $t1
--   rs=$t3=00111  rt=$t1=00011  rd=$t2=00101  funct=100101
--   => 0x00E32825
-- ============================================================

entity Instruction_Memory is
    Port ( address     : in  STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
    type instr_mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    constant instr_memory : instr_mem_type := (
        0 => x"00650820",  -- add $t0, $t1, $t2   (addr 0x00)
        1 => x"00A72822",  -- sub $t2, $t2, $t3   (addr 0x04)
        2 => x"00A11824",  -- and $t1, $t2, $t0   (addr 0x08)
        3 => x"00E32825",  -- or  $t2, $t3, $t1   (addr 0x0C)
        others => x"00000000"
    );
begin
    -- Byte addressing: divide address by 4 to get word index
    instruction <= instr_memory(to_integer(unsigned(address(9 downto 2))));
end Behavioral;
