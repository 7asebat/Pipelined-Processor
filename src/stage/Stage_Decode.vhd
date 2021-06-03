library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.utility_pack.all;

entity Stage_Decode is
port (
    clk: in std_logic;
    rst: in std_logic;

    IR: in std_logic_vector(WORD_SIZE-1 downto 0);

    -- Feedback values
    Reg_write: in std_logic;
    Reg_write_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    Reg_write_data: in std_logic_vector(WORD_SIZE-1 downto 0);

    is_lw: in std_logic;
    EX_RegB_ID: in std_logic_vector(REG_ADR_WIDTH-1 downto 0);

    control_signals: out control_signals_t;
    imm_value: out std_logic_vector(WORD_SIZE-1 downto 0);
    regA_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    regB_ID: out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
    regA_data: out std_logic_vector(WORD_SIZE-1 downto 0);
    regB_data: out std_logic_vector(WORD_SIZE-1 downto 0);

    -- Disables the PC if high
    enable_n: out std_logic;
    lw_reset: out std_logic
);
end entity Stage_Decode;

architecture main of Stage_Decode is
    signal s_enable: std_logic;
    signal s_IR: std_logic_vector(WORD_SIZE-1 downto 0);

    signal s_increment: std_logic;
    signal s_instruction_address: std_logic_vector(WORD_SIZE-1 downto 0);
    signal s_return_address: std_logic_vector(WORD_SIZE-1 downto 0);
    signal s_control_signals: control_signals_t;

    constant PC_DEFAULT: std_logic_vector(WORD_SIZE-1 downto 0) := X"0000_0000";

    alias instruction_lower: std_logic_vector(WORD_SIZE/2-1 downto 0) is IR(WORD_SIZE/2-1 downto 0);
    -- TODO(Abdelrahman) Extract constants
    alias instruction_regA_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0) is IR(21 downto 19);
    alias instruction_regB_ID: std_logic_vector(REG_ADR_WIDTH-1 downto 0) is IR(18 downto 16);

begin
    regA_ID <= instruction_regA_ID;
    regB_ID <= instruction_regB_ID;

    control_signals <= s_control_signals;

    ctrl_unit: entity work.Control_Unit
    port map (
        IR => IR,
        control_signals => s_control_signals
    );

    sign_ext: entity work.Sign_Extend
    generic map (WORD_SIZE/2, WORD_SIZE)
    port map (
        input => instruction_lower,
        output => imm_value
    );

    reg_file: entity work.Register_File
    port map (
        clk => clk,
        write_en => Reg_write,

        read_regA_ID => instruction_regA_ID,
        read_regB_ID => instruction_regB_ID,

        write_reg_ID => Reg_write_ID,
        write_data => Reg_write_data,

        regA_data => regA_data,
        regB_data => regB_data
    );

    stall: entity work.Stalling_Unit
    port map (
        clk => clk,
        is_lw => is_lw,
        lw_reset => lw_reset,
        not_en => enable_n,
        IR => IR,
        EX_RegB_ID => EX_RegB_ID
    );

end main;