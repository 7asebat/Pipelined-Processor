LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY Stage_Memory IS
  PORT (
    clk : IN STD_LOGIC;

    ALU_Result : INOUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    Return_Adr : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    RegB_Data : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    RegB_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
    IO_Load : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);

    is_CALL : IN STD_LOGIC;
    Mem_Write : IN STD_LOGIC;

    Memory_Load : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
  );
END ENTITY Stage_Memory;

ARCHITECTURE main OF Stage_Memory IS
  SIGNAL Write_Data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL Mem_Address : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
  SIGNAL Read_Data : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
BEGIN

  data_memory : ENTITY work.Memory
    GENERIC MAP(
      n => 2 ** 16,
      m => 16
    )
    PORT MAP(
      clk => clk,
      address => Mem_Address(15 DOWNTO 0),
      write_data => Write_Data,
      mem_write => Mem_Write,
      data_out => Read_Data
    );

  WITH is_CALL SELECT
    Write_Data <=
    RegB_Data WHEN '0',
    Return_Adr WHEN '1',
    (OTHERS => 'U') WHEN OTHERS;

  Mem_Address <= ALU_Result;
  Memory_Load <= Read_Data;
END main;