library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity IO_Block_TB is
end entity IO_Block_TB;

architecture main of IO_Block_TB is
  constant TESTCASE_COUNT: integer := 3;
  constant WORD_SIZE: integer := 32;

  type control_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(0 to 1);
  type word_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);

  constant test_control: control_t := (b"10", "01", "00");

  constant test_signal_in: word_t := (x"DEAD_BEEF", x"DEAD_DEAD", x"BEEF_BEEF");
  constant test_load_out: word_t := (x"DEAD_BEEF", x"DEAD_BEEF", x"DEAD_BEEF");

  constant test_write_in: word_t := (x"BADD_DDAB", x"FEDD_DEAD", x"0123_4567");
  constant test_signal_out: word_t := ((others => 'Z'), x"FEDD_DEAD", x"FEDD_DEAD");

  signal s_clk: std_logic;
  signal s_control_in: std_logic;
  signal s_control_out: std_logic;
  signal s_write_in: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_load_out: std_logic_vector(WORD_SIZE-1 downto 0) := (others => 'Z');
  signal s_signal_in: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_signal_out: std_logic_vector(WORD_SIZE-1 downto 0) := (others => 'Z');

begin
  io_block: entity work.IO_Block
    generic map (WORD_SIZE)
    port map (clk => s_clk,
              control_in => s_control_in,
              control_out => s_control_out,
              write_in => s_write_in,
              load_out => s_load_out,
              signal_in => s_signal_in,
              signal_out => s_signal_out);

    process begin
      for i in 0 to TESTCASE_COUNT-1 loop
        s_control_in <= test_control(i)(0);
        s_control_out <= test_control(i)(1);
        s_signal_in <= test_signal_in(i);
        s_write_in <= test_write_in(i);

        s_clk <= '0';
        wait for 50 ps;
        s_clk <= '1';
        wait for 50 ps;

        assert (s_load_out = test_load_out(i) and s_signal_out = test_signal_out(i))
        report "FAIL: case " & integer'image(i)
        severity error;
      end loop;
      wait;
    end process;
end architecture main;
