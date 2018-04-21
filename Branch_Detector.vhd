LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

-- FLAGS
-- Z-N-C
ENTITY INSTRUCTION_DECODER IS
 PORT (	BRANCH_DETECTED 		: in std_logic;
		FLAGS_REG_OUTPUT 		: in std_logic_vector(3 downto 0);
 		OPCODE                  : in std_logic_vector(4 downto 0);
 		RDST_VALUE				: in std_logic_vector(15 downto 0);				
 		
 		FLAGS_REG_INPUT			: out std_logic_vector(3 downto 0);
 		BRANCH_TAKEN 			: out std_logic;
 		DECODING_STAGE_OUTPUT 	: out std_logic_vector(8 downto 0)
       );
END ENTITY INSTRUCTION_DECODER;

ARCHITECTURE ARCH OF INSTRUCTION_DECODER IS  
	
	-- Opcodes constants.
	CONSTANT CONST_OPCODE_JMP 	: std_logic_vector(4 downto 0):="10100";
	CONSTANT CONST_OPCODE_JZ 	: std_logic_vector(4 downto 0):="10111";
	CONSTANT CONST_OPCODE_JN 	: std_logic_vector(4 downto 0):="11000";
	CONSTANT CONST_OPCODE_JC 	: std_logic_vector(4 downto 0):="11001";

  BEGIN

  -- Input to fetch stage.
  DECODING_STAGE_OUTPUT <= RDST_VALUE(8 downto 0);
  -- Z-N-C
  PROCESS(FLAGS_REG_OUTPUT, BRANCH_DETECTED, RDST_VALUE)
  BEGIN 
  
  	--If branch is detected.
  	IF BRANCH_DETECTED = '1' THEN
  		
  		-- Check if JMP
  		iF OPCODE = CONST_OPCODE_JMP THEN
  			BRANCH_TAKEN <= '1';
  			FLAGS_REG_INPUT <=	FLAGS_REG_OUTPUT;
	  	
	  	-- Check zero flag = 1.
	  	ELSIF OPCODE = CONST_OPCODE_JZ and FLAGS_REG_OUTPUT(3) = '1' THEN
	  		BRANCH_TAKEN <= '1';
	  		FLAGS_REG_INPUT <= ('0' & FLAGS_REG_OUTPUT(2 downto 0));

  		-- Check negative flag = 1.
  		ELSIF OPCODE = CONST_OPCODE_JN and FLAGS_REG_OUTPUT(2) = '1' THEN
  			BRANCH_TAKEN <= '1';
  			FLAGS_REG_INPUT <= (FLAGS_REG_OUTPUT(3) & FLAGS_REG_OUTPUT(2) & '0' & FLAGS_REG_OUTPUT(0));

		-- Check carry flag = 1.
		ELSIF OPCODE = CONST_OPCODE_JC and FLAGS_REG_OUTPUT(1) = '1' THEN
			BRANCH_TAKEN <= '1';
			FLAGS_REG_INPUT <= (FLAGS_REG_OUTPUT(3) & '0' & FLAGS_REG_OUTPUT(1 downto 0));
		ELSE 
			BRANCH_TAKEN <='0';
			FLAGS_REG_INPUT <= FLAGS_REG_OUTPUT;
	  	END IF;
  	END IF; 
  END PROCESS;
END ARCH;





