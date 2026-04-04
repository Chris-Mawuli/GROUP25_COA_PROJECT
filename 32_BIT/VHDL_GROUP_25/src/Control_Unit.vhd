library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
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
end Control_Unit;

architecture Behavioral of Control_Unit is
begin
    process(opcode, funct)
    begin
        -- Default values
        alu_op <= "00";
        reg_dst <= '0';
        alu_src <= '0';
        mem_read <= '0';
        mem_write <= '0';
        mem_to_reg <= '0';
        branch <= '0';
        jump <= '0';
        jr <= '0';
        jal <= '0';
        reg_write <= '0';
        
        case opcode is
            when "000000" => -- R-type
                reg_dst <= '1';
                alu_src <= '0';
                mem_read <= '0';
                mem_write <= '0';
                mem_to_reg <= '0';
                branch <= '0';
                jump <= '0';
                jr <= '0';
                jal <= '0';
                alu_op <= "10";
                if funct = "001000" then -- jr
                    jump <= '1';
                    jr <= '1';
                    reg_write <= '0';
                else
                    reg_write <= '1';
                end if;
            when "100011" => -- lw
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '1';
                mem_write <= '0';
                mem_to_reg <= '1';
                branch <= '0';
                jump <= '0';
                reg_write <= '1';
                alu_op <= "00";
            when "101011" => -- sw
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '1';
                branch <= '0';
                jump <= '0';
                reg_write <= '0';
                alu_op <= "00";
            when "000100" => -- beq
                alu_src <= '0';
                mem_read <= '0';
                mem_write <= '0';
                branch <= '1';
                jump <= '0';
                reg_write <= '0';
                alu_op <= "01";
            when "001000" => -- addi
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '0';
                mem_to_reg <= '0';
                branch <= '0';
                jump <= '0';
                reg_write <= '1';
                alu_op <= "00";
            when "001010" => -- slti
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '0';
                mem_to_reg <= '0';
                branch <= '0';
                jump <= '0';
                reg_write <= '1';
                alu_op <= "10";
            when "000010" => -- j
                mem_read <= '0';
                mem_write <= '0';
                branch <= '0';
                jump <= '1';
                reg_write <= '0';
            when "000011" => -- jal
                mem_read <= '0';
                mem_write <= '0';
                branch <= '0';
                jump <= '1';
                jal <= '1';
                reg_write <= '1';
            when others =>
                null;
        end case;
    end process;
end Behavioral;
