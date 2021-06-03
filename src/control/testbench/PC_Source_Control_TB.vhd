library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity PC_Source_Control_TB is
end entity PC_Source_Control_TB;

architecture main of PC_Source_Control_TB is
  constant TESTCASE_COUNT: integer := 6;

  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic;
  type flags_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(FLAGS_COUNT-1 downto 0);
  type condition_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(1 downto 0);

  constant test_flags: flags_t := (o"1", o"2", o"4", o"0", o"1", o"3");
  constant test_is_J_type: control_t := ('1', '1', '1', '1', '1', '0');
  constant test_JMP_flag: condition_t := (
    JMP_C, JMP_N, JMP_Z, JMP_Unconditional, JMP_Z, JMP_C
  );

  constant test_J_PC_SRC_CTRL: control_t := ('1', '1', '1', '1', '0', '0');

  signal s_flags: std_logic_vector(FLAGS_COUNT-1 downto 0);
  signal s_is_J_type: std_logic;
  signal s_JMP_flag: std_logic_vector(1 downto 0);
  signal s_J_PC_SRC_CTRL: std_logic;
  signal s_clk: std_logic;

begin
  pic: entity work.PC_Source_Control
  port map (
      clk => s_clk,
      flags => s_flags,
      is_J_type => s_is_J_type,
      JMP_flag => s_JMP_flag,
      J_PC_SRC_CTRL => s_J_PC_SRC_CTRL
  );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_clk <= '1';
        s_flags <= test_flags(i);
        s_is_J_type <= test_is_J_type(i);
        s_JMP_flag <= test_JMP_flag(i);
      wait for 50 ps;

      s_clk <= '0';
      wait for 50 ps;
      assert (s_J_PC_SRC_CTRL = test_J_PC_SRC_CTRL(i))
      report "FAIL: case " & integer'image(i) & CR
        & "J_PC_SRC_CTRL = " & std_logic'image(s_J_PC_SRC_CTRL) & CR
        & "expected  = " & std_logic'image(test_J_PC_SRC_CTRL(i))
      severity error;
    end loop;
    wait;

  end process;

end architecture main;
