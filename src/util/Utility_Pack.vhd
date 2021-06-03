LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;

package Utility_Pack is
  function to_string (a: std_logic_vector) return string;
  function to_hstring (slv: std_logic_vector) return string;
  function idx (adr: std_logic_vector) return integer;

  -- SP 
  constant ALU_FUNCT_SIZE: integer := 4;
  constant WORD_SIZE: integer := 32;
  constant IR_SIZE: integer := 32;
  constant REG_ADR_WIDTH: integer := 3;
  constant REG_COUNT: integer := 8;
  constant FLAGS_COUNT: integer := 3;

  constant SP_PUSH: std_logic_vector(1 downto 0) := b"00";
  constant SP_PUSH_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"FFFF_FFFE";

  constant SP_POP: std_logic_vector(1 downto 0) := b"01";
  constant SP_POP_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0002";

  -- Default value specified in the document (2^32-2)
  constant SP_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"4000_0000";

  constant PC_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0000";

  constant FLAGS_Z: integer := 2;
  constant FLAGS_N: integer := 1;
  constant FLAGS_C: integer := 0;

  constant JMP_Z: std_logic_vector(1 downto 0) := b"11";
  constant JMP_N: std_logic_vector(1 downto 0) := b"10";
  constant JMP_C: std_logic_vector(1 downto 0) := b"01";
  constant JMP_Unconditional: std_logic_vector(1 downto 0) := b"00";


  -- Control Signals Opcodes
  
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

  -- Struct
  type control_signals_t is record
    -- PC source control signals
    RET_PC_SRC_CTRL:  std_logic;

    -- Register write enable
    Reg_write:  std_logic;
    -- Memory write enable
    Mem_write:  std_logic;

    is_lw:  std_logic; 
    is_CALL:  std_logic;
    is_RET:  std_logic;

    is_CALL_or_RET:  std_logic;

    -- High if instruction is J-type (including CALL)
    -- schematic: J?
    is_J_type:  std_logic;

    -- Flag to check for jump condition
    -- 00: Unconditional
    -- 01: C
    -- 10: N
    -- 11: Z
    JMP_flag: std_logic_vector(1 downto 0);

    SP_push_or_pop:  std_logic_vector(1 downto 0);

    Flags_set:  std_logic_vector(2 downto 0);
    Flags_reset:  std_logic_vector(2 downto 0);
    Flags_enable:  std_logic;

    ALU_op1_src:  std_logic_vector(1 downto 0);
    ALU_op2_src:  std_logic_vector(1 downto 0);
    ALU_funct:  std_logic_vector(ALU_FUNCT_SIZE-1 downto 0);

    IO_in:  std_logic;
    IO_out: std_logic;

    -- Source of WB stage
    WB_source: std_logic_vector(1 downto 0);
  end record control_signals_t;

  constant CTRL_NOP: control_signals_t := (
    RET_PC_SRC_CTRL => '0',
    Reg_write => '0',
    Mem_write => '0',
    is_lw => '0',
    is_CALL => '0',
    is_RET => '0',
    is_CALL_or_RET => '0',
    is_J_type => '0',
    JMP_flag => b"00",
    SP_push_or_pop => b"11",
    Flags_set => b"000",
    Flags_reset => b"000",
    Flags_enable => '0',
    ALU_op1_src => b"00",
    ALU_op2_src => b"00",
    ALU_funct => (OTHERS => '0'),
    IO_in => '0',
    IO_out => '0',
    WB_source => b"11"
  );

end package Utility_Pack;


-- package body section
package body Utility_Pack is
  -- Turns a vector into a binary string
  function to_string (a: std_logic_vector) return string is
    variable b:    string (1 to a'length) := (others => nul);
    variable stri: integer := 1; 
  begin
       for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
        stri := stri+1;
       end loop;
    return b;
  end function;

  -- Turns a vector into a hexadecimal string
  function to_hstring (slv: std_logic_vector) return string is
    variable l: line;
  begin
      hwrite(l, slv);
      return l.all;
  end function;

  -- Turns a vector into an integer address
  function idx (adr: std_logic_vector) return integer is
  begin
    return to_integer(unsigned(adr));
  end function idx;

end package body Utility_Pack;
