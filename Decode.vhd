LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY DECODE IS
 PORT(	
      BUFFERED_PC_SELECTOR_BIT :  in std_logic;
      I_BUBBLE 			 	: in std_logic;
      ALU_MEMR 				: in std_logic;
      MEM_MEMR        : in std_logic;
	    ALU_RSRC 				: in std_logic_vector(2 downto 0);
	    ALU_RDST				: in std_logic_vector(2 downto 0);
	   	MEM_RSRC 				: in std_logic_vector(2 downto 0);
	   	MEM_RDST				: in std_logic_vector(2 downto 0);
	    FLAG_REG 				: in std_logic_vector(3 downto 0);
	    ALU_WB_SIGNALS 			: in std_logic_vector(1 downto 0);
	    SP 						: in std_logic_vector(8 downto 0);
	    PC 						: in std_logic_vector(8 downto 0);
	    IR 		 				: in std_logic_vector(15 downto 0);
	    ALU_STAGE_OUTPUT_SRC    : in std_logic_vector(15 downto 0);
	    ALU_STAGE_OUTPUT_DST    : in std_logic_vector(15 downto 0);
      OPCODE_FROM_EXECUTE     : in std_logic_vector(4 DOWNTO 0 ); --FROM BUFFER BEFORE EXECUTE

	     -- Rdst from register file.
	    REGISTER_FILE_OUTPUT 	: in std_logic_vector(15 downto 0);

	    PC_SELECTOR_BIT			: out std_logic;
	    FLAGS_REG_WRITE 		: out std_logic;
	    SP_INC				: out std_logic;
	    I_BUBBLE_OUT			: out std_logic;
	    WB_SIGNALS              : out std_logic_vector(1 downto 0);
	    MEM_SIGNALS             : out std_logic_vector(1 downto 0);
	    RSRC 					: out std_logic_vector(2 downto 0);
	    RDST 					: out std_logic_vector(2 downto 0);
	    FLAG_REG_OUT			: out std_logic_vector(3 downto 0);
	    OPCODE   				: out std_logic_vector(4 downto 0);
	    DECODING_STAGE_OUTPUT   : out std_logic_vector(8 downto 0);
	    PC_OUT         			: out std_logic_vector(8 downto 0);
	    EA_OR_SP_SH_VALUE          : out std_logic_vector(8 downto 0)

 		   
       );
END ENTITY DECODE;

ARCHITECTURE ARCH OF DECODE IS  

SIGNAL SIG_SP_INC_DETECTED : std_logic;
SIGNAL SIG_PASS_SP   : std_logic;
SIGNAL SIG_BRANCH_TAKEN : std_logic;
SIGNAL SIG_ALU_FORWARD_RSRC : std_logic;
SIGNAL SIG_ALU_FORWARD_RDST : std_logic;
SIGNAL SIG_BRANCH_ADDRESS : std_logic_vector(8 downto 0);
SIGNAL SIG_BRANCH_DETECTED   : std_logic;
SIGNAL SIG_DH_STALL : std_logic;
SIGNAL SIG_MEM_SIGNALS : std_logic_vector(1 downto 0 );
SIGNAL SIG_WB_SIGNALS : std_logic_vector(1 downto 0 );
SIGNAL SIG_RSRC : std_logic_vector(2 downto 0 );
SIGNAL SIG_RDST : std_logic_vector(2 downto 0 );
SIGNAL SIG_OPCODE : std_logic_vector(4 downto 0 );
SIGNAL SIG_EA_OR_SH_VALUE : std_logic_vector(8 downto 0);
SIGNAL SIG_BRANCH_DETECTOR_DATA : std_logic_vector(15 downto 0);  

  BEGIN
  -- Instruction decoder component.
  INSTRUCTION_DECODER: ENTITY work.INSTRUCTION_DECODER  PORT MAP 
  (-- Input.
    BUFFERED_PC_SELECTOR_BIT
  	I_BUBBLE, 
  	OPCODE_FROM_EXECUTE,
  	IR, 
  	-- Output.
  	SIG_BRANCH_DETECTED,
  	SIG_SP_INC_DETECTED,  
  	SIG_PASS_SP,
  	SIG_MEM_SIGNALS,
  	SIG_WB_SIGNALS,
  	SIG_RSRC,
  	SIG_RDST,
  	SIG_OPCODE,
  	SIG_EA_OR_SH_VALUE
  	);
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- hazard detector component.
HARZARD_DETECTOR: ENTITY work.STALL_DETECTOR  PORT MAP 
  (-- Input.
  	SIG_OPCODE, 
  	SIG_BRANCH_DETECTED,
  	SIG_WB_SIGNALS,
  	SIG_RSRC,
  	SIG_RDST,
  	ALU_RSRC,
  	ALU_RDST,
  	ALU_MEMR,
  	ALU_WB_SIGNALS,
  	MEM_RDST,
  	MEM_MEMR,
  	SIG_DH_STALL
  	);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--branch detector.
