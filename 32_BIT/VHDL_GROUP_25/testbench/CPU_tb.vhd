library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU_tb is
end CPU_tb;

architecture Behavioral of CPU_tb is
    component CPU
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC);
    end component;

    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
begin
    -- Instantiate CPU
    UUT: CPU port map (clk => clk, reset => reset);

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Reset process
    reset_process: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;
end Behavioral;