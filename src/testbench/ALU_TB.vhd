library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity ALU_TB is
end entity ALU_TB;

architecture main of ALU_TB is
  constant TESTCASE_COUNT: integer := 23;
  constant WORD_SIZE: integer := 32;

  type flags_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(2 downto 0);
  type op_t is array(0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);
  type selector_t is array(0 to TESTCASE_COUNT-1) of std_logic_vector(3 downto 0);

  constant test_OpA: op_t := (
    x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
    x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
    x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
    x"ABCDABCD", x"ABABCDCD", x"123ABCDE", x"FFFFFFFF",
    x"00000000", x"000F000F", x"00000000", x"00000001",
    x"00000003", x"00000001", x"00000003"
  );
  constant test_OpB: op_t := (
    x"FFFFFFFF", x"FFFFDFF0", x"FFFFFFFF", x"FFFFFFFE",
    x"00000000", x"FFFFFFFF", x"00000001", x"00000001",
    x"F0000000", x"00000000", x"0000000F", x"00000000",
    x"FFFFFFFF", x"1234ABCD", x"DEADBEAD", x"ABCDABCD",
    x"ABCDABCD", x"F000F000", x"00000000", x"FFFFFFFF",
    x"0000000F", x"FFFFFFFF", x"F0000000"
  );
  constant test_result: op_t := (
    x"00000000", x"0000200F", x"00000000", x"FFFFFFFF",
    x"FFFFFFFF", x"FFFFFFFE", x"00000000", x"FFFFFFFF",
    x"E0000001", x"00000000", x"80000007", x"00000000",
    x"ABCDABCD", x"BDE0799A", x"338CFE31", x"ABCDABCD",
    x"00000000", x"F00FF00F", x"00000000", x"FFFFFFFE",
    x"00000078", x"EFFFFFFF", x"1E000000"
  );
  constant test_S: selector_t := (
    "0000", "0001", "0010", "0010",
    "0011", "0011", "0011", "0100",
    "0101", "0101", "0110", "0110",
    "0111", "1000", "1001", "1010",
    "1010", "1011", "1011", "1100",
    "1100", "1101", "1101"
  );
  constant test_flags_in: flags_t := (
    "011", "111", "010", "101",
    "100", "100", "011", "101",
    "101", "000", "101", "000",
    "000", "100", "100", "110",
    "111", "100", "111", "100",
    "111", "000", "111"
  );
  constant test_flags_out: flags_t := (
    "111", "001", "101", "010",
    "011", "010", "100", "011",
    "101", "000", "101", "000",
    "000", "010", "000", "010",
    "101", "010", "101", "101",
    "110", "001", "110"
  );

  signal s_OpA: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_OpB: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_S: std_logic_vector(3 downto 0);
  signal s_flags_in: std_logic_vector(2 downto 0);
  signal s_flags_out: std_logic_vector(2 downto 0);
begin
  alu: entity work.ALU
    generic map(WORD_SIZE)
    port map (
      OpA => s_OpA, 
      OpB => s_OpB,
      result => s_result,
      S => s_S,
      flags_in => s_flags_in,
      flags_out => s_flags_out
    );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop

      s_OpA <= test_OpA(i);
      s_OpB <= test_OpB(i);
      s_S <= test_S(i);
      s_flags_in <= test_flags_in(i);

      wait for 25 ps;

      assert(s_flags_out = test_flags_out(i))
      report "FAIL: testcase " & integer'image(i) & " FLAGS NOT EQUAL"
      severity error;

      assert(s_result = test_result(i))
      report "FAIL: testcase " & integer'image(i) & " RESULT NOT EQUAL"
      severity error;
      
      wait for 25 ps;
    end loop;
    wait;
  end process;

end architecture main;