BRANCH_DETECTOR: ENTITY work.BRANCH_DETECTOR  PORT MAP 
  ( -- Input.
 	SIG_BRANCH_DETECTED,
 	SIG_DH_STALL,
 	FLAG_REG,
 	SIG_OPCODE,
 	SIG_BRANCH_DETECTOR_DATA,
 	FLAG_REG_OUT,
 	-- outputs.
 	SIG_BRANCH_TAKEN,
 	FLAGS_REG_WRITE,
 	SIG_BRANCH_ADDRESS
  	);
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--ALU to decode forwarding unit.
ALU_TO_DECODE_FORWARDING : ENTITY work.ALU_FORWARD  PORT MAP 
  ( -- Input.
  SIG_BRANCH_DETECTED,
 	SIG_RSRC,
 	SIG_RDST,
 	ALU_RSRC,
 	ALU_RDST,
 	ALU_WB_SIGNALS,
 	-- Output
 	SIG_ALU_FORWARD_RSRC,
 	SIG_ALU_FORWARD_RDST
  	);
  	
  

  -- 9 bit value for shift value or Effective address.
  EA_OR_SP_SH_VALUE <= sp when(SIG_PASS_SP='1')
  else  SIG_EA_OR_SH_VALUE;


  -- RSRC, RDST signals.
  RSRC <= SIG_RSRC;
  RDST <= SIG_RDST;

  -- PC out = pc in, (pass pc).
  PC_OUT <= PC;

  -- Pass I bubble.
  I_BUBBLE_OUT <=I_BUBBLE;
  
  PROCESS(I_BUBBLE, ALU_MEMR, MEM_MEMR, ALU_RSRC, ALU_RDST, MEM_RSRC, MEM_RDST, FLAG_REG,
  		ALU_WB_SIGNALS, SP, PC, IR, ALU_STAGE_OUTPUT_SRC, ALU_STAGE_OUTPUT_DST, REGISTER_FILE_OUTPUT,
  		 SIG_SP_INC_DETECTED, SIG_BRANCH_TAKEN, SIG_ALU_FORWARD_RSRC, SIG_ALU_FORWARD_RDST,
  		 SIG_BRANCH_ADDRESS, SIG_BRANCH_DETECTED, SIG_DH_STALL, SIG_RSRC, SIG_RDST, SIG_OPCODE, OPCODE_FROM_EXECUTE,
  		 SIG_BRANCH_DETECTOR_DATA
  		 )
  BEGIN
    
    

    IF SIG_ALU_FORWARD_RDST = '1' THEN
       SIG_BRANCH_DETECTOR_DATA <= ALU_STAGE_OUTPUT_DST;
    ELSIF SIG_ALU_FORWARD_RSRC = '1' THEN
      SIG_BRANCH_DETECTOR_DATA <=ALU_STAGE_OUTPUT_SRC;
    ELSIF SIG_ALU_FORWARD_RSRC = '0'  and SIG_ALU_FORWARD_RDST = '0' THEN
      SIG_BRANCH_DETECTOR_DATA <= REGISTER_FILE_OUTPUT;
   ELSE SIG_BRANCH_DETECTOR_DATA<=(others=>'0');
  END IF;

  -- Update sp and out the new value, if no stall.
  IF SIG_SP_INC_DETECTED = '1' and SIG_DH_STALL = '0' THEN
  	SP_INC <= '1';
  ELSE
	SP_INC <= '0';

  END IF;

  -- Output bubble if stall in control signals and opcode.
  IF SIG_DH_STALL = '1' THEN
  	WB_SIGNALS <= (others=>'0');
  	MEM_SIGNALS <= (others=>'0');-- (src, dst(write)).
  	OPCODE <= (others=>'0');
  ELSE
  	WB_SIGNALS <= SIG_WB_SIGNALS;
  	MEM_SIGNALS <= SIG_MEM_SIGNALS;-- (src, dst(write)).
  	OPCODE <= SIG_OPCODE;
  END IF;

-- If stall then pass old, stored PC, else pass branch address.
  IF SIG_DH_STALL = '1' THEN
  	DECODING_STAGE_OUTPUT <= PC;
  ELSE 
  	DECODING_STAGE_OUTPUT <= SIG_BRANCH_ADDRESS;
  END IF;

  -- PC_SELECTOR_BIT = 1 if branch taken or stall.
  IF SIG_DH_STALL = '1' or SIG_BRANCH_TAKEN = '1'THEN
  	PC_SELECTOR_BIT <= '1';
  ELSE 
  	PC_SELECTOR_BIT <= '0';
  END IF;
  

  END PROCESS;
END ARCH;



