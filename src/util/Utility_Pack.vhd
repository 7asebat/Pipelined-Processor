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
    SP_push_or_pop => b"11",
    Flags_set => b"000",
    Flags_reset => b"000",
    Flags_enable => '0',
    ALU_op1_src => b"00",
    ALU_op2_src => b"00",
    ALU_funct => (OTHERS => '0'),
    IO_in => '0',
    IO_out => '0',
    WB_source => b"11");

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
