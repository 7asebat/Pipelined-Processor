library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Utility_Pack.all;

entity Processor is
port (
  clk: in std_logic;
  reset: in std_logic;
  IO_in: in std_logic_vector(WORD_SIZE-1 downto 0);
  IO_out: out std_logic_vector(WORD_SIZE-1 downto 0)
);
end entity;

architecture main of Processor is
  signal s_IF_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_IF_IR: std_logic_vector(WORD_SIZE-1 downto 0);

  signal s_ID_control_signals: control_signals_t;
  signal s_ID_enable_n: std_logic;
  signal s_ID_lw_reset: std_logic;
  signal s_ID_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_ID_IR: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_ID_imm_value: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_ID_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_ID_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_ID_regA_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_ID_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);

  signal s_EX_control_signals: control_signals_t;
  signal s_EX_J_PC_SRC_CTRL: std_logic;
  signal s_EX_forward_regB_data: std_logic_vector(WORD_SIZE-1 downto 0); 
  signal s_EX_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_imm_value: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_EX_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_EX_regA_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_flags: std_logic_vector(FLAGS_COUNT-1 downto 0);
  signal s_EX_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_IO_load: std_logic_vector(WORD_SIZE-1 downto 0);

  signal s_MEM_control_signals: control_signals_t;
  signal s_MEM_is_RET: std_logic;
  signal s_MEM_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_flags: std_logic_vector(FLAGS_COUNT-1 downto 0);
  signal s_MEM_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_MEM_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_IO_load: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_Memory_load: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_reset_signal: std_logic;

  signal s_WB_control_signals: control_signals_t;
  signal s_WB_reset_signal: std_logic;
  signal s_WB_is_RET_or_RESET: std_logic;
  signal s_WB_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_WB_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_WB_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_WB_Memory_load: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_WB_IO_load: std_logic_vector(WORD_SIZE-1 downto 0);

  signal s_IFID_reset: std_logic;
  signal s_IFID_enable: std_logic;

  signal s_IDEX_reset: std_logic;
  signal s_IDEX_enable: std_logic;

  signal s_EXMEM_reset: std_logic;
  signal s_EXMEM_enable: std_logic;

  signal s_MEMWB_reset: std_logic;
  signal s_MEMWB_enable: std_logic;

