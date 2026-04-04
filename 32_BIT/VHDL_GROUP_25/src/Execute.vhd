library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Execute is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           read_data1 : in STD_LOGIC_VECTOR (31 downto 0);
           read_data2 : in STD_LOGIC_VECTOR (31 downto 0);
           sign_extend : in STD_LOGIC_VECTOR (31 downto 0);
           pc_plus_4 : in STD_LOGIC_VECTOR (31 downto 0);
           rt : in STD_LOGIC_VECTOR (4 downto 0);
           rd : in STD_LOGIC_VECTOR (4 downto 0);
           alu_op : in STD_LOGIC_VECTOR (1 downto 0);
           reg_dst : in STD_LOGIC;
           alu_src : in STD_LOGIC;
           mem_read : in STD_LOGIC;
           mem_write : in STD_LOGIC;
           mem_to_reg : in STD_LOGIC;
           branch : in STD_LOGIC;
           jump : in STD_LOGIC;
           jr : in STD_LOGIC;
           jal : in STD_LOGIC;
           funct : in STD_LOGIC_VECTOR(5 downto 0);
           reg_write_in : in STD_LOGIC;
           alu_result : out STD_LOGIC_VECTOR (31 downto 0);
           write_data : out STD_LOGIC_VECTOR (31 downto 0);
           write_reg : out STD_LOGIC_VECTOR (4 downto 0);
           mem_read_out : out STD_LOGIC;
           mem_write_out : out STD_LOGIC;
           mem_to_reg_out : out STD_LOGIC;
           branch_out : out STD_LOGIC;
           reg_write_out : out STD_LOGIC;
           zero : out STD_LOGIC);
end Execute;

architecture Behavioral of Execute is
signal alu_input2 : STD_LOGIC_VECTOR(31 downto 0);
signal alu_control : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- ALU input mux
    alu_input2 <= read_data2 when alu_src = '0' else sign_extend;

    -- ALU control
    process(alu_op, funct)
    begin
        case alu_op is
            when "00" => alu_control <= "0010"; -- add
            when "01" => alu_control <= "0110"; -- sub
            when "10" => 
                case funct is
                    when "100000" => alu_control <= "0010"; -- add
                    when "100010" => alu_control <= "0110"; -- sub
                    when "100100" => alu_control <= "0000"; -- and
                    when "100101" => alu_control <= "0001"; -- or
                    when "101010" => alu_control <= "0111"; -- slt
                    when "001010" => alu_control <= "0111"; -- slti (I-type uses funct placeholder)
                    when others => alu_control <= "0010";
                end case;
            when others => alu_control <= "0010";
        end case;
    end process;

    -- ALU
    process(alu_control, read_data1, alu_input2)
    begin
        zero <= '0';
        case alu_control is
            when "0000" => 
                alu_result <= read_data1 and alu_input2;
            when "0001" => 
                alu_result <= read_data1 or alu_input2;
            when "0010" => 
                alu_result <= std_logic_vector(unsigned(read_data1) + unsigned(alu_input2));
            when "0110" => 
                alu_result <= std_logic_vector(unsigned(read_data1) - unsigned(alu_input2));
                if to_integer(unsigned(read_data1) - unsigned(alu_input2)) = 0 then
                    zero <= '1';
                end if;
            when "0111" => 
                if signed(read_data1) < signed(alu_input2) then
                    alu_result <= x"00000001";
                else
                    alu_result <= x"00000000";
                end if;
            when others => 
                alu_result <= std_logic_vector(unsigned(read_data1) + unsigned(alu_input2));
        end case;
    end process;

    -- Write reg mux
    write_reg <= "11111" when jal = '1' else
                 rd when reg_dst = '1' else
                 rt;

    -- Outputs
    write_data <= pc_plus_4 when jal = '1' else read_data2;
    mem_read_out <= mem_read;
    mem_write_out <= mem_write;
    mem_to_reg_out <= mem_to_reg;
    branch_out <= branch;
    reg_write_out <= reg_write_in;
end Behavioral;
