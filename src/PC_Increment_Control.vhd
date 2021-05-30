library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity PC_Increment_Control is 
  generic (IR_SIZE: integer := 32);

  port (IR: in std_logic_vector(IR_SIZE-1 downto 0);
        increment: out std_logic);

end entity PC_Increment_Control;

architecture main of PC_Increment_Control is
begin
  increment <= IR(IR_SIZE-1);
end architecture main;