begin
  s_WB_is_RET_or_RESET <= s_WB_control_signals.is_RET or s_WB_reset_signal;
  fetch: entity work.Stage_Fetch
  port map (
    clk => clk,
    rst => reset,
    enable_n => s_ID_enable_n,
    J_PC_SRC_CTRL => s_EX_J_PC_SRC_CTRL,
    RET_PC_SRC_CTRL => s_WB_is_RET_or_RESET,
    
    jmp_address => s_EX_forward_regB_data,
    WB_result => s_WB_result,

    return_adr => s_IF_return_adr,
    IR => s_IF_IR
  );

  -- TODO(Abdelrahman) Verify this
  s_IFID_enable <= not s_ID_enable_n;
  s_IFID_reset <= (
    s_EX_control_signals.is_CALL_or_RET or
    s_MEM_control_signals.is_RET or
    s_WB_is_RET_or_RESET
  );
  intreg_ifid: entity work.Intreg_IF_ID
  port map (
    clk => clk,
    en => s_IFID_enable,
    rst => s_IFID_reset,

    load_return_adr => s_IF_return_adr,
    load_IR => s_IF_IR,

    return_adr => s_ID_return_adr,
    IR => s_ID_IR
  );

  decode: entity work.Stage_Decode
  port map (
    clk => clk,
    rst => reset,

    IR => s_ID_IR,

    Reg_write => s_WB_control_signals.Reg_write,
    Reg_write_ID => s_WB_regB_ID,
    Reg_write_data => s_WB_result,

    is_lw => s_EX_control_signals.is_LW,
    EX_regB_ID => s_EX_regB_ID,

    control_signals => s_ID_control_signals,
    imm_value => s_ID_imm_value,
    regA_ID => s_ID_regA_ID,
    regB_ID => s_ID_regB_ID,
    regA_data => s_ID_regA_data,
    regB_data => s_ID_regB_data,

    lw_reset => s_ID_lw_reset,
    enable_n => s_ID_enable_n
  );

  -- TODO(Abdelrahman) Verify this
  s_IDEX_enable <= '1';
  s_IDEX_reset <= s_ID_lw_reset;
  intreg_idex: entity work.Intreg_ID_EX
  port map (
    clk => clk,
    en => s_IDEX_enable,
    rst => s_IDEX_reset,

    load_control_signals => s_ID_control_signals,
    load_return_adr => s_ID_return_adr,
    load_imm_value => s_ID_imm_value,
    load_regA_ID => s_ID_regA_ID,
    load_regB_ID => s_ID_regB_ID,
    load_regA_data => s_ID_regA_data,
    load_regB_data => s_ID_regB_data,

    control_signals => s_EX_control_signals,
    return_adr => s_EX_return_adr,
    imm_value => s_EX_imm_value,
    regA_ID => s_EX_regA_ID,
    regB_ID => s_EX_regB_ID,
    regA_data => s_EX_regA_data,
    regB_data => s_EX_regB_data
  );

  execute: entity work.Stage_Execute
  port map (
    clk => clk,
    rst => reset,

    control_signals => s_EX_control_signals,

    imm_value => s_EX_imm_value,
    regA_ID => s_EX_regA_ID,
    regB_ID => s_EX_regB_ID,
    regA_data => s_EX_regA_data,
    regB_data => s_EX_regB_data,

    -- Feedback values
    WB_regB_ID => s_WB_regB_ID,
    MEM_regB_ID => s_MEM_regB_ID,
    MEM_ALU_result => s_MEM_ALU_result,
    WB_result => s_WB_result,

    flags => s_EX_flags,
    ALU_result => s_EX_ALU_result,
    IO_load => s_EX_IO_load,
    forward_regB_data => s_EX_forward_regB_data,
    J_PC_SRC_CTRL => s_EX_J_PC_SRC_CTRL,

    IO_signal_in => IO_in,
    IO_signal_out => IO_out
  );

  -- TODO(Abdelrahman) Verify this
  s_EXMEM_enable <= '1';
  s_EXMEM_reset <= '0';
  intreg_exmem: entity work.Intreg_EX_MEM
  port map (
    clk => clk,
    en => s_EXMEM_enable,
    rst => s_EXMEM_reset,

    load_control_signals => s_EX_control_signals,
    load_flags => s_EX_flags,
    load_ALU_result => s_EX_ALU_result,
    load_return_adr => s_EX_return_adr,
    load_regB_data => s_EX_forward_regB_data,
    load_regB_ID => s_EX_regB_ID,
    load_IO_load => s_EX_IO_load,

    control_signals => s_MEM_control_signals,
    flags => s_MEM_flags,
    ALU_result => s_MEM_ALU_result,
    return_adr => s_MEM_return_adr,
    regB_data => s_MEM_regB_data,
    regB_ID => s_MEM_regB_ID,
    IO_load => s_MEM_IO_load
  );

  memory: entity work.Stage_Memory
  port map (
    clk => clk,
    reset => reset,

    ALU_Result => s_MEM_ALU_result,
    return_adr => s_MEM_return_adr,
    regB_data => s_MEM_regB_data,
    regB_ID => s_MEM_regB_ID,
    IO_Load => s_MEM_IO_load,

    is_CALL => s_MEM_control_signals.is_CALL,
    Mem_Write => s_MEM_control_signals.Mem_Write,

    reset_signal => s_MEM_reset_signal,
    Memory_Load => s_MEM_Memory_load
  );

  s_MEMWB_reset <= '0';
  s_MEMWB_enable <= '1';
  intreg_memwb: entity work.Intreg_MEM_WB
  port map (
    clk => clk,
    en => s_MEMWB_enable,
    rst => s_MEMWB_reset,

    load_reset_signal => s_MEM_reset_signal,
    load_control_signals => s_MEM_control_signals,
    load_ALU_result => s_MEM_ALU_result,
    load_MEM_load => s_MEM_Memory_load,
    load_IO_load => s_MEM_IO_load,
    load_regB_ID => s_MEM_regB_ID,

    reset_signal => s_WB_reset_signal,
    control_signals => s_WB_control_signals,
    ALU_result => s_WB_ALU_result,
    MEM_load => s_WB_Memory_load,
    IO_load => s_WB_IO_load,
    regB_ID => s_WB_regB_ID
  );

  writeback: entity work.Stage_Writeback
  port map (
    ALU_result => s_WB_ALU_result,
    Memory_Load => s_WB_Memory_load,
    IO_Load => s_WB_IO_load,
    WB_Source => s_WB_control_signals.WB_source,

    WB_Result => s_WB_result
  );
  
end architecture main;