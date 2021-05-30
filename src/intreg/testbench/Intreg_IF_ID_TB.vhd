library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Intreg_IF_ID_TB is
end entity;

architecture main of Intreg_IF_ID_TB is
  constant TESTCASE_COUNT: integer := 5;

  -- (EN, RST)
  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(1 downto 0);
  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);

  constant test_control: control_t := (b"11", b"10", b"10", b"00", b"10");

  constant test_load_return_adr: word_t := (x"0000_1111",
                                            x"0000_2222",
                                            x"0000_3333",
                                            x"0000_4444",
                                            x"0000_5555");

  constant test_return_adr: word_t := (x"0000_0000",
                                       x"0000_2222",
                                       x"0000_3333",
                                       x"0000_3333",
                                       x"0000_5555");

  constant test_load_IR: word_t := (x"AAAA_0000",
                                    x"BBBB_0000",
                                    x"CCCC_0000",
                                    x"DDDD_0000",
                                    x"EEEE_0000");


  constant test_IR: word_t := (x"E800_0000", -- NOP
                               x"BBBB_0000",
                               x"CCCC_0000",
                               x"CCCC_0000",
                               x"EEEE_0000");

  signal s_load_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_load_IR: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_clk: std_logic;
  signal s_en: std_logic;
  signal s_rst: std_logic;

  signal s_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_IR: std_logic_vector(WORD_SIZE-1 downto 0);


begin
  intreg: entity work.Intreg_IF_ID
    port map (clk => s_clk,
              en => s_en,
              rst => s_rst,
              load_return_adr => s_load_return_adr,
              load_IR => s_load_IR,
              return_adr => s_return_adr,
              IR => s_IR);
  
  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      -- Set data up before rising edge
      s_clk <= '0';
        s_en <= test_control(i)(1);
        s_rst <= test_control(i)(0);

        s_load_return_adr <= test_load_return_adr(i);
        s_load_IR <= test_load_IR(i);

      wait for 50 ps;
      s_clk <= '1';
      wait for 50 ps;

      -- Assert data after rising edge
      assert ((s_return_adr = test_return_adr(i)) and (s_IR = test_IR(i)))
      report "FAIL: case " & integer'image(i) & LF
        & "RetAdr, IR = (" & to_hstring(s_return_adr) & ", " & to_hstring(s_IR) & ")" & LF
        & "expected   = (" & to_hstring(test_return_adr(i)) & ", " & to_hstring(test_IR(i)) & ") "
      severity error;

    end loop;
  end process;
end architecture main;
