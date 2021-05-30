library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity IO_Block is
  generic (WORD_SIZE: integer := 32);

  port (clk: in std_logic;
        control_in: in std_logic;
        control_out: in std_logic;

        write_in: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_out: out std_logic_vector(WORD_SIZE-1 downto 0);

        signal_in: in std_logic_vector(WORD_SIZE-1 downto 0);
        signal_out: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity IO_Block;

architecture main of IO_Block is
begin
  process (clk) begin
    if (rising_edge(clk)) then
      if (control_in = '1') then
        load_out <= signal_in;

      elsif (control_out = '1') then
        signal_out <= write_in;
      end if;

    end if;
  end process;
end architecture main;
