library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

ENTITY Sign_Extend IS
  GENERIC (INPUT_SIZE: integer := 16; OUTPUT_SIZE: integer := 32);

  PORT (
    input: IN std_logic_vector(INPUT_SIZE - 1 DOWNTO 0);
    output: OUT std_logic_vector(OUTPUT_SIZE - 1  DOWNTO 0)
  );

END ENTITY;

ARCHITECTURE main OF Sign_Extend IS
BEGIN

output(INPUT_SIZE - 1 DOWNTO 0) <= input(INPUT_SIZE - 1 DOWNTO 0);
output(OUTPUT_SIZE - 1 DOWNTO INPUT_SIZE) <= (OTHERS => input(INPUT_SIZE - 1));

END ARCHITECTURE;