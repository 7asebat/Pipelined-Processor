Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

ENTITY ALU IS 
	GENERIC(WORD_SIZE: INTEGER := 32);
	PORT(
			OpA, OpB: IN std_logic_vector(WORD_SIZE-1 DOWNTO 0);
			result: OUT std_logic_vector(WORD_SIZE-1 DOWNTO 0);
			S: IN std_logic_vector(3 DOWNTO 0);
      flags_in: in std_logic_vector(2 downto 0); -- Z, N, C
			flags_out: out std_logic_vector(2 downto 0)
	);
END ENTITY;

ARCHITECTURE main OF ALU IS

SIGNAL Z_in: std_logic;
SIGNAL N_in: std_logic;
SIGNAL C_in: std_logic;

SIGNAL Z: std_logic;
SIGNAL N: std_logic;
SIGNAL C: std_logic;


SIGNAL Z_out: std_logic;
SIGNAL N_out: std_logic;
SIGNAL C_out: std_logic;

SIGNAL OpF: std_logic_vector(WORD_SIZE DOWNTO 0); 

SIGNAL SHR_RESULT : std_logic_vector(WORD_SIZE DOWNTO 0);

BEGIN

SHR_RESULT <= (std_logic_vector(shift_right(unsigned(OpB & '0'), to_integer(unsigned(OpA)))));

WITH S(3 DOWNTO 0) SELECT
  OpF <=  (OTHERS => '0')                                           WHEN "0000", -- CLR
          ('0' & not(OpB))                                          WHEN "0001", -- NOT OpB
          (std_logic_vector(unsigned('0' & OpB) + 1))               WHEN "0010", -- INC OpB
          (std_logic_vector(unsigned('0' & OpB) - 1))               WHEN "0011", -- DEC OpB
          (std_logic_vector(unsigned(not('0' & OpB)) + 1))          WHEN "0100", -- NEG OpB
          ('0' & OpB(WORD_SIZE-2 DOWNTO 0) & C_in)                  WHEN "0101", -- RLC OpB
          ('0' & C_in & OpB(WORD_SIZE-1 DOWNTO 1))                  WHEN "0110", -- RRC OpB
          ('0' & OpA)                                               WHEN "0111", -- MOV OpA, OpB
          (std_logic_vector('0' & (unsigned(OpA) + unsigned(OpB)))) WHEN "1000", -- ADD OpA, OpB
          (std_logic_vector('0' & (unsigned(OpA) - unsigned(OpB)))) WHEN "1001", -- SUB OpA, OpB
          ('0' & (OpA and OpB))                                     WHEN "1010", -- AND OpA, OpB
          ('0' & (OpA or OpB))                                      WHEN "1011", -- OR  OpA, OpB
          (std_logic_vector(shift_left(unsigned('0' & OpB), to_integer(unsigned(OpA)))))  WHEN "1100", -- SHL OpB, Imm
          (SHR_RESULT(0) & SHR_RESULT(WORD_SIZE DOWNTO 1)) WHEN "1101", -- SHR OpB, Imm
          (OTHERS => 'U') WHEN OTHERS;

Z <= ('1') WHEN unsigned(OpF(WORD_SIZE-1 DOWNTO 0)) = 0 ELSE '0';
N <= ('1') WHEN signed(OpF(WORD_SIZE-1 DOWNTO 0)) < 0 ELSE '0';

WITH S(3 DOWNTO 0) SELECT
  C <=  
    (OpF(WORD_SIZE)) WHEN "0010", -- INC OpB
    (OpF(WORD_SIZE)) WHEN "0011", -- DEC OpB
    (OpB(WORD_SIZE-1)) WHEN "0101", -- RLC OpB
    (OpB(0))  WHEN "0110", -- RRC OpB
    (OpF(WORD_SIZE)) WHEN "1000", -- ADD OpA, OpB
    (OpF(WORD_SIZE)) WHEN "1001", -- SUB OpA, OpB
    (OpF(WORD_SIZE)) WHEN "1100", -- SHL OpB, Imm
    (OpF(WORD_SIZE)) WHEN "1101", -- SHR OpB, Imm
    ('U') WHEN OTHERS;

WITH S(3 DOWNTO 0) SELECT
  Z_out <=  Z     WHEN "0000", -- CLR
            Z     WHEN "0001", -- NOT OpB
            Z     WHEN "0010", -- INC OpB
            Z     WHEN "0011", -- DEC OpB
            Z     WHEN "0100", -- NEG OpB
            Z     WHEN "1000", -- ADD OpA, OpB
            Z     WHEN "1001", -- SUB OpA, OpB
            Z     WHEN "1010", -- AND OpA, OpB
            Z     WHEN "1011", -- OR  OpA, OpB
          (Z_in) WHEN OTHERS;

WITH S(3 DOWNTO 0) SELECT
  N_out <=  N     WHEN "0001", -- NOT OpB
            N     WHEN "0010", -- INC OpB
            N     WHEN "0011", -- DEC OpB
            N     WHEN "0100", -- NEG OpB
            N     WHEN "1000", -- ADD OpA, OpB
            N     WHEN "1001", -- SUB OpA, OpB
            N     WHEN "1010", -- AND OpA, OpB
            N     WHEN "1011", -- OR  OpA, OpB
          (N_in) WHEN OTHERS;

WITH S(3 DOWNTO 0) SELECT
  C_out <=  
            C     WHEN "0010", -- INC OpB
            C     WHEN "0011", -- DEC OpB
            C     WHEN "0101", -- RLC OpB
            C     WHEN "0110", -- RRC OpB
            C     WHEN "1000", -- ADD OpA, OpB
            C     WHEN "1001", -- SUB OpA, OpB
            C     WHEN "1100", -- SHL OpB, Imm
            C     WHEN "1101", -- SHR OpB, Imm
          (C_in) WHEN OTHERS;


-- map flag outputs

C_in <= flags_in(0);
N_in <= flags_in(1);
Z_in <= flags_in(2);

flags_out(0) <= C_out;
flags_out(1) <= N_out;
flags_out(2) <= Z_out;

-- map result
result <= OpF(WORD_SIZE-1 DOWNTO 0);

END ARCHITECTURE;