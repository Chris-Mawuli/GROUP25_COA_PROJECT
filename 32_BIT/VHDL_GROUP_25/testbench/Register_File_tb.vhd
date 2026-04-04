library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File_tb is
end Register_File_tb;

architecture Behavioral of Register_File_tb is
    component Register_File
        Port ( clk        : in  STD_LOGIC;
               reset      : in  STD_LOGIC;
               rs         : in  STD_LOGIC_VECTOR (4 downto 0);
               rt         : in  STD_LOGIC_VECTOR (4 downto 0);
               write_reg  : in  STD_LOGIC_VECTOR (4 downto 0);
               write_data : in  STD_LOGIC_VECTOR (31 downto 0);
               reg_write  : in  STD_LOGIC;
               read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
               read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal rs         : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal rt         : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal write_reg  : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal write_data : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal reg_write  : STD_LOGIC := '0';
    signal read_data1 : STD_LOGIC_VECTOR (31 downto 0);
    signal read_data2 : STD_LOGIC_VECTOR (31 downto 0);

    -- Task 3 required values
    -- Register 1: 1934858  = 0x001D8D0A
    -- Register 3: 8558447  = 0x0082A16F
    -- Register 5: 203848544= 0x0C24EF60
    -- Register 7: 20670420 = 0x013B4794
    constant VAL_REG1 : STD_LOGIC_VECTOR(31 downto 0) := x"001D8D0A"; -- 1934858
    constant VAL_REG3 : STD_LOGIC_VECTOR(31 downto 0) := x"0082A16F"; -- 8558447
    constant VAL_REG5 : STD_LOGIC_VECTOR(31 downto 0) := x"0C24EF60"; -- 203848544
    constant VAL_REG7 : STD_LOGIC_VECTOR(31 downto 0) := x"013B4794"; -- 20670420

begin
    UUT: Register_File port map (
        clk        => clk,
        reset      => reset,
        rs         => rs,
        rt         => rt,
        write_reg  => write_reg,
        write_data => write_data,
        reg_write  => reg_write,
        read_data1 => read_data1,
        read_data2 => read_data2
    );

    -- Clock: 20 ns period
    clk_process: process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process;

    stim: process
    begin
        -- ----------------------------------------------------------------
        -- Reset
        -- ----------------------------------------------------------------
        reset     <= '1';
        reg_write <= '0';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        -- ----------------------------------------------------------------
        -- Task 3(i): Write required values into registers 1, 3, 5, 7
        -- ----------------------------------------------------------------

        -- Write 1934858 into Register 1
        write_reg  <= "00001";
        write_data <= VAL_REG1;
        reg_write  <= '1';
        wait for 20 ns;
        report "Wrote 1934858 into Register 1" severity note;

        -- Write 8558447 into Register 3
        write_reg  <= "00011";
        write_data <= VAL_REG3;
        wait for 20 ns;
        report "Wrote 8558447 into Register 3" severity note;

        -- Write 203848544 into Register 5
        write_reg  <= "00101";
        write_data <= VAL_REG5;
        wait for 20 ns;
        report "Wrote 203848544 into Register 5" severity note;

        -- Write 20670420 into Register 7
        write_reg  <= "00111";
        write_data <= VAL_REG7;
        wait for 20 ns;
        report "Wrote 20670420 into Register 7" severity note;

        -- Stop writing
        reg_write <= '0';
        wait for 10 ns;

        -- ----------------------------------------------------------------
        -- Task 3(ii): Read back all four registers and verify
        -- ----------------------------------------------------------------

        -- Read Register 1 and Register 3 simultaneously
        rs <= "00001";
        rt <= "00011";
        wait for 10 ns;
        assert read_data1 = VAL_REG1
            report "FAIL Task3(ii): Register 1 expected 1934858 (0x001D8D0A)" severity error;
        assert read_data2 = VAL_REG3
            report "FAIL Task3(ii): Register 3 expected 8558447 (0x0082A16F)" severity error;
        report "PASS Task3(ii): Register 1 = 1934858, Register 3 = 8558447" severity note;

        -- Read Register 5 and Register 7 simultaneously
        rs <= "00101";
        rt <= "00111";
        wait for 10 ns;
        assert read_data1 = VAL_REG5
            report "FAIL Task3(ii): Register 5 expected 203848544 (0x0C24EF60)" severity error;
        assert read_data2 = VAL_REG7
            report "FAIL Task3(ii): Register 7 expected 20670420 (0x013B4794)" severity error;
        report "PASS Task3(ii): Register 5 = 203848544, Register 7 = 20670420" severity note;

        -- ----------------------------------------------------------------
        -- Extra: $zero protection — writing to register 0 must have no effect
        -- ----------------------------------------------------------------
        write_reg  <= "00000";
        write_data <= x"FFFFFFFF";
        reg_write  <= '1';
        wait for 20 ns;

        reg_write <= '0';
        rs        <= "00000";
        wait for 10 ns;
        assert read_data1 = x"00000000"
            report "FAIL: $zero protection failed — register 0 should always read 0" severity error;
        report "PASS: $zero register correctly protected" severity note;

        report "Register_File testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;
