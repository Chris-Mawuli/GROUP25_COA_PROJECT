library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( operand1 : in STD_LOGIC_VECTOR (31 downto 0);
           operand2 : in STD_LOGIC_VECTOR (31 downto 0);
           alu_control : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0);
           zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
begin
    process(alu_control, operand1, operand2)
    begin
        zero <= '0';
        case alu_control is
            when "0000" => 
                result <= operand1 and operand2;
            when "0001" => 
                result <= operand1 or operand2;
            when "0010" => 
                result <= std_logic_vector(unsigned(operand1) + unsigned(operand2));
            when "0110" => 
                result <= std_logic_vector(unsigned(operand1) - unsigned(operand2));
                if to_integer(unsigned(operand1) - unsigned(operand2)) = 0 then
                    zero <= '1';
                end if;
            when "0111" => 
                if signed(operand1) < signed(operand2) then
                    result <= x"00000001";
                else
                    result <= x"00000000";
                end if;
            when others => 
                result <= std_logic_vector(unsigned(operand1) + unsigned(operand2));
        end case;
    end process;
end Behavioral;
