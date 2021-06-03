library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Register_File is
  port (clk: in std_logic;
        write_en: in std_logic;

        read_regA_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        read_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);

        write_reg_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        write_data: in std_logic_vector(WORD_SIZE-1 downto 0);

        regA_data: out std_logic_vector(WORD_SIZE-1 downto 0);
        regB_data: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity Register_File;

architecture main of Register_File is
  type reg_file_t is array (0 to REG_COUNT-1) of std_logic_vector(WORD_SIZE-1 downto 0); 

  signal reg_file: reg_file_t := (
    others => (others => '0') 
  );

begin
  process(clk) begin
    -- Write to file on falling edge
    if (falling_edge(clk) and write_en = '1') then
      reg_file(idx(write_reg_ID)) <= write_data;
    end if;

  end process;
  regA_data <= reg_file(idx(read_regA_ID));
  regB_data <= reg_file(idx(read_regB_ID));

end architecture main;