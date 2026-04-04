library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC);
end CPU;

architecture Behavioral of CPU is
    -- Components
    component Instruction_Fetch
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               pc_in : in STD_LOGIC_VECTOR (31 downto 0);
               pc_out : out STD_LOGIC_VECTOR (31 downto 0);
               instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component Instruction_Decode
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
    end component;

    component Execute
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
               funct : in STD_LOGIC_VECTOR (5 downto 0);
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
    end component;

    component Memory_Access
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               alu_result : in STD_LOGIC_VECTOR (31 downto 0);
               write_data : in STD_LOGIC_VECTOR (31 downto 0);
               write_reg : in STD_LOGIC_VECTOR (4 downto 0);
               mem_read : in STD_LOGIC;
               mem_write : in STD_LOGIC;
               mem_to_reg : in STD_LOGIC;
               branch : in STD_LOGIC;
               reg_write_in : in STD_LOGIC;
               read_data : out STD_LOGIC_VECTOR (31 downto 0);
               alu_result_out : out STD_LOGIC_VECTOR (31 downto 0);
               write_reg_out : out STD_LOGIC_VECTOR (4 downto 0);
               mem_to_reg_out : out STD_LOGIC;
               reg_write_out : out STD_LOGIC);
    end component;

    component Write_Back
        Port ( read_data : in STD_LOGIC_VECTOR (31 downto 0);
               alu_result : in STD_LOGIC_VECTOR (31 downto 0);
               write_reg : in STD_LOGIC_VECTOR (4 downto 0);
               mem_to_reg : in STD_LOGIC;
               reg_write_in : in STD_LOGIC;
               write_data : out STD_LOGIC_VECTOR (31 downto 0);
               write_reg_out : out STD_LOGIC_VECTOR (4 downto 0);
               reg_write_out : out STD_LOGIC);
    end component;

    -- Signals
    signal pc_in, pc_out, instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_4 : STD_LOGIC_VECTOR(31 downto 0);

    -- Intermediate signals between stages
    signal id_ex_read_data1, id_ex_read_data2, id_ex_sign_extend : STD_LOGIC_VECTOR(31 downto 0);
    signal id_ex_rt, id_ex_rd : STD_LOGIC_VECTOR(4 downto 0);
    signal id_ex_funct : STD_LOGIC_VECTOR(5 downto 0);
    signal id_ex_jr, id_ex_jal : STD_LOGIC;
    signal id_ex_jump_address : STD_LOGIC_VECTOR(25 downto 0);
    signal id_ex_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal id_ex_reg_dst, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_branch, id_ex_jump, id_ex_reg_write : STD_LOGIC;
    signal ex_mem_alu_result, ex_mem_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_mem_write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_branch, ex_mem_reg_write, ex_mem_zero : STD_LOGIC;
    signal mem_wb_read_data, mem_wb_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wb_write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal mem_wb_mem_to_reg, mem_wb_reg_write : STD_LOGIC;

    -- Pipeline registers
    signal if_id_pc_plus_4_reg, if_id_instruction_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal id_ex_pc_plus_4_reg, id_ex_read_data1_reg, id_ex_read_data2_reg, id_ex_sign_extend_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal id_ex_rt_reg, id_ex_rd_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal id_ex_funct_reg : STD_LOGIC_VECTOR(5 downto 0);
    signal id_ex_jr_reg, id_ex_jal_reg : STD_LOGIC;
    signal id_ex_jump_address_reg : STD_LOGIC_VECTOR(25 downto 0);
    signal id_ex_alu_op_reg : STD_LOGIC_VECTOR(1 downto 0);
    signal id_ex_reg_dst_reg, id_ex_alu_src_reg, id_ex_mem_read_reg, id_ex_mem_write_reg, id_ex_mem_to_reg_reg, id_ex_branch_reg, id_ex_jump_reg, id_ex_reg_write_reg : STD_LOGIC;
    signal ex_mem_alu_result_reg, ex_mem_write_data_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_mem_write_reg_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal ex_mem_mem_read_reg, ex_mem_mem_write_reg, ex_mem_mem_to_reg_reg, ex_mem_branch_reg, ex_mem_reg_write_reg, ex_mem_zero_reg : STD_LOGIC;
    signal mem_wb_read_data_reg, mem_wb_alu_result_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wb_write_reg_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal mem_wb_mem_to_reg_reg, mem_wb_reg_write_reg : STD_LOGIC;

    -- WB
    signal wb_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal wb_write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal wb_reg_write : STD_LOGIC;

