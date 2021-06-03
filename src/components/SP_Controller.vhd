library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

-- Stack Pointer Controller
entity SP_Controller is
  port (clk: in std_logic;
        reset: in std_logic;
        push_or_pop: in std_logic_vector(1 downto 0);
        SP_out: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity SP_Controller;

architecture main of SP_Controller is
  signal SP_value: std_logic_vector(WORD_SIZE-1 downto 0) := SP_DEFAULT;

begin
  process(clk, reset) begin
    if (reset = '1') then
      SP_value <= SP_DEFAULT;

    elsif (falling_edge(clk)) then
      case push_or_pop is 
        when SP_PUSH => SP_value <= SP_value + SP_PUSH_INCREMENT;
        when SP_POP  => SP_value <= SP_value + SP_POP_INCREMENT;
        when others  => null;
      end case;

    elsif (rising_edge(clk)) then
      SP_out <= SP_value;
    end if;
  end process;
end architecture main;
