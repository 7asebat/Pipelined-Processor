library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

entity Data_Mem_Adr_Control is 
  port (clk: in std_logic;
        reset_signal: in std_logic;
        load_adr: in std_logic_vector(WORD_SIZE-1 downto 0);
        adr: out std_logic_vector(WORD_SIZE-1 downto 0));
end entity Data_Mem_Adr_Control;

architecture main of Data_Mem_Adr_Control is
  signal s_adr: std_logic_vector(WORD_SIZE-1 downto 0);
begin
  adr <= s_adr;
  process(clk, reset_signal) begin
    if (reset_signal = '1') then
      s_adr <= (others => '0');
    elsif (rising_edge(clk)) then
      s_adr <= load_adr;
    end if;
  end process;
end architecture main;
