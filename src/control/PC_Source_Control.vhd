Library ieee;
Use ieee.std_logic_1164.all;
use work.Utility_Pack.all;

entity PC_Source_Control is
    port (
        flags: in std_logic_vector(FLAGS_COUNT-1 downto 0);
        is_J_type: in std_logic;
        JMP_flag: in std_logic_vector(1 downto 0);
        J_PC_SRC_CTRL: out std_logic
    );
end entity PC_Source_Control;


architecture main of PC_Source_Control is
    signal s_jump_condition: std_logic;
begin
    with JMP_flag select
    s_jump_condition <= flags(FLAGS_Z) when JMP_Z,
                        flags(FLAGS_N) when JMP_N,
                        flags(FLAGS_C) when JMP_C,
                        '1' when others;


    J_PC_SRC_CTRL <= is_J_type and s_jump_condition;
end architecture main;