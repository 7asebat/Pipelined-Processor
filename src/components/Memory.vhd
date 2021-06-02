LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY Memory IS
  GENERIC (
    n : INTEGER := 1024;
    m : INTEGER := 16
  );
  PORT (
    clk : IN STD_LOGIC;
    address : IN STD_LOGIC_VECTOR(INTEGER(ceil(log2(real(n)))) - 1 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR((m * 2) - 1 DOWNTO 0);
    write_data : IN STD_LOGIC_VECTOR((m * 2) - 1 DOWNTO 0);
    mem_write : IN STD_LOGIC
  );
END ENTITY;

ARCHITECTURE main OF Memory IS

  TYPE ram_type IS ARRAY(0 TO n - 1) OF STD_LOGIC_VECTOR(m - 1 DOWNTO 0);
  SIGNAL ram : ram_type := (
    -- initialize here 
    OTHERS => (X"0000")
  );
BEGIN

  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF mem_write = '1' THEN
        ram(to_integer(unsigned(address))) <= write_data(m - 1 DOWNTO 0);
        ram(to_integer(unsigned(address)) + 1) <= write_data(m * 2 - 1 DOWNTO m);
      END IF;
    END IF;

  END PROCESS;
  data_out <= ram(to_integer(unsigned(address))) & ram(to_integer(unsigned(address)) + 1);
END ARCHITECTURE;