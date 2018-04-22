LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY WB IS
	PORT(

		------------------- CONTROL SIGNALS ----------------------
		IBUBBLE: IN std_logic;
		WB_SIGNALS: IN std_logic_vector(1 DOWNTO 0);
		----------------------------------------------------------

		------------------- INPUT DATA ---------------------------
		RAM_VALUE_or_DST_RESULT: IN std_logic_vector(15 DOWNTO 0);
		SRC_RESULT: IN std_logic_vector(15 DOWNTO 0);
		OPCODE : IN std_logic_vector(4 DOWNTO 0);
		----------------------------------------------------------

		---------------- REGISTERS SELECTION ---------------------
		Rdst_INDEX: IN std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX: IN std_logic_vector(2 DOWNTO 0);
		----------------------------------------------------------


--TODO: Take opcode as input and src is in wb signal (0)


		----------------- REGISTERS ENABLES ----------------------
		PC_WRITE_EN: OUT std_logic;
		REGISTERS_WRITE_ENABLES: OUT std_logic_vector(5 downto 0);
		----------------------------------------------------------

		------------------- OUTPUT DATA --------------------------
		OUT_BUS: INOUT std_logic_vector(31 DOWNTO 0)
		----------------------------------------------------------
	);
END WB;

ARCHITECTURE WB_ARCH OF WB IS

------------------------- OPCODE BITS --------------------------------
CONSTANT OPCODE_POP: 			std_logic_vector(4 downto 0) := "01110";
CONSTANT OPCODE_LOAD: 			std_logic_vector(4 downto 0) := "11110";
CONSTANT OPCODE_PUSH:  			std_logic_vector(4 downto 0) := "01101";
CONSTANT OPCODE_STORE:  		std_logic_vector(4 downto 0) := "11111";
CONSTANT OPCODE_RET: 			std_logic_vector(4 downto 0) := "11100";
CONSTANT OPCODE_CALL: 			std_logic_vector(4 downto 0) := "11011";
CONSTANT OPCODE_IN_PORT: 		std_logic_vector(4 downto 0) := "10000";
CONSTANT OPCODE_OUT_PORT: 		std_logic_vector(4 downto 0) := "10001";
CONSTANT OPCODE_RTI: 			std_logic_vector(4 downto 0) := "11010";
----------------------------------------------------------------------


BEGIN
	
	-- Decoder to generate register enable signals from Rsrc and Rdst indexes
	REGISTERS_DECODER: ENTITY work.DECODER PORT MAP (Rdst_INDEX, Rsrc_INDEX, REGISTERS_WRITE_ENABLES);

	PROCESS(WB_SIGNALS,IBUBBLE)
	BEGIN
		-- INT -> CHANGE PC WITH ISR address
		IF(IBUBBLE = '1') THEN
			PC_WRITE_EN <= '1';
		-- Write back in SRC
		ELSIF(WB_SIGNALS(0) = '1')
			PC_WRITE_EN <= '0';
			OUT_BUS(31 DOWNTO 16) <= SRC_RESULT;  --TODO: Check multiply write back
			OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;
		-- Write back in DST
		ELSIF(WB_SIGNALS(1) = '1')	
			IF (OPCODE = OPCODE_RET or OPCODE = OPCODE_RTI)
				PC_WRITE_EN <= '1';
			ELSIF (OPCODE = OPCODE_POP or OPCODE = OPCODE_IN_PORT)
				PC_WRITE_EN <= '0';
				OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;
			ELSE 
				PC_WRITE_EN <= '0';
				OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;
			END IF;
		ELSE 
			OUT_BUS(31 DOWNTO 16) <= (OTHERS => 'Z');
			OUT_BUS(15 DOWNTO 0) <= (OTHERS => 'Z');
			PC_WRITE_EN <= '0';
		END IF;


		---- If WB is needed in this instruction
		--IF(WB_SIGNALS(2) = '1') THEN

		--	-- RET/RTI
		--	IF(WB_SIGNALS(1 DOWNTO 0) = "00") THEN
		--		PC_WRITE_EN <= '1';
		--		PC_VALUE <= RAM_VALUE_OR_DST_RESULT;

		--	-- POP/IN
		--	ELSIF(WB_SIGNALS(1 DOWNTO 0) = "01") THEN
		--		PC_WRITE_EN <= '0';
		--		OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;

		--	-- MUL
		--	ELSIF(WB_SIGNALS(1 DOWNTO 0) = "10") THEN
		--		PC_WRITE_EN <= '0';
		--		OUT_BUS(31 DOWNTO 16) <= SRC_RESULT;  --TODO: Check multiply write back
		--		OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;
			
		--	-- ANY OTHER OPERATION NEEDS TO WRITE IN Rdst
		--	ELSE
		--		PC_WRITE_EN <= '0';
		--		OUT_BUS(15 DOWNTO 0) <= RAM_VALUE_OR_DST_RESULT;

		--	END IF;

		--END IF;

	END PROCESS;
	
END WB_ARCH;
