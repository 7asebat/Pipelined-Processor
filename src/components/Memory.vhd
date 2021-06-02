
Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;
use IEEE.math_real.all;

ENTITY Memory IS 
  GENERIC(
    n: INTEGER := 1024;
    m: INTEGER := 16
  );
  PORT(
    address: IN std_logic_vector(integer(ceil(log2(real(n))))-1 DOWNTO 0);
    data_out: OUT std_logic_vector((m*2)-1 DOWNTO 0);
    write_data: IN std_logic_vector((m*2) -1 DOWNTO 0);
    mem_write: IN std_logic
  ); 
END ENTITY;

ARCHITECTURE main OF Memory IS
	
  TYPE ram_type IS ARRAY(0 TO n-1) of std_logic_vector(m-1 DOWNTO 0);
  SIGNAL ram: ram_type := (
    -- initialize here 
    OTHERS => (X"0000")
  );
BEGIN

process (mem_write)
begin
    if mem_write = '1' then
        ram(to_integer(unsigned(address))) <= write_data(m-1 DOWNTO 0);
	      ram(to_integer(unsigned(address))+1) <= write_data(m*2-1 DOWNTO m);
    end if;
end process;
  data_out <= ram(to_integer(unsigned(address))) & ram(to_integer(unsigned(address))+1) ;
end architecture;