library IEEE;
use IEEE.std_logic_1164.all;

ENTITY Flags_File IS
  -- 2: Z
  -- 1: N
  -- 0: C
  PORT (
      clk: IN std_logic;
      flags_in: IN std_logic_vector(2 DOWNTO 0);
      flags_set: IN std_logic_vector(2 DOWNTO 0);
      flags_reset: IN std_logic_vector(2 DOWNTO 0);
      flags_out: OUT std_logic_vector(2 DOWNTO 0);
      flags_en: IN std_logic
  );

END ENTITY;

ARCHITECTURE main OF Flags_File IS
BEGIN
  PROCESS(clk, flags_set, flags_reset) BEGIN
    IF (rising_edge(clk)) THEN
      FOR i IN 0 TO 2 LOOP
        IF(flags_set(i) = '1') THEN
          flags_out(i) <= '1';
        ELSIF(flags_reset(i) = '1') THEN
          flags_out(i) <= '0';
        ELSIF(flags_en = '1') THEN
          flags_out(i) <= flags_in(i);
        END IF;
      END LOOP;
    END IF;
  END PROCESS;

END ARCHITECTURE;