library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Data_Memory_tb is
end Data_Memory_tb;

architecture Behavioral of Data_Memory_tb is
    component Data_Memory
        Port ( clk        : in  STD_LOGIC;
               reset      : in  STD_LOGIC;
               address    : in  STD_LOGIC_VECTOR (31 downto 0);
               write_data : in  STD_LOGIC_VECTOR (31 downto 0);
               mem_read   : in  STD_LOGIC;
               mem_write  : in  STD_LOGIC;
               read_data  : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal address    : STD_LOGIC_VECTOR (31 downto 0);
    signal write_data : STD_LOGIC_VECTOR (31 downto 0);
    signal mem_read   : STD_LOGIC := '0';
    signal mem_write  : STD_LOGIC := '0';
    signal read_data  : STD_LOGIC_VECTOR (31 downto 0);

    -- Word-aligned byte addresses: addr 2 -> byte addr 8, addr 4 -> byte addr 16
    -- Using byte addressing with word granularity (address[9:2] indexes the word)
    -- addr 2 means word index 2, so byte address = 2 * 4 = 8
    -- addr 4 means word index 4, so byte address = 4 * 4 = 16
    constant BYTE_ADDR_2 : STD_LOGIC_VECTOR(31 downto 0) := x"00000008"; -- word 2
    constant BYTE_ADDR_4 : STD_LOGIC_VECTOR(31 downto 0) := x"00000010"; -- word 4

    -- Task 1 required values
    constant VAL_1024   : STD_LOGIC_VECTOR(31 downto 0) := x"00000400"; -- 1024
    constant VAL_429496 : STD_LOGIC_VECTOR(31 downto 0) := x"00068EB8"; -- 429496
begin
    UUT: Data_Memory port map (
        clk        => clk,
        reset      => reset,
        address    => address,
        write_data => write_data,
        mem_read   => mem_read,
        mem_write  => mem_write,
        read_data  => read_data
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
        mem_read  <= '0';
        mem_write <= '0';
        address   <= (others => '0');
        write_data<= (others => '0');
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        -- ----------------------------------------------------------------
        -- Task 1(i): Write 1024 into Memory Address 2, then read it back
        -- ----------------------------------------------------------------
        address    <= BYTE_ADDR_2;
        write_data <= VAL_1024;
        mem_write  <= '1';
        mem_read   <= '0';
        wait for 20 ns;          -- one full clock cycle

        -- Read back
        mem_write <= '0';
        mem_read  <= '1';
        wait for 10 ns;
        assert read_data = VAL_1024
            report "FAIL Task1(i): expected 1024 at address 2" severity error;
        report "PASS Task1(i): Read 1024 from Memory Address 2" severity note;

        -- ----------------------------------------------------------------
        -- Task 1(ii): Write 429496 into Memory Address 4, then read it back
        -- ----------------------------------------------------------------
        mem_read   <= '0';
        address    <= BYTE_ADDR_4;
        write_data <= VAL_429496;
        mem_write  <= '1';
        wait for 20 ns;

        -- Read back
        mem_write <= '0';
        mem_read  <= '1';
        wait for 10 ns;
        assert read_data = VAL_429496
            report "FAIL Task1(ii): expected 429496 at address 4" severity error;
        report "PASS Task1(ii): Read 429496 from Memory Address 4" severity note;

        -- ----------------------------------------------------------------
        -- Verify address 2 still holds 1024 (no corruption)
        -- ----------------------------------------------------------------
        address  <= BYTE_ADDR_2;
        wait for 10 ns;
        assert read_data = VAL_1024
            report "FAIL: Address 2 corrupted after write to Address 4" severity error;
        report "PASS: Address 2 still holds 1024 after Address 4 write" severity note;

        -- ----------------------------------------------------------------
        -- Verify read_data = 0 when mem_read is deasserted
        -- ----------------------------------------------------------------
        mem_read <= '0';
        wait for 10 ns;
        assert read_data = x"00000000"
            report "FAIL: read_data not zero when mem_read=0" severity error;
        report "PASS: read_data is 0 when mem_read=0" severity note;

        report "Data_Memory testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;
