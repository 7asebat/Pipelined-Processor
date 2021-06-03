library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

-- TODO(Abdelrahman) Extract all constants into one package
entity Control_Unit is
  port (IR: in std_logic_vector(IR_SIZE-1 downto 0);
        control_signals: out control_signals_t);
end entity Control_Unit;

architecture main of Control_Unit is
  -- TODO(Abdelrahman) Fix these declarations
  -- type opcode_t is std_logic_vector(5 downto 0);
  -- type funct_t is std_logic_vector(ALU_FUNCT_SIZE-1 downto 0);

  alias IR_ALU_funct: std_logic_vector(ALU_FUNCT_SIZE-1 downto 0) is IR(IR_SIZE-7 downto IR_SIZE-10);

  alias opcode: std_logic_vector(5 downto 0) is IR(IR_SIZE-1 downto IR_SIZE-6);
  alias opcode_type: std_logic_vector(1 downto 0) is opcode(5 downto 4);
  alias opcode_Opc: std_logic is opcode(3); -- Op count
  alias opcode_ALU: std_logic is opcode(2);
  alias opcode_JMP_flag: std_logic_vector(1 downto 0) is opcode(1 downto 0);

  constant TYPE_R: std_logic_vector(1 downto 0) := b"00";
  constant TYPE_J: std_logic_vector(1 downto 0) := b"01";
  constant TYPE_I: std_logic_vector(1 downto 0) := b"10";
  constant TYPE_C: std_logic_vector(1 downto 0) := b"11";

  constant BITS_LW: std_logic_vector(4 downto 0) := b"10_0_1_0";
  constant BITS_CLR: std_logic_vector(1 downto 0) := b"00";
  constant BITS_SET: std_logic_vector(1 downto 0) := b"01";

  constant ALU_Main: std_logic := '0';
  constant ALU_Aux: std_logic := '1';

  constant OPC_Single_Op: std_logic := '0';
  constant OPC_Double_Op: std_logic := '1';

  constant OP_CALL: std_logic_vector(5 downto 0) := b"01_10_00";
  constant OP_RET: std_logic_vector(5 downto 0) := b"01_10_01";

  constant OP_LDD: std_logic_vector(5 downto 0) := b"10_0_1_01";
  constant OP_STD: std_logic_vector(5 downto 0) := b"10_0_1_10";

  -- TODO(Abdelrahman) Change all constants to this format
  -- constant OP_PUSH: std_logic_vector(5 downto 0) := TYPE_R & OPC_Single_Op & ALU_Aux & b"00";
  constant OP_PUSH: std_logic_vector(5 downto 0) := b"00_1_0_00";
  constant OP_POP: std_logic_vector(5 downto 0) := b"00_1_0_01";
  constant OP_IN: std_logic_vector(5 downto 0) := b"00_1_0_10";
  constant OP_OUT: std_logic_vector(5 downto 0) := b"00_1_0_11";

  constant OP1_Ra: std_logic_vector(1 downto 0) := b"00";
  constant OP1_Imm: std_logic_vector(1 downto 0) := b"01";
  constant OP1_SP: std_logic_vector(1 downto 0) := b"10";

  constant OP2_Rb: std_logic_vector(1 downto 0) := b"00";
  constant OP2_Imm: std_logic_vector(1 downto 0) := b"01";
  constant OP2_Zero: std_logic_vector(1 downto 0) := b"10";
  constant OP2_Two: std_logic_vector(1 downto 0) := b"11";

  constant WBS_ALU: std_logic_vector(1 downto 0) := b"00";
  constant WBS_Memload: std_logic_vector(1 downto 0) := b"01";
  constant WBS_IOload: std_logic_vector(1 downto 0) := b"10";

  signal s_is_LW: std_logic;
  signal s_is_CALL: std_logic;
  signal s_is_RET: std_logic;

begin
  control_signals.is_J_type <= '1' when 
    opcode_type = TYPE_J else 
  '0';

  control_signals.JMP_flag <= opcode_JMP_flag;

  s_is_LW <= '1' when 
    opcode(5 downto 1) = BITS_LW else 
  '0';

  control_signals.is_LW <= s_is_LW;

  s_is_CALL <= '1' when 
    opcode = OP_CALL else 
  '0';

  control_signals.is_CALL <= s_is_CALL;

  s_is_RET <= '1' when 
    opcode = OP_RET else 
  '0';

  control_signals.is_RET <= s_is_RET;

  control_signals.is_CALL_or_RET <= s_is_CALL or s_is_RET;

  control_signals.RET_PC_SRC_CTRL <= s_is_RET;

  control_signals.SP_push_or_pop <= OP_PUSH(1 downto 0) when 
    opcode = OP_PUSH else OP_POP(1 downto 0) 
    when opcode = OP_POP else
  b"11";

  -- POP
  -- LW
  -- (R/I) & Main ALU
  control_signals.Reg_write <= '1' when 
    opcode = OP_POP or 
    s_is_LW = '1' or
    (opcode_type = TYPE_R and opcode_ALU = ALU_Main) or
    (opcode_type = TYPE_I and opcode_ALU = ALU_Main) else
  '0';

  control_signals.Mem_write <= '1' when
    opcode = OP_STD or
    opcode = OP_PUSH or
    opcode = OP_CALL else
  '0';

  control_signals.Flags_set <= b"001" when
    (opcode_type = TYPE_C and opcode(1 downto 0) = BITS_SET) else
  b"000";

  control_signals.Flags_reset <= b"001" when
    (opcode_type = TYPE_C and opcode(1 downto 0) = BITS_CLR) else
  b"000";

  -- (R/I) & Main ALU
  control_signals.Flags_enable <= '1' when
    (opcode_type = TYPE_R and opcode_ALU = ALU_Main) or
    (opcode_type = TYPE_I and opcode_ALU = ALU_Main) else
  '0';

  control_signals.ALU_op1_src <= 
    OP1_Ra when (opcode_type = TYPE_R and opcode_Opc = OPC_Double_Op) 
            or opcode = OP_STD 
            or opcode = OP_LDD 
    else
    OP1_Imm when (opcode_type = TYPE_I and opcode(1 downto 0) = b"00") 
    else
    OP1_SP when opcode = OP_PUSH
           or   opcode = OP_POP
           or   opcode = OP_CALL
           or   opcode = OP_RET 
    else
    b"11";

  control_signals.ALU_op2_src <= 
    OP2_Rb when (opcode_type = TYPE_R and opcode_ALU = ALU_Main)
           or   (opcode_type = TYPE_I and opcode(1 downto 0) = b"00") 
    else
    OP2_Imm when opcode = OP_STD
            or   opcode = OP_LDD
    else
    OP2_Zero when opcode = OP_PUSH
             or   opcode = OP_CALL
    else
    OP2_Two;

  control_signals.ALU_funct <= IR_ALU_funct;

  control_signals.IO_in <= '1' when opcode = OP_IN else
  '0';

  control_signals.IO_out <= '1' when opcode = OP_OUT else
  '0';

  -- TODO(Abdelrahman) Replace I-type condition, the long ugly one
  control_signals.WB_source <=
    WBS_ALU when opcode_type = TYPE_R
            or   (opcode_type = TYPE_I and opcode(1 downto 0) = b"00") 
    else
    WBS_Memload when opcode = OP_LDD
                or   opcode = OP_POP
    else
    WBS_IOload when opcode = OP_IN
    else
    b"11";

end architecture main;
