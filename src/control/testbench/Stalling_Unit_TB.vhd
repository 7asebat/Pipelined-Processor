library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Stalling_Unit_TB is
end entity Stalling_Unit_TB;

architecture main of Stalling_Unit_TB is
  constant TESTCASE_COUNT: integer := 7;
  constant REG_ADR_WIDTH: integer := 3;

  type bit_t is array (0 to TESTCASE_COUNT-1) of std_logic;
  type Reg_ID_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);
  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 DOWNTO 0);

  constant test_is_lw: bit_t := ('1', '1', '1', '1', '1', '1', '0');
  constant test_EX_RegB_ID: Reg_ID_t := (b"010", b"001", b"011", b"010", b"010", b"001", b"001");

  constant test_IR: word_t := (
    -- R-type, Double-op, Main ALU, 6 filler bits, Ra, Rb
    TYPE_R & OPC_Double_OP & ALU_Main & o"00" & o"2" & o"3" & x"0000",
    -- LDD/STD, Add, Ra, Rb
    OP_LDD & x"8" & o"1" & o"2" & x"0000",
    OP_STD & x"8" & o"1" & o"3" & x"0000",
    -- PUSH/POP, Add, 4 filler bits, Rb
    OP_POP & x"8" & o"2" & o"1" & x"0000",
    OP_PUSH & x"8" & o"1" & o"2" & x"0000",
    -- CALL, Add, 4 filler bits, Rb
    OP_CALL & x"8" & o"0" & o"1" & x"0000",
    -- PUSH/POP, Add, 4 filler bits, Rb
    OP_POP & x"8" & o"0" & o"1" & x"0000"
  );

  constant test_lw_reset: bit_t := ('1', '1', '1', '0', '1', '1', '0');
  constant test_not_en: bit_t := ('1', '1', '1', '0', '1', '1', '0');

  signal s_clk: std_logic;
  signal s_is_lw: std_logic;
  signal s_lw_reset: std_logic;
  signal s_not_en: std_logic;
  signal s_IR: STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  signal s_EX_RegB_ID: std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);

begin
  uut: entity work.Stalling_Unit
  port map (
    clk => s_clk,
    is_lw => s_is_lw,
    lw_reset => s_lw_reset,
    not_en => s_not_en,
    IR => s_IR,
    EX_RegB_ID => s_EX_RegB_ID
  );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_clk <= '0';
        s_is_lw <= test_is_lw(i);
        s_EX_RegB_ID <= test_EX_regB_ID(i);
        s_IR <= test_IR(i);

      wait for 50 ps;
      s_clk <= '1';
      wait for 50 ps;

      assert (s_not_en = test_not_en(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;

      assert (s_lw_reset = test_lw_reset(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;
    end loop;
    wait;

  end process;

end architecture main;
