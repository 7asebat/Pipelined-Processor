LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.Utility_Pack.ALL;

ENTITY Processor IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    IO_in : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    IO_out : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE main OF Processor IS
  SIGNAL s_IF_return_adr : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_IF_IR : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

  SIGNAL s_ID_control_signals : control_signals_t;
  SIGNAL s_ID_enable_n : STD_LOGIC;
  SIGNAL s_ID_lw_reset : STD_LOGIC;
  SIGNAL s_ID_return_adr : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_ID_IR : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_ID_imm_value : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_ID_regA_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_ID_regB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_ID_regA_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_ID_regB_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

  SIGNAL s_EX_control_signals : control_signals_t;
  SIGNAL s_EX_J_PC_SRC_CTRL : STD_LOGIC;
  SIGNAL s_EX_forward_regB_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_return_adr : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_imm_value : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_regA_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_EX_regB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_EX_regA_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_regB_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_flags : STD_LOGIC_VECTOR(FLAGS_COUNT - 1 DOWNTO 0);
  SIGNAL s_EX_ALU_result : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_EX_IO_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

  SIGNAL s_MEM_control_signals : control_signals_t;
  SIGNAL s_MEM_is_RET : STD_LOGIC;
  SIGNAL s_MEM_ALU_result : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_MEM_flags : STD_LOGIC_VECTOR(FLAGS_COUNT - 1 DOWNTO 0);
  SIGNAL s_MEM_return_adr : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_MEM_regB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_MEM_regB_data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_MEM_IO_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_MEM_Memory_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

  SIGNAL s_WB_control_signals : control_signals_t;
  SIGNAL s_WB_result : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_WB_regB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL s_WB_ALU_result : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_WB_Memory_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_WB_IO_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

  SIGNAL s_IFID_reset : STD_LOGIC;
  SIGNAL s_IFID_enable : STD_LOGIC;

  SIGNAL s_IDEX_reset : STD_LOGIC;
  SIGNAL s_IDEX_enable : STD_LOGIC;
  SIGNAL s_IDEX_flush : STD_LOGIC;

  SIGNAL s_EXMEM_reset : STD_LOGIC;
  SIGNAL s_EXMEM_enable : STD_LOGIC;

  SIGNAL s_MEMWB_reset : STD_LOGIC;
  SIGNAL s_MEMWB_enable : STD_LOGIC;

BEGIN
  fetch : ENTITY work.Stage_Fetch
    PORT MAP(
      clk => clk,
      rst => reset,
      enable_n => s_ID_enable_n,
      J_PC_SRC_CTRL => s_EX_J_PC_SRC_CTRL,
      RET_PC_SRC_CTRL => s_WB_control_signals.is_RET,

      jmp_address => s_EX_forward_regB_data,
      WB_result => s_WB_result,

      return_adr => s_IF_return_adr,
      IR => s_IF_IR
    );

  -- TODO(Abdelrahman) Verify this
  s_IFID_enable <= NOT s_ID_enable_n OR reset;
  s_IFID_reset <= (
    s_EX_control_signals.is_CALL_or_RET OR
    s_MEM_control_signals.is_RET OR
    s_WB_control_signals.is_RET
  );
  intreg_ifid : ENTITY work.Intreg_IF_ID
    PORT MAP(
      clk => clk,
      en => s_IFID_enable,
      rst => s_IFID_reset,

      load_return_adr => s_IF_return_adr,
      load_IR => s_IF_IR,

      return_adr => s_ID_return_adr,
      IR => s_ID_IR
    );

  decode : ENTITY work.Stage_Decode
    PORT MAP(
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
  -- NOTE(Abdelrahman) 
  -- One true jump followed by a false jump causes both jumps to be taken
  -- Unless the IDEX register is flushed after a jump is taken
  -- Introducing a synchronous flush fixes this
  s_IDEX_reset <= reset;
  s_IDEX_enable <= '1';
  s_IDEX_flush <= s_EX_J_PC_SRC_CTRL or s_ID_lw_reset;
  intreg_idex : ENTITY work.Intreg_ID_EX
    PORT MAP(
      clk => clk,
      en => s_IDEX_enable,
      rst => s_IDEX_reset,
      flush => s_IDEX_flush,

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

  execute : ENTITY work.Stage_Execute
    PORT MAP(
      clk => clk,
      rst => reset,

      control_signals => s_EX_control_signals,

      imm_value => s_EX_imm_value,
      regA_ID => s_EX_regA_ID,
      regB_ID => s_EX_regB_ID,
      regA_data => s_EX_regA_data,
      regB_data => s_EX_regB_data,

      -- Feedback values
      MEM_NOP => s_MEM_control_signals.NOP,
      MEM_IO_in => s_MEM_control_signals.IO_in,
      MEM_IO_load => s_MEM_IO_load,
      MEM_regB_ID => s_MEM_regB_ID,
      MEM_ALU_result => s_MEM_ALU_result,

      WB_NOP => s_WB_control_signals.NOP,
      WB_regB_ID => s_WB_regB_ID,
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
  s_EXMEM_reset <= reset;
  s_EXMEM_enable <= '1';
  intreg_exmem : ENTITY work.Intreg_EX_MEM
    PORT MAP(
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

  memory : ENTITY work.Stage_Memory
    PORT MAP(
      clk => clk,

      ALU_Result => s_MEM_ALU_result,
      return_adr => s_MEM_return_adr,
      regB_data => s_MEM_regB_data,
      regB_ID => s_MEM_regB_ID,
      IO_load => s_MEM_IO_load,

      is_CALL => s_MEM_control_signals.is_CALL,
      Mem_Write => s_MEM_control_signals.Mem_Write,

      Memory_Load => s_MEM_Memory_load
    );

  s_MEMWB_reset <= reset;
  s_MEMWB_enable <= '1';
  intreg_memwb : ENTITY work.Intreg_MEM_WB
    PORT MAP(
      clk => clk,
      en => s_MEMWB_enable,
      rst => s_MEMWB_reset,

      load_control_signals => s_MEM_control_signals,
      load_ALU_result => s_MEM_ALU_result,
      load_MEM_load => s_MEM_Memory_load,
      load_IO_load => s_MEM_IO_load,
      load_regB_ID => s_MEM_regB_ID,

      control_signals => s_WB_control_signals,
      ALU_result => s_WB_ALU_result,
      MEM_load => s_WB_Memory_load,
      IO_load => s_WB_IO_load,
      regB_ID => s_WB_regB_ID
    );

  writeback : ENTITY work.Stage_Writeback
    PORT MAP(
      ALU_result => s_WB_ALU_result,
      Memory_Load => s_WB_Memory_load,
      IO_load => s_WB_IO_load,
      WB_Source => s_WB_control_signals.WB_source,

      WB_Result => s_WB_result
    );

END ARCHITECTURE main;