library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity PC_Increment_Control_TB is
end entity PC_Increment_Control_TB;

architecture main of PC_Increment_Control_TB is
  constant TESTCASE_COUNT: integer := 3;
  constant IR_SIZE: integer := 32;

  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(IR_SIZE-1 downto 0);
  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic;

  constant test_IR: word_t := (X"F000_0000", X"7000_0000", X"8000_FFFF");
  constant test_increment: control_t := ('1', '0', '1');

  signal s_IR: std_logic_vector(IR_SIZE-1 downto 0);
  signal s_increment: std_logic;

begin
  pic: entity work.PC_Increment_Control
    generic map (IR_SIZE)
    port map (IR => s_IR,
              increment => s_increment);

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_IR <= test_IR(i);

      wait for 50 ps;
      assert (s_increment = test_increment(i))
      report "FAIL: case " & integer'image(i) & " "
        & "increment = " & std_logic'image(s_increment) & " "
        & "expected  = " & std_logic'image(test_increment(i))
      severity error;
    end loop;
    wait;

  end process;

end architecture main;
