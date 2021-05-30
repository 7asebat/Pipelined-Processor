library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Register_File_TB is
end entity Register_File_TB;

architecture main of Register_File_TB is
  constant TESTCASE_COUNT: integer := 5;
  constant WORD_SIZE: integer := 32;
  constant REG_COUNT: integer := 8;
  constant REG_ADR_WIDTH: integer := 3;

  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic;
  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);
  type adr_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(REG_ADR_WIDTH-1 downto 0);

  constant test_write_en: control_t := ('1', '1', '1', '1', '0');
  constant test_write_reg_ID: adr_t := (o"0", o"1", o"2", o"3", o"4"); 
  constant test_write_data: word_t := (x"DEAD_BEEF", 
                                       x"DEAD_DEAD", 
                                       x"BEEF_BEEF", 
                                       x"1234_5678", 
                                       x"DEAD_BEEF"); 

  constant test_read_regA_ID: adr_t := (o"0", o"0", o"0", o"2", o"2"); 
  constant test_regA_data: word_t := (x"0000_0000", 
                                      x"DEAD_BEEF", 
                                      x"DEAD_BEEF", 
                                      x"BEEF_BEEF", 
                                      x"BEEF_BEEF"); 

  constant test_read_regB_ID: adr_t := (o"0", o"1", o"1", o"1", o"3"); 
  constant test_regB_data: word_t := (x"0000_0000", 
                                      x"0000_0000", 
                                      x"DEAD_DEAD", 
                                      x"DEAD_DEAD", 
                                      x"1234_5678"); 

  signal s_clk: std_logic;
  signal s_write_en: std_logic;
  signal s_read_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_read_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_write_reg_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_write_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regA_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  reg_file: entity work.Register_File
    generic map (WORD_SIZE, REG_COUNT, REG_ADR_WIDTH)
    port map (clk => s_clk,
              write_en => s_write_en, 
              read_regA_ID => s_read_regA_ID,
              read_regB_ID => s_read_regB_ID,
              write_reg_ID => s_write_reg_ID,
              write_data => s_write_data,
              regA_data => s_regA_data,
              regB_data => s_regB_data);

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      -- Start with a rising edge
      s_clk <= '0';

      s_read_regA_ID <= test_read_regA_ID(i);
      s_read_regB_ID <= test_read_regB_ID(i);
      wait for 50 ps;

      -- Read previous state on a rising edge
      s_clk <= '1';

      -- Write data on the next falling edge 
      s_write_en <= test_write_en(i);
      s_write_reg_ID <= test_write_reg_ID(i);
      s_write_data <= test_write_data(i);
      wait for 50 ps;

      assert (s_regA_data = test_regA_data(i) and s_regB_data = test_regB_data(i))
      report "FAIL: case " & integer'image(i) & " "
        & "RA, RB   = (" & to_hstring(s_regA_data) & ", " & to_hstring(s_regB_data) & ") "
        & "expected = (" & to_hstring(test_regA_data(i)) & ", " & to_hstring(test_regB_data(i)) & ") "
      severity error;

    end loop;
    wait;
  end process;

end architecture main;
