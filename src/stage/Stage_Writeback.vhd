LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY Stage_Writeback IS
PORT (
  ALU_Result : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  Memory_Load : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  IO_load : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  WB_Source : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

  WB_Result : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
);
END ENTITY Stage_Writeback;

ARCHITECTURE main OF Stage_Writeback IS
BEGIN

  WITH WB_Source(1 DOWNTO 0) SELECT
  WB_Result <=
    ALU_Result WHEN "00",
    Memory_Load WHEN "01",
    IO_load WHEN "10",
    (OTHERS => 'U') WHEN OTHERS;

END main;