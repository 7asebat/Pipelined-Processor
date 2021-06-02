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

  constant test_is_lw: bit_t := ('1', '1', '1', '1', '0', '0', '0');
  constant test_D_RegA_ID: Reg_ID_t := (b"010", b"010", b"010", b"010", b"010", b"001", b"111");
  constant test_D_RegB_ID: Reg_ID_t := (b"001", b"001", b"001", b"010", b"001", b"001", b"111");
  constant test_EX_RegB_ID: Reg_ID_t := (b"010", b"001", b"011", b"010", b"010", b"001", b"001");

  constant test_lw_reset: bit_t := ('1', '1', '0', '1', '0', '0', '0');
  constant test_not_en: bit_t := ('0', '0', '1', '0', '1', '1', '1');

  signal s_is_lw: std_logic;
  signal s_D_RegA_ID: std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);
  signal s_D_RegB_ID: std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);
  signal s_EX_RegB_ID: std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);

  signal s_lw_reset: std_logic;
  signal s_not_en: std_logic;

begin
  uut: entity work.Stalling_Unit
    port map (is_lw => s_is_lw,
              not_en => s_not_en,
              lw_reset => s_lw_reset,
              D_RegA_ID => s_D_RegA_ID,
              D_RegB_ID => s_D_RegB_ID,
              EX_RegB_ID => s_EX_RegB_ID
        );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_is_lw <= test_is_lw(i);
      s_D_RegA_ID <= test_D_RegA_ID(i);
      s_D_RegB_ID <= test_D_RegB_ID(i);
      s_EX_RegB_ID <= test_EX_RegB_ID(i);
      wait for 25 ps;

      assert (s_not_en = test_not_en(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;

      assert (s_lw_reset = test_lw_reset(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;

      wait for 25 ps;
    end loop;
    wait;

  end process;

end architecture main;
