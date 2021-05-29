library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Flags_File_TB is
end entity Flags_File_TB;

architecture main of Flags_File_TB is
  constant TESTCASE_COUNT: integer := 5;
  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic;
  type flags_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(2 downto 0);

  constant test_flags_en: control_t := ('1', '1', '1', '1', '0');
  constant test_flags_set: flags_t := ("111", "000", "101", "000", "001"); 
  constant test_flags_reset: flags_t := ("000", "111", "010", "000", "100"); 
  constant test_flags_in: flags_t := ("000", "000", "000", "110", "110"); 
  constant test_flags_out: flags_t := ("111", "000", "101", "110", "011"); 

  signal s_clk: std_logic;
  signal s_flags_en: std_logic;
  signal s_flags_set: std_logic_vector(2 downto 0);
  signal s_flags_reset: std_logic_vector(2 downto 0);
  signal s_flags_in: std_logic_vector(2 downto 0);
  signal s_flags_out: std_logic_vector(2 downto 0);


begin
  reg_file: entity work.Flags_File
    port map (
      clk => s_clk,
      flags_en => s_flags_en, 
      flags_set => s_flags_set,
      flags_reset => s_flags_reset,
      flags_in => s_flags_in,
      flags_out => s_flags_out
    );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      s_clk <= '0';

      s_flags_en <= test_flags_en(i);
      s_flags_set <= test_flags_set(i);
      s_flags_reset <= test_flags_reset(i);
      s_flags_in <= test_flags_in(i);

      wait for 50 ps;

      s_clk <= '1';

      wait for 25 ps;
      assert (s_flags_out = test_flags_out(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;


      wait for 25 ps;
    end loop;
    wait;
  end process;

end architecture main;
