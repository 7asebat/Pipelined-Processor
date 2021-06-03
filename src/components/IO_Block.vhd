library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

entity IO_Block is
  port (clk: in std_logic;
        rst: in std_logic;
        control_in: in std_logic;
        control_out: in std_logic;

        write_in: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_out: out std_logic_vector(WORD_SIZE-1 downto 0);

        signal_in: in std_logic_vector(WORD_SIZE-1 downto 0);
        signal_out: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity IO_Block;

architecture main of IO_Block is
begin
  process (clk, rst) begin
    if (rst = '1') then
      signal_out <= (others => '0');

    elsif (rising_edge(clk)) then
      if (control_out = '1') then
        signal_out <= write_in;
      end if;
    end if;

  end process;

  load_out <= signal_in;
end architecture main;
