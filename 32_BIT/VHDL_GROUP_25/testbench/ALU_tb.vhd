library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_tb is
end ALU_tb;

architecture Behavioral of ALU_tb is
    component ALU
        Port ( operand1    : in  STD_LOGIC_VECTOR (31 downto 0);
               operand2    : in  STD_LOGIC_VECTOR (31 downto 0);
               alu_control : in  STD_LOGIC_VECTOR (3 downto 0);
               result      : out STD_LOGIC_VECTOR (31 downto 0);
               zero        : out STD_LOGIC);
    end component;

    signal operand1    : STD_LOGIC_VECTOR (31 downto 0);
    signal operand2    : STD_LOGIC_VECTOR (31 downto 0);
    signal alu_control : STD_LOGIC_VECTOR (3 downto 0);
    signal result      : STD_LOGIC_VECTOR (31 downto 0);
    signal zero        : STD_LOGIC;

    -- ALU control codes (matching ALU.vhd)
    -- "0000" = AND
    -- "0001" = OR
    -- "0010" = ADD
    -- "0110" = SUB
    -- "0111" = SLT (set less than)

begin
    UUT: ALU port map (
        operand1    => operand1,
        operand2    => operand2,
        alu_control => alu_control,
        result      => result,
        zero        => zero
    );

    stim: process
    begin
        -- ----------------------------------------------------------------
        -- Task 2(i): ADD 2500 + 25000 = 27500
        --   2500  = 0x000009C4
        --   25000 = 0x000061A8
        --   27500 = 0x00006B6C
        -- ----------------------------------------------------------------
        operand1    <= x"000009C4";
        operand2    <= x"000061A8";
        alu_control <= "0010";
        wait for 10 ns;
        assert result = x"00006B6C"
            report "FAIL Task2(i): ADD 2500 + 25000 expected 27500" severity error;
        report "PASS Task2(i): ADD 2500 + 25000 = 27500" severity note;

        -- ----------------------------------------------------------------
        -- Task 2(ii): SUB 540250 - 37800 = 502450
        --   540250 = 0x0008401A
        --   37800  = 0x000093A8
        --   502450 = 0x0007AC72
        -- ----------------------------------------------------------------
        operand1    <= x"0008401A";
        operand2    <= x"000093A8";
        alu_control <= "0110";
        wait for 10 ns;
        assert result = x"0007AC72"
            report "FAIL Task2(ii): SUB 540250 - 37800 expected 502450" severity error;
        assert zero = '0'
            report "FAIL Task2(ii): zero flag should be 0" severity error;
        report "PASS Task2(ii): SUB 540250 - 37800 = 502450" severity note;

        -- ----------------------------------------------------------------
        -- Task 2(iii): AND 53957 & 30000
        --   53957  = 0x0000D2C5
        --   30000  = 0x00007530
        --   Result = 0x0000D2C5 & 0x00007530 = 0x00005000
        -- ----------------------------------------------------------------
        operand1    <= x"0000D2C5";
        operand2    <= x"00007530";
        alu_control <= "0000";
        wait for 10 ns;
        assert result = x"00005000"
            report "FAIL Task2(iii): AND 53957 & 30000 expected 0x00005000 (20480)" severity error;
        report "PASS Task2(iii): AND 53957 & 30000 = 20480" severity note;

        -- ----------------------------------------------------------------
        -- Task 2(iv): OR 746353 | 846465
        --   746353 = 0x000B6331
        --   846465 = 0x000CE901
        --   Result = 0x000BEB31 | extras ... let us compute:
        --   0x000B6331 | 0x000CE901 = 0x000DEB31
        -- ----------------------------------------------------------------
        operand1    <= x"000B6331";
        operand2    <= x"000CE901";
        alu_control <= "0001";
        wait for 10 ns;
        assert result = x"000DEB31"
            report "FAIL Task2(iv): OR 746353 | 846465 expected 0x000DEB31 (912177)" severity error;
        report "PASS Task2(iv): OR 746353 | 846465 = 912177" severity note;

        -- ----------------------------------------------------------------
        -- Task 2(v): Compare (SLT) 58847537 vs 72464383
        --   58847537 = 0x03826931  -> less than 72464383
        --   72464383 = 0x04504DFF
        --   R[rs] < R[rt] => result = 1
        -- ----------------------------------------------------------------
        operand1    <= x"03826931";
        operand2    <= x"04504DFF";
        alu_control <= "0111";
        wait for 10 ns;
        assert result = x"00000001"
            report "FAIL Task2(v): SLT 58847537 < 72464383 expected 1" severity error;
        report "PASS Task2(v): SLT 58847537 < 72464383 = 1" severity note;

        -- ----------------------------------------------------------------
        -- Extra: SUB resulting in zero (zero flag test)
        --   10 - 10 = 0
        -- ----------------------------------------------------------------
        operand1    <= x"0000000A";
        operand2    <= x"0000000A";
        alu_control <= "0110";
        wait for 10 ns;
        assert result = x"00000000"
            report "FAIL: SUB 10-10 expected 0" severity error;
        assert zero = '1'
            report "FAIL: zero flag should be 1 when result=0" severity error;
        report "PASS: zero flag correctly set when SUB result = 0" severity note;

        report "ALU testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;
