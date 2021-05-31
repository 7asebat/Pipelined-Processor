library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Data_Mem_Adr_Control_TB is
end entity Data_Mem_Adr_Control_TB;

architecture main of Data_Mem_Adr_Control_TB is
  constant TESTCASE_COUNT: integer := 3;

  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic;
  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(IR_SIZE-1 downto 0);

  constant test_reset_signal: control_t := ('1', '0', '0');
  constant test_load_adr: word_t := (X"F000_0000", X"7000_0000", X"8000_FFFF");
  constant test_adr: word_t := (X"0000_0000", X"7000_0000", X"8000_FFFF");

  signal s_clk: std_logic;
  signal s_reset_signal: std_logic;
  signal s_load_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_adr: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  pic: entity work.Data_Mem_Adr_Control
    port map (clk => s_clk,
              reset_signal => s_reset_signal,
              load_adr => s_load_adr,
              adr => s_adr);
  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      -- Set data up before rising edge
      s_clk <= '0';
        s_reset_signal <= test_reset_signal(i);
        s_load_adr <= test_load_adr(i);

      wait for 50 ps;
      s_clk <= '1';
      wait for 50 ps;

      assert (s_adr = test_adr(i))
      report "FAIL: case " & integer'image(i) & " "
        & "increment = " & to_hstring(s_adr) & " "
        & "expected  = " & to_hstring(test_adr(i))
      severity error;
    end loop;
    wait;

  end process;

end architecture main;
