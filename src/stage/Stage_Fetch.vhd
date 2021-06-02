library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Stage_Fetch is
port (
    clk: in std_logic;
    rst: in std_logic;

    -- Disables the PC if high
    enable_n: in std_logic;

    -- PC source selectors
    J_PC_SRC_CTRL: in std_logic;
    RET_PC_SRC_CTRL: in std_logic;

    -- Feedback values
    jmp_address: in std_logic_vector(WORD_SIZE-1 downto 0);
    WB_result: in std_logic_vector(WORD_SIZE-1 downto 0);

    return_adr: out std_logic_vector(WORD_SIZE-1 downto 0);
    IR: out std_logic_vector(WORD_SIZE-1 downto 0)
);
end entity Stage_Fetch;

architecture main of Stage_Fetch is
    signal s_enable: std_logic;
    signal s_IR: std_logic_vector(WORD_SIZE-1 downto 0);

    signal s_increment: std_logic;
    signal s_instruction_address: std_logic_vector(WORD_SIZE-1 downto 0);
    signal s_return_address: std_logic_vector(WORD_SIZE-1 downto 0);

    constant PC_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0000";

begin
    -- TODO(Abdelrahman) Change this to use enable directly
    s_enable <= not enable_n;

    -- Instantiate components
    pc_inc_control: entity work.PC_Increment_Control
    port map (
        IR => s_IR,
        increment => s_increment
    );

    pc_controller: entity work.PC_Controller
    port map (
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

    instruction_memory: entity work.Memory
    port map (
        -- NOTE(Abdelrahman) no need to watch for a rising edge as this is a read-only memory
        clk => '0',
        address => s_instruction_address,
        data_out => s_IR,
        write_data => (others => '0'),
        mem_write => '0'
    );

end main;