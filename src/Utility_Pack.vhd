LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;

package Utility_Pack is
  function to_string (a: std_logic_vector) return string;
  function to_hstring (slv: std_logic_vector) return string;
  function idx (adr: std_logic_vector) return integer;
end package Utility_Pack;


-- package body section
package body Utility_Pack is
  -- Turns a vector into a binary string
  function to_string (a: std_logic_vector) return string is
    variable b:    string (1 to a'length) := (others => nul);
    variable stri: integer := 1; 
    begin
       for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
        stri := stri+1;
       end loop;
    return b;

  end function;

  -- Turns a vector into a hexadecimal string
  function to_hstring (slv: std_logic_vector) return string is
    variable l: line;
    begin
      hwrite(l, slv);
      return l.all;

  end function;

  -- Turns a vector into an integer address
  function idx (adr: std_logic_vector) return integer is
  begin
    return to_integer(unsigned(adr));

  end function idx;
end package body Utility_Pack;