begin
    -- PC logic
    pc_plus_4 <= std_logic_vector(unsigned(pc_out) + 4);
    pc_in <= id_ex_read_data1_reg when id_ex_jr_reg = '1' else
             std_logic_vector(unsigned(pc_plus_4(31 downto 28) & id_ex_jump_address_reg & "00")) when id_ex_jump_reg = '1' else
             std_logic_vector(unsigned(pc_plus_4) + unsigned(id_ex_pc_plus_4_reg) + unsigned(signed(id_ex_sign_extend_reg(29 downto 0)) & "00")) when ex_mem_branch = '1' and ex_mem_zero = '1' else
             pc_plus_4;

    -- Pipeline registers
    process(clk, reset)
    begin
        if reset = '1' then
            if_id_pc_plus_4_reg <= (others => '0');
            if_id_instruction_reg <= (others => '0');
            id_ex_pc_plus_4_reg <= (others => '0');
            id_ex_read_data1_reg <= (others => '0');
            id_ex_read_data2_reg <= (others => '0');
            id_ex_sign_extend_reg <= (others => '0');
            id_ex_rt_reg <= (others => '0');
            id_ex_rd_reg <= (others => '0');
            id_ex_funct_reg <= (others => '0');
            id_ex_jr_reg <= '0';
            id_ex_jal_reg <= '0';
            id_ex_jump_address_reg <= (others => '0');
            id_ex_alu_op_reg <= (others => '0');
            id_ex_reg_dst_reg <= '0';
            id_ex_alu_src_reg <= '0';
            id_ex_mem_read_reg <= '0';
            id_ex_mem_write_reg <= '0';
            id_ex_mem_to_reg_reg <= '0';
            id_ex_branch_reg <= '0';
            id_ex_jump_reg <= '0';
            id_ex_reg_write_reg <= '0';
            ex_mem_alu_result_reg <= (others => '0');
            ex_mem_write_data_reg <= (others => '0');
            ex_mem_write_reg_reg <= (others => '0');
            ex_mem_mem_read_reg <= '0';
            ex_mem_mem_write_reg <= '0';
            ex_mem_mem_to_reg_reg <= '0';
            ex_mem_branch_reg <= '0';
            ex_mem_reg_write_reg <= '0';
            ex_mem_zero_reg <= '0';
            mem_wb_read_data_reg <= (others => '0');
            mem_wb_alu_result_reg <= (others => '0');
            mem_wb_write_reg_reg <= (others => '0');
            mem_wb_mem_to_reg_reg <= '0';
            mem_wb_reg_write_reg <= '0';
        elsif rising_edge(clk) then
            -- IF/ID
            if_id_pc_plus_4_reg <= pc_plus_4;
            if_id_instruction_reg <= instruction;
            -- ID/EX
            id_ex_pc_plus_4_reg <= if_id_pc_plus_4_reg;
            id_ex_read_data1_reg <= id_ex_read_data1;
            id_ex_read_data2_reg <= id_ex_read_data2;
            id_ex_sign_extend_reg <= id_ex_sign_extend;
            id_ex_rt_reg <= id_ex_rt;
            id_ex_rd_reg <= id_ex_rd;
            id_ex_funct_reg <= id_ex_funct;
            id_ex_jr_reg <= id_ex_jr;
            id_ex_jal_reg <= id_ex_jal;
            id_ex_jump_address_reg <= if_id_instruction_reg(25 downto 0);
            id_ex_alu_op_reg <= id_ex_alu_op;
            id_ex_reg_dst_reg <= id_ex_reg_dst;
            id_ex_alu_src_reg <= id_ex_alu_src;
            id_ex_mem_read_reg <= id_ex_mem_read;
            id_ex_mem_write_reg <= id_ex_mem_write;
            id_ex_mem_to_reg_reg <= id_ex_mem_to_reg;
            id_ex_branch_reg <= id_ex_branch;
            id_ex_jump_reg <= id_ex_jump;
            id_ex_reg_write_reg <= id_ex_reg_write;
            -- EX/MEM
            ex_mem_alu_result_reg <= ex_mem_alu_result;
            ex_mem_write_data_reg <= ex_mem_write_data;
            ex_mem_write_reg_reg <= ex_mem_write_reg;
            ex_mem_mem_read_reg <= ex_mem_mem_read;
            ex_mem_mem_write_reg <= ex_mem_mem_write;
            ex_mem_mem_to_reg_reg <= ex_mem_mem_to_reg;
            ex_mem_branch_reg <= ex_mem_branch;
            ex_mem_reg_write_reg <= ex_mem_reg_write;
            ex_mem_zero_reg <= ex_mem_zero;
            -- MEM/WB
            mem_wb_read_data_reg <= mem_wb_read_data;
            mem_wb_alu_result_reg <= mem_wb_alu_result;
            mem_wb_write_reg_reg <= mem_wb_write_reg;
            mem_wb_mem_to_reg_reg <= mem_wb_mem_to_reg;
            mem_wb_reg_write_reg <= mem_wb_reg_write;
        end if;
    end process;

    -- Instantiate components
    IF_stage: Instruction_Fetch port map (clk, reset, pc_in, pc_out, instruction);

    ID_stage: Instruction_Decode port map (clk, reset, if_id_instruction_reg, if_id_pc_plus_4_reg, mem_wb_reg_write_reg, mem_wb_write_reg_reg, wb_write_data,
                                                                     id_ex_read_data1, id_ex_read_data2, id_ex_sign_extend, id_ex_rt, id_ex_rd, id_ex_funct, id_ex_jr, id_ex_jal,
                                          id_ex_alu_op, id_ex_reg_dst, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_branch, id_ex_jump, id_ex_reg_write);

    EX_stage: Execute port map (clk, reset, id_ex_read_data1_reg, id_ex_read_data2_reg, id_ex_sign_extend_reg, id_ex_pc_plus_4_reg, id_ex_rt_reg, id_ex_rd_reg,
                                id_ex_alu_op_reg, id_ex_reg_dst_reg, id_ex_alu_src_reg, id_ex_mem_read_reg, id_ex_mem_write_reg, id_ex_mem_to_reg_reg,
                                id_ex_branch_reg, id_ex_jump_reg, id_ex_jr_reg, id_ex_jal_reg, id_ex_funct_reg,
                                id_ex_reg_write_reg,
                                ex_mem_alu_result, ex_mem_write_data, ex_mem_write_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_branch, ex_mem_reg_write, ex_mem_zero);

    MEM_stage: Memory_Access port map (clk, reset, ex_mem_alu_result_reg, ex_mem_write_data_reg, ex_mem_write_reg_reg, ex_mem_mem_read_reg, ex_mem_mem_write_reg, ex_mem_mem_to_reg_reg, ex_mem_branch_reg, ex_mem_reg_write_reg,
                                       mem_wb_read_data, mem_wb_alu_result, mem_wb_write_reg, mem_wb_mem_to_reg, mem_wb_reg_write);

    WB_stage: Write_Back port map (mem_wb_read_data_reg, mem_wb_alu_result_reg, mem_wb_write_reg_reg, mem_wb_mem_to_reg_reg, mem_wb_reg_write_reg,
                                   wb_write_data, wb_write_reg, wb_reg_write);

end Behavioral;