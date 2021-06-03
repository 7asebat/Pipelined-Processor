LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.Utility_Pack.ALL;

ENTITY Stalling_Unit IS
  PORT (
    clk : IN STD_LOGIC;
    is_lw : IN STD_LOGIC;
    lw_reset : OUT STD_LOGIC;
    not_en : OUT STD_LOGIC;
    IR : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    EX_RegB_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0)
  );

END ENTITY Stalling_Unit;

ARCHITECTURE main OF Stalling_Unit IS
  SIGNAL activate : STD_LOGIC;

  SIGNAL D_RegA_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL D_RegB_ID : STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
  SIGNAL D_RegA_en : STD_LOGIC;
  SIGNAL D_RegB_en : STD_LOGIC;
  SIGNAL s_is_lw : STD_LOGIC;

  ALIAS opcode : STD_LOGIC_VECTOR(5 DOWNTO 0) IS IR(IR_SIZE - 1 DOWNTO IR_SIZE - 6);
  ALIAS opcode_type : STD_LOGIC_VECTOR(1 DOWNTO 0) IS opcode(5 DOWNTO 4);
  ALIAS opcode_Opc : STD_LOGIC IS opcode(3); -- Op count

BEGIN
  D_RegA_ID <= IR(21 DOWNTO 19);
  D_RegB_ID <= IR(18 DOWNTO 16);
  D_RegA_en <= '1' WHEN (opcode_type = TYPE_R AND opcode_Opc = OPC_Double_OP) OR (opcode = OP_LDD) OR (opcode = OP_STD) ELSE
    '0';
  D_RegB_En <= '1' WHEN NOT((opcode = OP_RET) OR (opcode_type = TYPE_C)) ELSE
    '0';

  activate <=
    '1' WHEN ((s_is_lw = '1')
    AND
    (
    ((EX_RegB_ID = D_RegA_ID) AND D_RegA_en = '1')
    OR
    ((EX_RegB_ID = D_RegB_ID) AND D_RegB_en = '1')))
    ELSE
    '0';

  PROCESS (clk)
  BEGIN
    IF (rising_edge(clk)) THEN
      s_is_lw <= is_lw;
    END IF;
  END PROCESS;

  lw_reset <= activate;
  not_en <= activate;
END ARCHITECTURE main;