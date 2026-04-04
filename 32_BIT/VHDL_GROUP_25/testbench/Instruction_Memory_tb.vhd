library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================
-- Task 4: Required instructions (32-bit MIPS R-format)
--   Registers used: 1=$t0, 3=$t1, 5=$t2, 7=$t3 (per spec)
--
--   R-format layout: op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
--
--   Address 0: add $t0, $t1, $t2
--     op=000000 rs=00011($t1) rt=00101($t2) rd=00001($t0) shamt=00000 funct=100000
--     = 0000 0000 0110 0101 0000 1000 0010 0000 = 0x00650820
--
--   Address 4 (word 1): sub $t2, $t2, $t3
--     op=000000 rs=00101($t2) rt=00111($t3) rd=00101($t2) shamt=00000 funct=100010
--     = 0000 0000 1010 0111 0010 1000 0010 0010 = 0x00A72822
--
--   Address 8 (word 2): and $t1, $t2, $t0
--     op=000000 rs=00101($t2) rt=00001($t0) rd=00011($t1) shamt=00000 funct=100100
--     = 0000 0000 1010 0001 0001 1000 0010 0100 = 0x00A11824
--
--   Address 12 (word 3): or $t2, $t3, $t1
--     op=000000 rs=00111($t3) rt=00011($t1) rd=00101($t2) shamt=00000 funct=100101
--     = 0000 0000 1110 0011 0010 1000 0010 0101 = 0x00E32825
-- ============================================================

entity Instruction_Memory_tb is
end Instruction_Memory_tb;

architecture Behavioral of Instruction_Memory_tb is
    component Instruction_Memory
        Port ( address     : in  STD_LOGIC_VECTOR (31 downto 0);
               instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal address     : STD_LOGIC_VECTOR (31 downto 0);
    signal instruction : STD_LOGIC_VECTOR (31 downto 0);

    -- Expected instruction encodings (see derivation above)
    constant INSTR_ADD : STD_LOGIC_VECTOR(31 downto 0) := x"00650820"; -- add $t0,$t1,$t2
    constant INSTR_SUB : STD_LOGIC_VECTOR(31 downto 0) := x"00A72822"; -- sub $t2,$t2,$t3
    constant INSTR_AND : STD_LOGIC_VECTOR(31 downto 0) := x"00A11824"; -- and $t1,$t2,$t0
    constant INSTR_OR  : STD_LOGIC_VECTOR(31 downto 0) := x"00E32825"; -- or  $t2,$t3,$t1

begin
    UUT: Instruction_Memory port map (
        address     => address,
        instruction => instruction
    );

    stim: process
    begin
        -- ----------------------------------------------------------------
        -- Task 4(i)/(ii): Read the four required instructions
        -- Note: Instruction_Memory uses byte addressing.
        --       address[9:2] selects the word, so word 0 = byte addr 0,
        --       word 1 = byte addr 4, word 2 = byte addr 8, word 3 = byte addr 12.
        -- ----------------------------------------------------------------

        -- Address 0: add $t0, $t1, $t2
        address <= x"00000000";
        wait for 10 ns;
        assert instruction = INSTR_ADD
            report "FAIL Task4: Address 0 expected ADD $t0,$t1,$t2 (0x00650820)" severity error;
        report "PASS Task4: Address 0 = add $t0, $t1, $t2" severity note;

        -- Address 4 (word 1): sub $t2, $t2, $t3
        address <= x"00000004";
        wait for 10 ns;
        assert instruction = INSTR_SUB
            report "FAIL Task4: Address 4 expected SUB $t2,$t2,$t3 (0x00A72822)" severity error;
        report "PASS Task4: Address 4 = sub $t2, $t2, $t3" severity note;

        -- Address 8 (word 2): and $t1, $t2, $t0
        address <= x"00000008";
        wait for 10 ns;
        assert instruction = INSTR_AND
            report "FAIL Task4: Address 8 expected AND $t1,$t2,$t0 (0x00A11824)" severity error;
        report "PASS Task4: Address 8 = and $t1, $t2, $t0" severity note;

        -- Address 12 (word 3): or $t2, $t3, $t1
        address <= x"0000000C";
        wait for 10 ns;
        assert instruction = INSTR_OR
            report "FAIL Task4: Address 12 expected OR $t2,$t3,$t1 (0x00E32825)" severity error;
        report "PASS Task4: Address 12 = or $t2, $t3, $t1" severity note;

        -- ----------------------------------------------------------------
        -- Verify out-of-range address returns NOP (0x00000000)
        -- ----------------------------------------------------------------
        address <= x"00000064";
        wait for 10 ns;
        assert instruction = x"00000000"
            report "FAIL: Out-of-range address should return 0x00000000" severity error;
        report "PASS: Out-of-range address returns NOP (0x00000000)" severity note;

        report "Instruction_Memory testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;
