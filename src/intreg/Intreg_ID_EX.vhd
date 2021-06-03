library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.Utility_Pack.all;

entity Intreg_ID_EX is
  port (clk: in std_logic;
        en: in std_logic;
        rst: in std_logic;
        flush: in std_logic;

        load_control_signals: in control_signals_t;
        load_return_adr: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_imm_value: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_regA_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        load_regB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        load_regA_data: in std_logic_vector(WORD_SIZE-1 downto 0);
        load_regB_data: in std_logic_vector(WORD_SIZE-1 downto 0);

        control_signals: out control_signals_t;
        return_adr: out std_logic_vector(WORD_SIZE-1 downto 0);
        imm_value: out std_logic_vector(WORD_SIZE-1 downto 0);
        regA_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        regB_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        regA_data: out std_logic_vector(WORD_SIZE-1 downto 0);
        regB_data: out std_logic_vector(WORD_SIZE-1 downto 0));
end entity Intreg_ID_EX;

architecture main of Intreg_ID_EX is
  signal s_control_signals: control_signals_t;
  signal s_return_adr: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_imm_value: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0);
  signal s_regA_data: std_logic_vector(WORD_SIZE-1 downto 0);
  signal s_regB_data: std_logic_vector(WORD_SIZE-1 downto 0);

begin
  control_signals <= s_control_signals;
  return_adr <= s_return_adr;
  imm_value <= s_imm_value;
  regA_ID <= s_regA_ID;
  regB_ID <= s_regB_ID;
  regA_data <= s_regA_data;
  regB_data <= s_regB_data;

  process(clk, rst) begin
    -- TODO(Abdelrahman) Reset this register properly
    if (rst = '1') then
      s_control_signals <= CTRL_NOP;
      s_return_adr <= (others => '0');
      s_imm_value <= (others => '0');
      s_regA_ID <= (others => '0');
      s_regB_ID <= (others => '0');
      s_regA_data <= (others => '0');
      s_regB_data <= (others => '0');
    
    elsif (rising_edge(clk) and flush = '1') then
      s_control_signals <= CTRL_NOP;
      s_return_adr <= (others => '0');
      s_imm_value <= (others => '0');
      s_regA_ID <= (others => '0');
      s_regB_ID <= (others => '0');
      s_regA_data <= (others => '0');
      s_regB_data <= (others => '0');

    elsif (rising_edge(clk) and en = '1') then
      s_control_signals <= load_control_signals;
      s_return_adr <= load_return_adr;
      s_imm_value <= load_imm_value;
      s_regA_ID <= load_regA_ID;
      s_regB_ID <= load_regB_ID;
      s_regA_data <= load_regA_data;
      s_regB_data <= load_regB_data;
    end if;
  end process;
end architecture main;
