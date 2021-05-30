library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity SP_Controller_TB is
end entity SP_Controller_TB;

architecture main of SP_Controller_TB is
  constant TESTCASE_COUNT: integer := 5;
  constant WORD_SIZE: integer := 32;

  constant SP_PUSH: std_logic_vector(1 downto 0) := b"00";
  constant SP_PUSH_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"FFFF_FFFE";

  constant SP_POP: std_logic_vector(1 downto 0) := b"01";
  constant SP_POP_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0002";

  constant SP_UNDEF: std_logic_vector(1 downto 0) := b"11";

  -- Default value specified in the document (2^32-2)
  constant SP_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"40_00_00_00";

  type push_or_pop_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(1 downto 0);
  type SP_out_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0);

  constant test_push_or_pop: push_or_pop_t := (SP_PUSH, SP_POP, SP_POP, SP_UNDEF, SP_UNDEF);
  constant test_SP_out: SP_out_t := (
    SP_DEFAULT,
    SP_DEFAULT + SP_PUSH_INCREMENT,
    SP_DEFAULT,
    SP_DEFAULT + SP_POP_INCREMENT,
    SP_DEFAULT + SP_POP_INCREMENT
  );

  signal s_reset: std_logic;
  signal s_clk: std_logic;
  signal s_push_or_pop: std_logic_vector(1 downto 0);
  signal s_SP_out: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  sp_controller: entity work.SP_Controller 
    generic map (WORD_SIZE)
    port map (clk => s_clk,
              reset => s_reset,
              push_or_pop => s_push_or_pop,
              SP_out => s_SP_out);

  process begin
    s_reset <= '1';
    wait for 50 ps;
    s_reset <= '0';

    for i in 0 to TESTCASE_COUNT-1 loop
      -- Start with a rising edge
      s_clk <= '0';

      s_push_or_pop <= test_push_or_pop(i);
      wait for 50 ps;

      -- Read previous state on a rising edge
      s_clk <= '1';
      wait for 50 ps;

      assert (s_SP_out = test_SP_out(i))
      report "FAIL: case " & integer'image(i)
        & " SP = " & to_hstring(s_SP_out)
        & ", expected " & to_hstring(test_SP_out(i))
      severity error;
    end loop;
    wait;
  end process;
end architecture main;
