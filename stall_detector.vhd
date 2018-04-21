-- Detect if I have to stall.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

-- FLAGS
-- Z-N-C
ENTITY STALL_DETECTOR IS
	
PORT (	OPCODE   : in std_logic_vector(4 downto 0);
		BRANCH_DETECTED : in std_logic;
		WB_SIGNALS : in std_logic_vector(1 downto 0);
		RSRC 	 : in std_logic_vector(2 downto 0);
 		RDST 	 : in std_logic_vector(2 downto 0);
 		ALU_RSRC : in std_logic_vector(2 downto 0);
 		ALU_RDST  : in std_logic_vector(2 downto 0);
 		ALU_MEMR : in std_logic;
 		ALU_WB_SIGNALS : in std_logic_vector(1 downto 0);
 		MEM_RDST : in std_logic_vector(2 downto 0);
 		MEM_MEMR : in std_logic;
 		-- Data hazard stall.
 		DH_STALL : out std_logic
       );
END ENTITY STALL_DETECTOR;

ARCHITECTURE ARCH OF STALL_DETECTOR IS  

CONSTANT CONST_OPCODE_MOV 	: std_logic_vector(4 downto 0):="00001";
CONSTANT CONST_OPCODE_MUL 	: std_logic_vector(4 downto 0):="00011";



  BEGIN
  PROCESS(OPCODE, BRANCH_DETECTED, WB_SIGNALS, RSRC, RDST, ALU_RSRC, ALU_RDST, ALU_MEMR, ALU_WB_SIGNALS,
  		 MEM_RDST, MEM_MEMR)
  BEGIN

  -- Conditions check for branch.
  	IF BRANCH_DETECTED = '1' THEN
  		IF ((RDST = ALU_RDST and ALU_MEMR = '1') or (RDST = MEM_RDST and MEM_MEMR = '1')) THEN
  			DH_STALL <= '1';
		END IF;

	ELSE
		-- IF there is WB signals, WB(SRC,DST).
		IF (WB_SIGNALS(0) = '1' or WB_SIGNALS(1) = '1') 
			and (ALU_WB_SIGNALS(0) = '1' or ALU_WB_SIGNALS(1) = '1') THEN
			
			IF OPCODE = CONST_OPCODE_MOV THEN
				IF (RSRC = ALU_RDST and ALU_MEMR = '1') THEN
  				DH_STALL <= '1';
				END IF;
			ELSE
				IF (RSRC = ALU_RDST and ALU_MEMR = '1') or (RDST = ALU_RDST and ALU_MEMR = '1') THEN
				DH_STALL <= '1';
				ELSE 
				DH_STALL <= '0';
				END IF;
			END IF;
		ELSE 
			DH_STALL <= '0';
		END IF;

	END IF;

  END PROCESS;
END ARCH;






	