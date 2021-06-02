library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

entity Stalling_Unit is 
  port (
    is_lw : IN std_logic;
    lw_reset: OUT std_logic;
    not_en : OUT std_logic;
    D_RegA_ID : IN std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);
    D_RegB_ID : IN std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0);
    EX_RegB_ID : IN std_logic_vector(REG_ADR_WIDTH-1 DOWNTO 0)
  );

end entity Stalling_Unit;

architecture main of Stalling_Unit is
  SIGNAL activate: std_logic;
begin
  activate <=
    '1' WHEN (is_lw = '1') and (EX_RegB_ID = D_RegA_ID or EX_RegB_ID = D_RegB_ID) else
    '0';

  lw_reset <= activate;
  not_en <= not(activate);
end architecture main;