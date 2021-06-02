LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.Utility_Pack.ALL;

ENTITY Stalling_Unit IS
  PORT (
    is_lw : IN STD_LOGIC;
    lw_reset : OUT STD_LOGIC;
    not_en : OUT STD_LOGIC;
    D_RegA_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
    D_RegB_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0);
    EX_RegB_ID : IN STD_LOGIC_VECTOR(REG_ADR_WIDTH - 1 DOWNTO 0)
  );

END ENTITY Stalling_Unit;

ARCHITECTURE main OF Stalling_Unit IS
  SIGNAL activate : STD_LOGIC;
BEGIN
  activate <=
    '1' WHEN (is_lw = '1') AND (EX_RegB_ID = D_RegA_ID OR EX_RegB_ID = D_RegB_ID) ELSE
    '0';

  lw_reset <= activate;
  not_en <= activate;
END ARCHITECTURE main;