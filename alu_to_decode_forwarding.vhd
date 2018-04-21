-- Detect if I have to stall.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

-- FLAGS
-- Z-N-C
ENTITY ALU_FORWARD IS
	
PORT (	BRANCH_DETECTED : in std_logic;
		RSRC 	 : in std_logic_vector(2 downto 0);
 		RDST 	 : in std_logic_vector(2 downto 0);
 		ALU_RSRC : in std_logic_vector(2 downto 0);
 		ALU_RDST  : in std_logic_vector(2 downto 0);
 		ALU_WB_SIGNALS : in std_logic_vector(1 downto 0);
 		
 		ALU_FORWARD_RSRC : out std_logic;
 		ALU_FORWARD_RDST : out std_logic
       );
END ENTITY ALU_FORWARD;

ARCHITECTURE ARCH OF ALU_FORWARD IS  


  BEGIN
  PROCESS(BRANCH_DETECTED, RSRC, RDST, ALU_RSRC, ALU_RDST, ALU_WB_SIGNALS)
  BEGIN

  -- Conditions check for branch, ALU_WB (SRC,DST)
  	IF BRANCH_DETECTED = '1' THEN
  		IF ALU_WB_SIGNALS(0) = '1' or ALU_WB_SIGNALS(1) = '1' THEN
  			IF RSRC = ALU_RSRC THEN
 				ALU_FORWARD_RSRC <= '1'; 		
 				ALU_FORWARD_RDST <= '0';
 			ELSIF RDST = ALU_RDST THEN
 				ALU_FORWARD_RSRC <= '0'; 		
 				ALU_FORWARD_RDST <= '1';
 			ELSE 
 				ALU_FORWARD_RSRC <= '0';
 				ALU_FORWARD_RDST <= '0';
 			END IF;
 		ELSE 
 			ALU_FORWARD_RSRC <= '0';	
 			ALU_FORWARD_RDST <= '0';
		END IF;
	END IF;

  END PROCESS;
END ARCH;






	