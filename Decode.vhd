LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY DECODE IS
 PORT (	I_BUBBLE 			 	: in std_logic;
	    FLAG_REG 				: in std_logic_vector(3 downto 0);
	    SP 						: in std_logic_vector(8 downto 0);
	    IR 		 				: in std_logic_vector(15 downto 0);
	    ALU_STAGE_OUTPUT_SRC    : in std_logic_vector(15 downto 0);
	    ALU_STAGE_OUTPUT_DST    : in std_logic_vector(15 downto 0);
	    REGISTER_FILE_OUTPUT 	: in std_logic_vector(15 downto 0);


	    DH_STALL			 	: out std_logic;
	    BRANCH_TAKEN			: out std_logic;
	    FLAGS_REG_WRITE 		: out std_logic;
	    WB_SIGNALS              : out std_logic_vector(1 downto 0);
	    MEM_SIGNALS             : out std_logic_vector(1 downto 0);
	    RSRC 					: out std_logic_vector(3 downto 0);
	    RDST 					: out std_logic_vector(3 downto 0);
	    OPCODE   				: out std_logic_vector(4 downto 0);
	    DECODING_STAGE_OUTPUT   : out std_logic_vector(8 downto 0);
	    SP_OUTPUT               : out std_logic_vector(8 downto 0);
	    EA_OR_SH_VALUE          : out std_logic_vector(8 downto 0)

 		   
       );
END ENTITY DECODE;

ARCHITECTURE ARCH OF DECODE IS  

SIGNAL SIG_OPCODE_FROM_EXECUTE :STD_LOGIC_VECTOR(5 DOWNTO 0 ); --SELECT OPERATION
SIGNAL SIG_SP_INC_DETECTED :STD_LOGIC_VECTOR(5 DOWNTO 0 ); --SELECT OPERATIOND
SIGNAL SIG_POP_DETECTED :STD_LOGIC_VECTOR(5 DOWNTO 0 ); --SELECT OPERATIOND

  BEGIN
  -- Instruction decoder component.
  INSTRUCTION_DECODER: ENTITY work.ALU_FUN_SEL  PORT MAP 
  (I_BUBBLE, IR, SIG_OPCODE_FROM_EXECUTE, SIG_SP_INC_DETECTED,  SIG_POP_DETECTED);

   PORT (	I_BUBBLE 			: in std_logic;
 		OPCODE_FROM_EXECUTE : in std_logic_vector(4 downto 0);
 		IR 					: in std_logic_vector(15 downto 0);
		
		BRANCH_DETECTED  	: out std_logic;
		SIG_POP_DETECTED 	: out std_logic;
		SIG_PUSH_DETECTED 	: out std_logic;
		MEM_SIGNALS 		: out std_logic_vector(1 downto 0);
		WB_SIGNALS 			: out std_logic_vector(1 downto 0);
		RSRC 				: out std_logic_vector (2 downto 0);
		RDST 				: out std_logic_vector (2 downto 0);
		OPCODE 				: out std_logic_vector (4 downto 0);
		OUTPUT_VALUE 		: out std_logic_vector (8 downto 0) 	
       );
  PROCESS()
  BEGIN
 
  END PROCESS;
END ARCH;



