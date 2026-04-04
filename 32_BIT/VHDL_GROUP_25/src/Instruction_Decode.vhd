library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Decode is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           instruction : in STD_LOGIC_VECTOR (31 downto 0);
           pc_plus_4 : in STD_LOGIC_VECTOR (31 downto 0);
           reg_write_in : in STD_LOGIC;
           write_reg : in STD_LOGIC_VECTOR (4 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
           read_data2 : out STD_LOGIC_VECTOR (31 downto 0);
           sign_extend : out STD_LOGIC_VECTOR (31 downto 0);
           rt : out STD_LOGIC_VECTOR (4 downto 0);
           rd : out STD_LOGIC_VECTOR (4 downto 0);
           funct : out STD_LOGIC_VECTOR (5 downto 0);
           jr : out STD_LOGIC;
           jal : out STD_LOGIC;
           alu_op : out STD_LOGIC_VECTOR (1 downto 0);
           reg_dst : out STD_LOGIC;
           alu_src : out STD_LOGIC;
           mem_read : out STD_LOGIC;
           mem_write : out STD_LOGIC;
           mem_to_reg : out STD_LOGIC;
           branch : out STD_LOGIC;
           jump : out STD_LOGIC;
           reg_write_out : out STD_LOGIC);
end Instruction_Decode;

architecture Behavioral of Instruction_Decode is
type reg_file_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal reg_file : reg_file_type := (others => (others => '0'));
signal opcode : STD_LOGIC_VECTOR(5 downto 0);
signal rs, rt_in, rd_in : STD_LOGIC_VECTOR(4 downto 0);
signal funct_field : STD_LOGIC_VECTOR(5 downto 0);
signal immediate : STD_LOGIC_VECTOR(15 downto 0);
begin
    opcode <= instruction(31 downto 26);
    rs <= instruction(25 downto 21);
    rt_in <= instruction(20 downto 16);
    rd_in <= instruction(15 downto 11);
    funct_field <= instruction(5 downto 0);
    immediate <= instruction(15 downto 0);

    -- Register file read
    read_data1 <= reg_file(to_integer(unsigned(rs)));
    read_data2 <= reg_file(to_integer(unsigned(rt_in)));

    -- Sign extend
    sign_extend <= (15 downto 0 => immediate(15)) & immediate;

    -- Control unit
    process(opcode, funct_field)
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
        reg_write_out <= '0';
        
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
                if funct_field = "001000" then -- jr
                    jump <= '1';
                    jr <= '1';
                    reg_write_out <= '0';
                else
                    reg_write_out <= '1';
                end if;
            when "100011" => -- lw
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '1';
                mem_write <= '0';
                mem_to_reg <= '1';
                branch <= '0';
                jump <= '0';
                reg_write_out <= '1';
                alu_op <= "00";
            when "101011" => -- sw
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '1';
                branch <= '0';
                jump <= '0';
                reg_write_out <= '0';
                alu_op <= "00";
            when "000100" => -- beq
                alu_src <= '0';
                mem_read <= '0';
                mem_write <= '0';
                branch <= '1';
                jump <= '0';
                reg_write_out <= '0';
                alu_op <= "01";
            when "001000" => -- addi
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '0';
                mem_to_reg <= '0';
                branch <= '0';
                jump <= '0';
                reg_write_out <= '1';
                alu_op <= "00";
            when "001010" => -- slti
                reg_dst <= '0';
                alu_src <= '1';
                mem_read <= '0';
                mem_write <= '0';
                mem_to_reg <= '0';
                branch <= '0';
                jump <= '0';
                reg_write_out <= '1';
                alu_op <= "10"; -- use funct handling in Execute for SLTI
            when "000010" => -- j
                mem_read <= '0';
                mem_write <= '0';
                branch <= '0';
                jump <= '1';
                reg_write_out <= '0';
            when "000011" => -- jal
                mem_read <= '0';
                mem_write <= '0';
                branch <= '0';
                jump <= '1';
                jal <= '1';
                reg_write_out <= '1';
            when others =>
                null;
        end case;
    end process;

    -- Register file write
    process(clk, reset)
    begin
        if reset = '1' then
            reg_file <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write_in = '1' and to_integer(unsigned(write_reg)) /= 0 then
                reg_file(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;

    funct <= funct_field;
    rt <= rt_in;
    rd <= rd_in;
end Behavioral;
