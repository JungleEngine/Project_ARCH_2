LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***	This is the ALU stage
--***

ENTITY alu IS
 PORT (	




 	--	MEM_READ:										IN std_logic;
		--MEM_WRITE:										IN std_logic;
		--IBUBBLE_IN:										IN std_logic;
		--WB_SIGNALS_IN:				 IN std_logic_vector(2 DOWNTO 0);
		--OPCODE_IN:					 IN std_logic_vector(2 DOWNTO 0);
		---------------------------------------------------------------

		-------------------- REGISTERS SELECTION ----------------------
		--Rdst_INDEX_IN:				 IN std_logic_vector(2 DOWNTO 0);
		--Rsrc_INDEX_IN:				 IN std_logic_vector(2 DOWNTO 0);
		---------------------------------------------------------------

		------------------------ INPUT DATA ----------------------------
		--DATA:						 IN std_logic_vector(15 DOWNTO 0);
		--ADDRESS_or_SP_or_SRC_RESULT: IN std_logic_vector(15 DOWNTO 0);
		--PC:							  IN std_logic_vector(8 DOWNTO 0);


		
 		------------------------< Possible ALU operands --------------------------------

		------------------------- Possible ALU operands />------------------------------
		
		-------------------------<  --------------------------------
		stall: IN std_logic;	-- Stall signal sent by Decode stage
		opcode: IN std_logic_vector(4 DOWNTO 0);	-- Opcode bits sent by Decode stage
		-------------------------  />-------------------------------
		
		-------------------------< SP register signals -----------------------------------------
		inc_SP: IN std_logic;	-- Signal sent by Decode stage to increment SP
		dec_SP: OUT std_logic	-- Signal sent by ALU stage to decrement SP
		-------------------------- SP register signals />-----------------------------------------
	);
END ENTITY alu;

ARCHITECTURE alu_arch OF alu IS  
BEGIN
	
	--ALU_Operands_Selection_Unit: ENTITY work.ALU-Operands PORT MAP ();
	--ALU_Output_Selection_Unit: ENTITY work.ALU-Output PORT MAP ();
	--ALU_Hazard_Detection_Unit: ENTITY work.ALU-Hazard-Detection-Unit PORT MAP ();

	dec_SP <= '1' when (inc_SP = '0' AND (not stall) AND opcode = PUSH)
	else '0';

END alu_arch;

