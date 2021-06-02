LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY Stage_Fetch IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        -- Disables the PC if high
        enable_n : IN STD_LOGIC;

        -- PC source selectors
        J_PC_SRC_CTRL : IN STD_LOGIC;
        RET_PC_SRC_CTRL : IN STD_LOGIC;

        -- Feedback values
        jmp_address : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        WB_result : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

        return_adr : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        IR : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
    );
END ENTITY Stage_Fetch;

ARCHITECTURE main OF Stage_Fetch IS
    SIGNAL s_enable : STD_LOGIC;
    SIGNAL s_IR : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

    SIGNAL s_increment : STD_LOGIC;
    SIGNAL s_instruction_address : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL s_return_address : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

    CONSTANT PC_DEFAULT : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := X"0000_0000";

BEGIN
    -- TODO(Abdelrahman) Change this to use enable directly
    s_enable <= NOT enable_n;

    -- Instantiate components
    pc_inc_control : ENTITY work.PC_Increment_Control
        PORT MAP(
            IR => s_IR,
            increment => s_increment
        );

    pc_controller : ENTITY work.PC_Controller
        PORT MAP(
            clk => clk,
            en => s_enable,
            reset => rst,

            j_pc_src_ctrl => j_pc_src_ctrl,
            ret_pc_src_ctrl => ret_pc_src_ctrl,
            inc_sel => s_increment,

            wb_result => WB_result,
            jmp_address => jmp_address,

            return_adr => s_return_address,
            inst_address => s_instruction_address
        );
    return_adr <= s_return_address;

    instruction_memory : ENTITY work.Memory
        PORT MAP(
            -- NOTE(Abdelrahman) no need to watch for a rising edge as this is a read-only memory
            clk => '0',
            address => s_instruction_address(9 DOWNTO 0),
            data_out => s_IR,
            write_data => (OTHERS => '0'),
            mem_write => '0'
        );

END main;