library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

-- NOTE(Abdelrahman) return_adr is fed directly from one intermediate register to another
entity Stage_Execute is
port (
    clk: in std_logic;
    rst: in std_logic;

    control_signals: in control_signals_t;

    imm_value: in std_logic_vector(WORD_SIZE-1 downto 0);
    regA_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    regA_data: in std_logic_vector(WORD_SIZE-1 downto 0);
    regB_data: in std_logic_vector(WORD_SIZE-1 downto 0);

    -- Feedback values
    MEM_NOP: in std_logic;
    MEM_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    MEM_ALU_result: in std_logic_vector(WORD_SIZE-1 downto 0);

    WB_NOP: in std_logic;
    WB_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    WB_result: in std_logic_vector(WORD_SIZE-1 downto 0);

    flags: out std_logic_vector(FLAGS_COUNT-1 downto 0);
    ALU_result: out std_logic_vector(WORD_SIZE-1 downto 0);
    IO_load: out std_logic_vector(WORD_SIZE-1 downto 0);
    forward_regB_data: out std_logic_vector(WORD_SIZE-1 downto 0);
    J_PC_SRC_CTRL: out std_logic;

    IO_signal_in: in std_logic_vector(WORD_SIZE-1 downto 0);
    IO_signal_out: out std_logic_vector(WORD_SIZE-1 downto 0)
);
end entity Stage_Execute;

architecture main of Stage_Execute is
    signal s_SP_out: std_logic_vector(WORD_SIZE-1 downto 0);

    signal s_ALU_OpA: std_logic_vector(WORD_SIZE-1 downto 0);
    signal s_ALU_OpB: std_logic_vector(WORD_SIZE-1 downto 0);

    signal s_Flags_file_ALU: std_logic_vector(FLAGS_COUNT-1 downto 0);
    signal s_Flags_ALU_file: std_logic_vector(FLAGS_COUNT-1 downto 0);
    signal s_Flags_reset: std_logic_vector(FLAGS_COUNT-1 downto 0);

    signal s_fu_A: std_logic_vector(WORD_SIZE-1 downto 0);
    signal s_fu_B: std_logic_vector(WORD_SIZE-1 downto 0);

    constant ALU_PUSH_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := x"0000_0000";
    constant ALU_POP_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := x"0000_0002";

begin
    -- SP
    spc: entity work.SP_Controller
    port map (
        clk => clk,
        reset => rst,
        push_or_pop => control_signals.SP_push_or_pop,
        SP_out => s_SP_out
    );

    -- ALU
    with control_signals.ALU_op1_src select
    s_ALU_OpA <= s_fu_A    when "00",
                 imm_value when "01",
                 s_SP_out  when others;

    with control_signals.ALU_op2_src select
    s_ALU_OpB <= s_fu_B             when "00",
                 imm_value          when "01",
                 ALU_PUSH_INCREMENT when "10",
                 ALU_POP_INCREMENT  when others;

    alu: entity work.ALU
    port map (
        OpA => s_ALU_OpA,
        OpB => s_ALU_OpB,
        result => ALU_result,
        S => control_signals.ALU_funct,
        flags_in => s_Flags_file_ALU,
        flags_out => s_Flags_ALU_file
    );

    fu: entity work.Forwarding_Unit
    port map (
        EX_regA_ID => regA_ID,
        EX_regB_ID => regB_ID,

        MEM_NOP => MEM_NOP,
        MEM_regB_ID => MEM_regB_ID,
        MEM_ALU_result => MEM_ALU_result,

        WB_NOP => WB_NOP,
        WB_regB_ID => WB_regB_ID,
        WB_result => WB_result,

        EX_regA_data => regA_data,
        EX_regB_data => regB_data,

        forwardA => s_fu_A,
        forwardB => s_fu_B
    );
    forward_regB_data <= s_fu_B;

    -- Clear flags on reset
    s_Flags_reset <= o"7" when rst = '1' else control_signals.Flags_reset;
    ff: entity work.Flags_File
    port map (
        clk => clk,
        flags_in => s_Flags_ALU_file,
        flags_set => control_signals.Flags_set,
        flags_reset => s_Flags_reset,
        flags_out => s_Flags_file_ALU,
        flags_en => control_signals.Flags_enable
    );
    flags <= s_Flags_ALU_file;

    iob: entity work.IO_Block
    port map (
        clk => clk,
        rst => rst,
        control_in => control_signals.IO_in,
        control_out => control_signals.IO_out,

        write_in => s_fu_B,
        load_out => IO_load,

        signal_in => IO_signal_in,
        signal_out => IO_signal_out
    );

    pc_src_ctrl: entity work.PC_Source_Control
    port map (
        clk => clk,
        flags => s_Flags_file_ALU,
        is_J_type => control_signals.is_J_type,
        JMP_flag => control_signals.JMP_flag,
        J_PC_SRC_CTRL => J_PC_SRC_CTRL
    );

end main;