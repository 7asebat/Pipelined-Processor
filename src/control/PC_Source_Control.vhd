Library ieee;
Use ieee.std_logic_1164.all;
use work.Utility_Pack.all;

entity PC_Source_Control is
port (
    clk: in std_logic;
    flags: in std_logic_vector(FLAGS_COUNT-1 downto 0);
    is_J_type: in std_logic;
    JMP_flag: in std_logic_vector(1 downto 0);
    J_PC_SRC_CTRL: out std_logic
);
end entity PC_Source_Control;


architecture main of PC_Source_Control is
    signal s_jump_condition: std_logic;
begin
    process(clk) begin
        if (falling_edge(clk)) then
            case JMP_flag is
            when JMP_Z => s_jump_condition <= flags(FLAGS_Z);
            when JMP_N => s_jump_condition <= flags(FLAGS_N);
            when JMP_C => s_jump_condition <= flags(FLAGS_C);
            when others => s_jump_condition <= '1';
            end case;
        end if;
    end process;

    J_PC_SRC_CTRL <= is_J_type and s_jump_condition;
end architecture main;