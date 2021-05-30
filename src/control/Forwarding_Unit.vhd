library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

entity Forwarding_Unit is 
  port (EX_regA_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        EX_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        WB_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        MEM_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        

        EX_regA_data: in std_logic_vector(WORD_SIZE-1 downto 0);
        EX_regB_data: in std_logic_vector(WORD_SIZE-1 downto 0);
        MEM_ALU_result: in std_logic_vector(WORD_SIZE-1 downto 0);
        WB_result: in std_logic_vector(WORD_SIZE-1 downto 0);

        forwardA: out std_logic_vector(WORD_SIZE-1 downto 0);
        forwardB: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity Forwarding_Unit;

architecture main of Forwarding_Unit is
begin
  forwardA <= 
    MEM_ALU_result when EX_regA_ID = MEM_regB_ID else 
    WB_result      when EX_regA_ID = WB_regB_ID  else 
    EX_regA_data;

  forwardB <= 
    MEM_ALU_result when EX_regB_ID = MEM_regB_ID else 
    WB_result      when EX_regB_ID = WB_regB_ID  else 
    EX_regB_data;
end architecture main;