library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Intreg_EX_MEM is
  port (clk: in std_logic;
        en: in std_logic;
        rst: in std_logic;

        -- NOTE(Abdelrahman) We don't need all control signals here but this
        -- gives a cleaner port layout
        load_control_signals: in control_signals_t;
        load_flags: in std_logic_vector(FLAGS_COUNT-1 downto 0);
        load_ALU_result: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_return_adr: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_regB_data: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        load_IO_load: in std_logic_vector(WORD_SIZE-1 downto 0);

        control_signals: out control_signals_t;
        flags: out std_logic_vector(FLAGS_COUNT-1 downto 0);
        ALU_result: out std_logic_vector(WORD_SIZE-1 downto 0);
        return_adr: out std_logic_vector(WORD_SIZE-1 downto 0);
        regB_data: out std_logic_vector(WORD_SIZE-1 downto 0);
        regB_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        IO_load: out std_logic_vector(WORD_SIZE-1 downto 0));

end entity Intreg_EX_MEM;

architecture main of Intreg_EX_MEM is
  signal s_control_signals: control_signals_t;
  signal s_flags: std_logic_vector(FLAGS_COUNT-1 downto 0);
  signal s_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_IO_load: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  control_signals <= s_control_signals;
  flags <= s_flags;
  ALU_result <= s_ALU_result;
  return_adr <= s_return_adr;
  regB_data <= s_regB_data;
  regB_ID <= s_regB_ID;
  IO_load <= s_IO_load;

  process(clk, rst) begin
    -- TODO(Abdelrahman) Reset this register properly
    if (rst = '1') then
      s_control_signals <= CTRL_NOP;
      s_flags <= (others => '0');
      s_ALU_result <= (others => '0');
      s_return_adr <= (others => '0');
      s_regB_data <= (others => '0');
      s_regB_ID <= (others => '0');
      s_IO_load <= (others => '0');

    elsif (rising_edge(clk) and en = '1') then
      s_control_signals <= load_control_signals;
      s_flags <= load_flags;
      s_ALU_result <= load_ALU_result;
      s_return_adr <= load_return_adr;
      s_regB_data <= load_regB_data;
      s_regB_ID <= load_regB_ID;
      s_IO_load <= load_IO_load;
    end if;
  end process;
end architecture main;
