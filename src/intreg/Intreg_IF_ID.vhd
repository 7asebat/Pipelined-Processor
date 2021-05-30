library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Intreg_IF_ID is
  port (clk: in std_logic;
        en: in std_logic;
        rst: in std_logic;

        load_return_adr: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_IR: in std_logic_vector(WORD_SIZE-1 downto 0);

        return_adr: out std_logic_vector(WORD_SIZE-1 downto 0);
        IR: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity Intreg_IF_ID;

architecture main of Intreg_IF_ID is
  constant OP_NOP: std_logic_vector(5 downto 0) := b"11_10_10";

  signal s_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_IR: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  return_adr <= s_return_adr;
  IR <= s_IR;

  process(clk, rst) begin
    if (rst = '1') then
      s_return_adr <= (OTHERS => '0');
      s_IR(WORD_SIZE-1 downto WORD_SIZE-6) <= OP_NOP; 
      s_IR(WORD_SIZE-7 downto 0) <= (OTHERS => '0'); -- NOP

    elsif (rising_edge(clk) and en = '1') then
      s_return_adr <= load_return_adr;
      s_IR <= load_IR;
    end if;
  end process;
end architecture main;
