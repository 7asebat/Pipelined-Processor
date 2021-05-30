library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Forwarding_Unit_TB is
end entity Forwarding_Unit_TB;

architecture main of Forwarding_Unit_TB is
  constant TESTCASE_COUNT: integer := 5;

  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);
  type adr_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(REG_ADR_WIDTH-1 downto 0);

  constant test_EX_regA_ID: adr_t := (O"0", O"0", O"0", O"3", O"1");
  constant test_EX_regB_ID: adr_t := (O"1", O"1", O"1", O"4", O"1");

  constant test_WB_regB_ID: adr_t := (O"0", O"1", O"0", O"1", O"1");
  constant test_MEM_regB_ID: adr_t := (O"0", O"0", O"1", O"2", O"1");
  

  constant test_EX_regA_data: word_t := (x"0000_AAAA",
                                         x"0000_AAAA",
                                         x"0000_AAAA",
                                         x"0000_AAAA",
                                         x"0000_AAAA");

  constant test_EX_regB_data: word_t := (x"0000_BBBB",
                                         x"0000_BBBB",
                                         x"0000_BBBB",
                                         x"0000_BBBB",
                                         x"0000_BBBB");

  constant test_MEM_ALU_result: word_t := (x"EEEE_AAAA",
                                           x"EEEE_AAAA",
                                           x"EEEE_BBBB",
                                           x"DEAD_BEEF",
                                           x"0E0E_0E0E");

  constant test_WB_result: word_t := (x"CCCC_AAAA",
                                      x"CCCC_BBBB",
                                      x"CCCC_AAAA",
                                      x"BEEF_0000",
                                      x"BEEF_0000");

  constant test_forwardA: word_t := (x"EEEE_AAAA",
                                     x"EEEE_AAAA",
                                     x"CCCC_AAAA",
                                     x"0000_AAAA",
                                     x"0E0E_0E0E");

  constant test_forwardB: word_t := (x"0000_BBBB",
                                     x"CCCC_BBBB",
                                     x"EEEE_BBBB",
                                     x"0000_BBBB",
                                     x"0E0E_0E0E");

  signal s_EX_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_EX_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_WB_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_MEM_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);

  signal s_EX_regA_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_EX_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_WB_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_forwardA: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_forwardB: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  forwarding_unit: entity work.Forwarding_Unit
    port map (EX_regA_ID => s_EX_regA_ID,
              EX_regB_ID => s_EX_regB_ID,
              WB_regB_ID => s_WB_regB_ID,
              MEM_regB_ID => s_MEM_regB_ID,

              EX_regA_data => s_EX_regA_data,
              EX_regB_data => s_EX_regB_data,
              MEM_ALU_result => s_MEM_ALU_result,
              WB_result => s_WB_result,

              forwardA => s_forwardA,
              forwardB => s_forwardB);

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_EX_regA_ID <= test_EX_regA_ID(i);
      s_EX_regB_ID <= test_EX_regB_ID(i);
      s_WB_regB_ID <= test_WB_regB_ID(i);
      s_MEM_regB_ID <= test_MEM_regB_ID(i);

      s_EX_regA_data <= test_EX_regA_data(i);
      s_EX_regB_data <= test_EX_regB_data(i);
      s_MEM_ALU_result <= test_MEM_ALU_result(i);
      s_WB_result <= test_WB_result(i);

      wait for 50 ps;
      assert (s_forwardA = test_forwardA(i) and s_forwardB = test_forwardB(i))
      report "FAIL: case " & integer'image(i) & " "
        & "FA, FB   = (" & to_hstring(s_forwardA) & ", " & to_hstring(s_forwardB) & ") "
        & "expected = (" & to_hstring(test_forwardA(i)) & ", " & to_hstring(test_forwardB(i)) & ") "
      severity error;
      
    end loop;
    wait;
  end process;
end architecture main;
