LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY Intreg_MEM_WB IS
  PORT (
    clk : IN STD_LOGIC;
    en : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    -- NOTE(Abdelrahman) We don't need all control signals here but this
    -- gives a cleaner port layout
    load_control_signals : IN control_signals_t;
    load_ALU_result : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    load_MEM_load : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    load_IO_load : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    load_regB_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
    control_signals : OUT control_signals_t;
    ALU_result : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    MEM_load : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    IO_load : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    regB_ID : OUT STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0)
  );

END ENTITY Intreg_MEM_WB;

ARCHITECTURE main OF Intreg_MEM_WB IS

  SIGNAL s_control_signals : control_signals_t;
  SIGNAL s_ALU_result : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_MEM_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_IO_load : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL s_regB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);

BEGIN

  control_signals <= s_control_signals;
  ALU_result <= s_ALU_result;
  MEM_load <= s_MEM_load;
  IO_load <= s_IO_load;
  regB_ID <= s_regB_ID;

  PROCESS (clk, rst) BEGIN
    -- TODO(Abdelrahman) Reset this register properly
    IF (rst = '1') THEN
      s_control_signals <= CTRL_NOP;
      s_ALU_result <= (OTHERS => '0');
      s_MEM_load <= (OTHERS => '0');
      s_IO_load <= (OTHERS => '0');
      s_regB_ID <= (OTHERS => '0');

    ELSIF (rising_edge(clk) AND en = '1') THEN
      s_control_signals <= load_control_signals;
      s_ALU_result <= load_ALU_result;
      s_MEM_load <= load_MEM_load;
      s_IO_load <= load_IO_load;
      s_regB_ID <= load_regB_ID;
    END IF;
  END PROCESS;
END ARCHITECTURE main;