library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Stalling_Unit is 
  port (
    is_lw : IN std_logic;
    lw_reset: OUT std_logic;
    not_en : OUT std_logic;
    D_RegA_ID : IN std_logic_vector(3 DOWNTO 0);
    D_RegB_ID : IN std_logic_vector(3 DOWNTO 0);
    EX_RegB_ID : IN std_logic_vector(3 DOWNTO 0)
  );

end entity Stalling_Unit;

architecture main of Stalling_Unit is
  SIGNAL D_RegA_ID : std_logic_vector(3 DOWNTO 0);
  SIGNAL D_RegB_ID : std_logic_vector(3 DOWNTO 0);
  SIGNAL activate: std_logic;

  activate <=
    '1' WHEN is_lw and (EX_RegB_ID = D_RegA_ID or EX_RegB_ID = D_RegB_ID)
    '0' WHEN OTHERS;

  lw_reset <= activate;
  not_en <= not(activate);
begin 


  
end architecture main;