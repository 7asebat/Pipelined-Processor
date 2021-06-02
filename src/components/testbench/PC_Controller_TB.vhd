LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.utility_pack.ALL;

ENTITY PC_Controller_TB IS
END ENTITY PC_Controller_TB;

ARCHITECTURE main OF PC_Controller_TB IS
    CONSTANT TESTCASE_COUNT : INTEGER := 10;
    TYPE PC_out_t IS ARRAY (0 TO TESTCASE_COUNT - 1) OF STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    TYPE logic_t IS ARRAY (0 TO TESTCASE_COUNT - 1) OF STD_LOGIC;
    CONSTANT test_enable : logic_t := ('1', '1', '1', '1', '1', '1', '1', '1', '1', '0');
    CONSTANT test_jmp_addr : logic_t := ('0', '0', '0', '0', '0', '0', '1', '0', '0', '0');
    CONSTANT test_wb : logic_t := ('0', '0', '0', '1', '0', '0', '0', '0', '0', '0');
    CONSTANT test_inc_sel : logic_t := ('0', '1', '0', '0', '1', '0', '0', '1', '0', '0');
    CONSTANT test_reset : logic_t := ('1', '0', '0', '0', '0', '0', '0', '0', '0', '0');

    SIGNAL s_enable : STD_LOGIC;
    SIGNAL s_reset : STD_LOGIC;
    SIGNAL s_clk : STD_LOGIC;
    SIGNAL j_ctrl : STD_LOGIC;
    SIGNAL ret_ctrl : STD_LOGIC;
    SIGNAL address : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL inc_sel : STD_LOGIC;
    SIGNAL wb : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := X"0001_1001";
    SIGNAL jmp_addr : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := X"1111_1111";
    SIGNAL def : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := x"0000_0000";

    CONSTANT test_PC_out : PC_out_t := (
        def,
        def + 1,
        def + 3,
        wb,
        wb + 1,
        wb + 3,
        jmp_addr,
        jmp_addr + 1,
        jmp_addr + 3,
        jmp_addr + 3
    );

BEGIN
    pc_controller : ENTITY work.PC_Controller
        PORT MAP(
            clk => s_clk,
            en => s_enable,
            j_pc_src_ctrl => j_ctrl,
            ret_pc_src_ctrl => ret_ctrl,
            inc_sel => inc_sel,
            wb_result => wb,
            jmp_address => jmp_addr,
            reset => s_reset,
            default_val => def,
            inst_address => address
        );

    PROCESS BEGIN
        FOR i IN 0 TO TESTCASE_COUNT - 1 LOOP
            -- Start with a rising edge
            s_reset <= test_reset(i);
            s_enable <= test_enable(i);
            inc_sel <= test_inc_sel(i);
            j_ctrl <= test_jmp_addr(i);
            ret_ctrl <= test_wb(i);

            s_clk <= '1';
            WAIT FOR 50 ps;

            -- Read previous state on a rising edge
            s_clk <= '0';
            WAIT FOR 50 ps;

            ASSERT (address = test_PC_out(i))
            REPORT "FAIL: case " & INTEGER'image(i)
                & " PC = " & to_hstring(address)
                & ", expected " & to_hstring(test_PC_out(i))
                SEVERITY error;
        END LOOP;
        WAIT;
    END PROCESS;
END ARCHITECTURE main;