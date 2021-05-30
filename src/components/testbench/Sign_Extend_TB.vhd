library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Sign_Extend_TB is
end entity Sign_Extend_TB;

architecture main of Sign_Extend_TB is
  constant TESTCASE_COUNT: integer := 5;
  constant INPUT_SIZE: integer := 16;
  constant OUTPUT_SIZE: integer := 32;

  type input_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(INPUT_SIZE-1 DOWNTO 0);
  type output_t is array (0 to TESTCASE_COUNT-1) of std_logic_vector(OUTPUT_SIZE-1 DOWNTO 0);

  constant test_input: input_t := (x"FFFF", x"7FFF", x"0000", x"8000", x"ABCD");
  constant test_output: output_t := (x"FFFFFFFF", x"00007FFF", x"00000000", x"FFFF8000", x"FFFFABCD"); 

  signal s_input: std_logic_vector(INPUT_SIZE-1 DOWNTO 0);
  signal s_output: std_logic_vector(OUTPUT_SIZE-1 DOWNTO 0); 

begin
  sign_extend: entity work.Sign_Extend
    port map (
      input => s_input,
      output => s_output
    );

  process begin
    for i in 0 to TESTCASE_COUNT-1 loop
      
      s_input <= test_input(i);

      wait for 25 ps;
      assert (s_output = test_output(i))
      report "FAIL: testcase " & integer'image(i)
      severity error;


      wait for 25 ps;
    end loop;
    wait;
  end process;

end architecture main;
