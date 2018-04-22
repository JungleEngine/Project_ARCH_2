LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY INSTRUCTION_DECODER IS
 PORT (	I_BUBBLE 			: in std_logic;
 		OPCODE_FROM_EXECUTE : in std_logic_vector(4 downto 0);
 		IR 					: in std_logic_vector( 15 downto 0);
		
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
END ENTITY INSTRUCTION_DECODER;

ARCHITECTURE ARCH OF INSTRUCTION_DECODER IS  
	
	-- OPcodes constants.
	CONSTANT CONST_OPCODE_NOP 	: std_logic_vector(4 downto 0):="00000";
	CONSTANT CONST_OPCODE_MOV 	: std_logic_vector(4 downto 0):="00001";
	CONSTANT CONST_OPCODE_ADD 	: std_logic_vector(4 downto 0):="00010";
	CONSTANT CONST_OPCODE_MUL 	: std_logic_vector(4 downto 0):="00011";
	CONSTANT CONST_OPCODE_SUB 	: std_logic_vector(4 downto 0):="00100";
	CONSTANT CONST_OPCODE_AND 	: std_logic_vector(4 downto 0):="00101";
	CONSTANT CONST_OPCODE_OR 	: std_logic_vector(4 downto 0):="00110";
	CONSTANT CONST_OPCODE_RLC 	: std_logic_vector(4 downto 0):="00111";
	CONSTANT CONST_OPCODE_RRC 	: std_logic_vector(4 downto 0):="01000";
	CONSTANT CONST_OPCODE_SHL 	: std_logic_vector(4 downto 0):="01001";
	CONSTANT CONST_OPCODE_SHR 	: std_logic_vector(4 downto 0):="01010";
	CONSTANT CONST_OPCODE_SETC 	: std_logic_vector(4 downto 0):="01011";
	CONSTANT CONST_OPCODE_CLRC 	: std_logic_vector(4 downto 0):="01100";
	CONSTANT CONST_OPCODE_PUSH 	: std_logic_vector(4 downto 0):="01101";
	CONSTANT CONST_OPCODE_POP 	: std_logic_vector(4 downto 0):="01110";
	CONSTANT CONST_OPCODE_OUT 	: std_logic_vector(4 downto 0):="01111";
	CONSTANT CONST_OPCODE_IN 	: std_logic_vector(4 downto 0):="10000";
	CONSTANT CONST_OPCODE_NOT 	: std_logic_vector(4 downto 0):="10001";
	CONSTANT CONST_OPCODE_DEC 	: std_logic_vector(4 downto 0):="10010";
	CONSTANT CONST_OPCODE_INC 	: std_logic_vector(4 downto 0):="10011";
	CONSTANT CONST_OPCODE_JMP 	: std_logic_vector(4 downto 0):="10100";
	CONSTANT CONST_OPCODE_JZ 	: std_logic_vector(4 downto 0):="10111";
	CONSTANT CONST_OPCODE_JN 	: std_logic_vector(4 downto 0):="11000";
	CONSTANT CONST_OPCODE_JC 	: std_logic_vector(4 downto 0):="11001";
	CONSTANT CONST_OPCODE_RTI 	: std_logic_vector(4 downto 0):="11010";
	CONSTANT CONST_OPCODE_CALL 	: std_logic_vector(4 downto 0):="11011";
	CONSTANT CONST_OPCODE_RET 	: std_logic_vector(4 downto 0):="11100";
	CONSTANT CONST_OPCODE_LDM 	: std_logic_vector(4 downto 0):="11101";
	CONSTANT CONST_OPCODE_LDD 	: std_logic_vector(4 downto 0):="11110";
	CONSTANT CONST_OPCODE_STD 	: std_logic_vector(4 downto 0):="11111";

  BEGIN
  PROCESS(OPCODE_FROM_EXECUTE, I_BUBBLE, IR)
  BEGIN  
-- DOne : 
-- 1-NOP
-- 2-ADD
-- 3-MUL
-- 4-SUB
-- 5-AND
  	-- For LDM , so IR now has  immediate value
  	IF OPCODE_FROM_EXECUTE = CONST_OPCODE_LDM or I_BUBBLE = '1' or IR = (x"0000") THEN 
  		MEM_SIGNALS <= (others=>'0');
  		WB_SIGNALS <= (others=>'0');
  		RSRC <= (others=>'0');
  		RDST <= (others=>'0');
  		BRANCH_DETECTED <= ('0');
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= (others=>'0');
  		OUTPUT_VALUE <= (others=>'0');
  	
  	-- Check load, read-write(2 bits), WB 2 bits src,dst.
  	ELSIF IR(15) = '1' and IR(14) = '1' THEN
  		MEM_SIGNALS <= "10";
  		WB_SIGNALS <= "01";
  		RSRC <=(others=>'0');
  		RDST <= IR(13 downto 11);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_LDD;		
  		OUTPUT_VALUE <= IR(10 downto 2);

  	-- Check store, read-write(2 bits), WB 2 bits src,dst..
  	ELSIF IR(15) = '1' and IR(1) = '1' THEN
  		MEM_SIGNALS <= "01";
  		WB_SIGNALS <= "00";
  		RSRC <=(others=>'0');
  		RDST <= IR(13 downto 11);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_STD;		
  		OUTPUT_VALUE <= IR(10 downto 2);

  	-- Check SHR/SHL, read-write(2 bits), WB 2 bits src,dst..
  	ELSIF IR(15) = '0' and( IR(14 downto 10) = CONST_OPCODE_SHR or IR(14 downto 10) = CONST_OPCODE_SHL ) THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS  <= "01";
  		RSRC <=IR(9 downto 7);
  		RDST <= IR(6 downto 4);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= IR(14 downto 10);		
  		OUTPUT_VALUE <= ("00000" & IR(9 downto 6) );
	
	-- Check Branch value in destination.
	ELSIF IR(15) = '0' and (IR(14 downto 10) = CONST_OPCODE_JMP or IR(14 downto 10) = CONST_OPCODE_JZ  
	or IR(14 downto 10) = CONST_OPCODE_JC or IR(14 downto 10) = CONST_OPCODE_JN 
  or IR(14 downto 10) = CONST_OPCODE_CALL) THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS <= "00";
  		RSRC <= (others=>'0');
  		RDST <= IR(9 downto 7);
  		BRANCH_DETECTED <= '1';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= IR(14 downto 10);		
  		OUTPUT_VALUE <= (others=>'0');

	-- Check  multiplication.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_MUL THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS <= "11";
  		RSRC <= IR(9 downto 7);
  		RDST <= IR(6 downto 4);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_MUL;		
  		OUTPUT_VALUE <= (others=>'0');

	-- Check  push.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_PUSH THEN
  		MEM_SIGNALS <= "01";
  		WB_SIGNALS <= "00";
  		RSRC <= (others=>'0');
  		RDST <= IR(9 downto 7);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '1';
  		OPCODE <= CONST_OPCODE_PUSH;		
  		OUTPUT_VALUE <= (others=>'0');
  		
	-- Check  pop.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_POP THEN
  		MEM_SIGNALS <= "10";
  		WB_SIGNALS <= "01";
  		RSRC <= (others=>'0');
  		RDST <= IR(9 downto 7);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '1';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_POP;		
  		OUTPUT_VALUE <= (others=>'0');
  	
  	-- Check  move.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_MOV THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS <= "01";
  		RSRC <= IR(9 downto 7);
  		RDST <= IR(6 downto 4);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_MOV;		
  		OUTPUT_VALUE <= (others=>'0');
  		
  	-- Check add.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_ADD THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS <= "01";
  		RSRC <= IR(9 downto 7);
  		RDST <= IR(6 downto 4);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_ADD;		
  		OUTPUT_VALUE <= (others=>'0');

	-- Check SUB.
	ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_SUB THEN
  		MEM_SIGNALS <= "00";
  		WB_SIGNALS <= "01";
  		RSRC <= IR(9 downto 7);
  		RDST <= IR(6 downto 4);
  		BRANCH_DETECTED <= '0';  
  		SIG_POP_DETECTED <= '0';
  		SIG_PUSH_DETECTED <= '0';
  		OPCODE <= CONST_OPCODE_SUB;		
  		OUTPUT_VALUE <= (others=>'0');

    -- Check AND.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_AND THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= IR(9 downto 7);
      RDST <= IR(6 downto 4);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_AND;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check OR.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_OR THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= IR(9 downto 7);
      RDST <= IR(6 downto 4);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_OR;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check RLC.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_RLC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_RLC;   
      OUTPUT_VALUE <= (others=>'0');

    -- Check RRC.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_RRC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_RRC;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check SETC.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_SETC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= (others=>'0');
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_SETC;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check CLRC.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_CLRC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= (others=>'0');
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_CLRC;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check out.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_OUT THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_IN;   
      OUTPUT_VALUE <= (others=>'0');

    -- Check IN.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_IN THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_IN;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check INC.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_INC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_INC;   
      OUTPUT_VALUE <= (others=>'0');

  -- Check Dec.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_DEC THEN
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "01";
      RSRC <= (others=>'0');
      RDST <= IR(9 downto 7);
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_DEC;   
      OUTPUT_VALUE <= (others=>'0');

    -- Check RET.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_RET THEN
      MEM_SIGNALS <= "10";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= (others=>'0');
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '1';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_RET;   
      OUTPUT_VALUE <= (others=>'0');

      -- Check RTI.
  ELSIF IR(15) = '0' and IR(14 downto 10) = CONST_OPCODE_RTI THEN
      MEM_SIGNALS <= "10";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= (others=>'0');
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '1';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_RTI;   
      OUTPUT_VALUE <= (others=>'0');
  ELSE 
      MEM_SIGNALS <= "00";
      WB_SIGNALS <= "00";
      RSRC <= (others=>'0');
      RDST <= (others=>'0');
      BRANCH_DETECTED <= '0';  
      SIG_POP_DETECTED <= '0';
      SIG_PUSH_DETECTED <= '0';
      OPCODE <= CONST_OPCODE_RTI;   
      OUTPUT_VALUE <= (others=>'0');    
  	END IF; 
  END PROCESS;
END ARCH;




