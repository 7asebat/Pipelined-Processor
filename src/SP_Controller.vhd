-- Stack Pointer Controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity SP_Controller is
  generic (WORD_SIZE: integer := 32);

  port (clk: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        push_or_pop: in std_logic;
        SP_out: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity SP_Controller;

architecture main of SP_Controller is
  constant SP_PUSH: std_logic := '0';
  constant SP_PUSH_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"FFFF_FFFE";

  constant SP_POP: std_logic := '1';
  constant SP_POP_INCREMENT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0002";

  -- Default value specified in the document (2^32-2)
  constant SP_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"4000_0000";

  signal SP_value: std_logic_vector(WORD_SIZE-1 downto 0) := SP_DEFAULT;

begin
  process(clk, reset) begin
    if (reset = '1') then
      SP_value <= SP_DEFAULT;

    elsif (rising_edge(clk) and enable = '1') then
      case push_or_pop is 
        when SP_PUSH =>
          SP_value <= SP_value + SP_PUSH_INCREMENT;

        when SP_POP =>
          SP_value <= SP_value + SP_POP_INCREMENT;

        when others => null;
      end case;
    end if;
  end process;
  SP_out <= SP_value;
end architecture main;
