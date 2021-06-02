LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY PC_Controller IS
    PORT (
        j_pc_src_ctrl : IN STD_LOGIC;
        ret_pc_src_ctrl : IN STD_LOGIC;
        en : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        inc_sel : IN STD_LOGIC;
        wb_result : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        jmp_address : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        reset : IN STD_LOGIC;
        PC_DEFAULT : IN STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        return_adr : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
        inst_address : OUT STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0)
    );

END ENTITY PC_Controller;

ARCHITECTURE main OF PC_Controller IS
    SIGNAL PC_value : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL SEL : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL adder_address_in : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL intermediate_inst_address : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL adder_out : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
BEGIN
    SEL <= ret_pc_src_ctrl & j_pc_src_ctrl;
    return_adr <= adder_out;

    WITH SEL SELECT
        intermediate_inst_address <= PC_value WHEN "00",
        jmp_address WHEN "01",
        wb_result WHEN OTHERS;

    adder_address_in <= intermediate_inst_address;

    inst_address <= intermediate_inst_address;
    WITH inc_sel SELECT
        adder_out <= adder_address_in + 1 WHEN '0',
        adder_address_in + 2 WHEN OTHERS;

    PROCESS (clk)
    BEGIN
        IF (reset = '1') THEN
            PC_value <= PC_DEFAULT;
        ELSIF (rising_edge(clk) AND en = '1') THEN
            PC_value <= adder_out;
        END IF;
    END PROCESS;

END ARCHITECTURE main;