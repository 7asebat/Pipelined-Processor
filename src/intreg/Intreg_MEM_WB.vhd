library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Intreg_MEM_WB is
  port (clk: in std_logic;
        en: in std_logic;
        rst: in std_logic;

        -- NOTE(Abdelrahman) We don't need all control signals here but this
        -- gives a cleaner port layout
        load_reset_signal: in std_logic;
        load_control_signals: in control_signals_t;
        load_ALU_result: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_MEM_load: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_IO_load: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);

        reset_signal: out std_logic;
        control_signals: out control_signals_t;
        ALU_result: out std_logic_vector(WORD_SIZE-1 downto 0);
        MEM_load: out std_logic_vector(WORD_SIZE-1 downto 0);
        IO_load: out std_logic_vector(WORD_SIZE-1 downto 0);
        regB_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0));

end entity Intreg_MEM_WB;

architecture main of Intreg_MEM_WB is
  signal s_reset_signal: std_logic;
  signal s_control_signals: control_signals_t;
  signal s_ALU_result: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_MEM_load: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_IO_load: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);

begin
  reset_signal <= s_reset_signal;
  control_signals <= s_control_signals;
  ALU_result <= s_ALU_result;
  MEM_load <= s_MEM_load;
  IO_load <= s_IO_load;
  regB_ID <= s_regB_ID;

  process(clk, rst) begin
    -- TODO(Abdelrahman) Reset this register properly
    if (rst = '1') then
      s_reset_signal <= '0';
      s_control_signals <= CTRL_NOP;
      s_ALU_result <= (others => '0');
      s_MEM_load <= (others => '0');
      s_IO_load <= (others => '0');
      s_regB_ID <= (others => '0');

    elsif (rising_edge(clk) and en = '1') then
      s_reset_signal <= load_reset_signal;
      s_control_signals <= load_control_signals;
      s_ALU_result <= load_ALU_result;
      s_MEM_load <= load_MEM_load;
      s_IO_load <= load_IO_load;
      s_regB_ID <= load_regB_ID;
    end if;
  end process;
end architecture main;
