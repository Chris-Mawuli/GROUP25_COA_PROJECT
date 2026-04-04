library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit_tb is
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is
    component Control_Unit
        Port ( opcode : in STD_LOGIC_VECTOR (5 downto 0);
               funct : in STD_LOGIC_VECTOR (5 downto 0);
               alu_op : out STD_LOGIC_VECTOR (1 downto 0);
               reg_dst : out STD_LOGIC;
               alu_src : out STD_LOGIC;
               mem_read : out STD_LOGIC;
               mem_write : out STD_LOGIC;
               mem_to_reg : out STD_LOGIC;
               branch : out STD_LOGIC;
               jump : out STD_LOGIC;
               jr : out STD_LOGIC;
               jal : out STD_LOGIC;
               reg_write : out STD_LOGIC);
    end component;

    signal opcode, funct : STD_LOGIC_VECTOR (5 downto 0);
    signal alu_op : STD_LOGIC_VECTOR (1 downto 0);
    signal reg_dst, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, jr, jal, reg_write : STD_LOGIC;
begin
    UUT: Control_Unit port map (opcode, funct, alu_op, reg_dst, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, jr, jal, reg_write);

    process
    begin
        -- Test R-type ADD (opcode=000000, funct=100000)
        opcode <= "000000";
        funct <= "100000";
        wait for 10 ns;
        assert reg_dst = '1' and alu_src = '0' and alu_op = "10" and reg_write = '1' 
            report "R-type ADD control failed" severity error;
        assert mem_read = '0' and mem_write = '0' and branch = '0' and jump = '0'
            report "R-type ADD memory/branch control failed" severity error;

        -- Test R-type JR (opcode=000000, funct=001000)
        opcode <= "000000";
        funct <= "001000";
        wait for 10 ns;
        assert jump = '1' and jr = '1' and reg_write = '0'
            report "R-type JR control failed" severity error;

        -- Test ADDI (opcode=001000)
        opcode <= "001000";
        funct <= "000000";
        wait for 10 ns;
        assert reg_dst = '0' and alu_src = '1' and alu_op = "00" and reg_write = '1'
            report "ADDI control failed" severity error;

        -- Test SLTI (opcode=001010)
        opcode <= "001010";
        funct <= "000000";
        wait for 10 ns;
        assert alu_op = "10" and reg_write = '1' and alu_src = '1'
            report "SLTI control failed" severity error;

        -- Test LW (opcode=100011)
        opcode <= "100011";
        funct <= "000000";
        wait for 10 ns;
        assert reg_dst = '0' and alu_src = '1' and mem_read = '1' and mem_to_reg = '1' and reg_write = '1'
            report "LW control failed" severity error;

        -- Test SW (opcode=101011)
        opcode <= "101011";
        funct <= "000000";
        wait for 10 ns;
        assert alu_src = '1' and mem_write = '1' and reg_write = '0'
            report "SW control failed" severity error;

        -- Test BEQ (opcode=000100)
        opcode <= "000100";
        funct <= "000000";
        wait for 10 ns;
        assert alu_op = "01" and branch = '1' and alu_src = '0' and reg_write = '0'
            report "BEQ control failed" severity error;

        -- Test J (opcode=000010)
        opcode <= "000010";
        funct <= "000000";
        wait for 10 ns;
        assert jump = '1' and reg_write = '0' and jr = '0'
            report "J control failed" severity error;

        -- Test JAL (opcode=000011)
        opcode <= "000011";
        funct <= "000000";
        wait for 10 ns;
        assert jump = '1' and jal = '1' and reg_write = '1'
            report "JAL control failed" severity error;

        report "Control_Unit testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;
