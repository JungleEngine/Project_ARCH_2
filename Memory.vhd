LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEMORY IS
	PORT(

		-------------------- CONTROL SIGNALS ------------------------
		IBUBBLE_IN:										IN std_logic;
		CLK:                  IN std_logic;
		RST:                  IN std_logic;
		MEM_SIGNALS:				 IN std_logic_vector(1 DOWNTO 0);
		WB_SIGNALS_IN:				 IN std_logic_vector(1 DOWNTO 0);
		PREV_OPCODE:				 IN std_logic_vector(4 DOWNTO 0);
		OPCODE_IN:					 IN std_logic_vector(4 DOWNTO 0);
		-------------------------------------------------------------

		------------------ REGISTERS SELECTION ----------------------
		Rdst_INDEX_IN:				 IN std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX_IN:				 IN std_logic_vector(2 DOWNTO 0);
		-------------------------------------------------------------

		---------------------- INPUT DATA ----------------------------
		DATA:						 IN std_logic_vector(15 DOWNTO 0);
		ADDRESS_or_SP_or_SRC_RESULT: IN std_logic_vector(15 DOWNTO 0);
		RAM_DATA_OUT:				 IN std_logic_vector(15 DOWNTO 0);
		PREV_RAM_VALUE:				 IN std_logic_vector(15 DOWNTO 0);
		PC:							  IN std_logic_vector(8 DOWNTO 0);
		--------------------------------------------------------------






		-------------------- CONTROL SIGNALS -------------------------
		IBUBBLE_OUT:									OUT std_logic;
		RAM_WRITE_EN:									OUT std_logic;
		RAM_READ_EN:									OUT std_logic;
		WB_SIGNALS_OUT:				 OUT std_logic_vector(1 DOWNTO 0);
		OPCODE_OUT:					 OUT std_logic_vector(4 DOWNTO 0);
		--------------------------------------------------------------

		---------------------- OUTPUT DATA ---------------------------
		RAM_VALUE_or_DST_RESULT:	OUT std_logic_vector(15 DOWNTO 0);
		SRC_RESULT:					OUT std_logic_vector(15 DOWNTO 0);
		RAM_DATA_IN:				OUT std_logic_vector(15 DOWNTO 0);
		RAM_ADDRESS:				OUT std_logic_vector(8 DOWNTO 0);
		--------------------------------------------------------------

		------------------ REGISTERS SELECTION ----------------------
		Rdst_INDEX_OUT:				OUT std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX_OUT:				OUT std_logic_vector(2 DOWNTO 0)
		-------------------------------------------------------------

	);
END MEMORY;

ARCHITECTURE MEMORY_ARCH OF MEMORY IS

------------------------- OPCODE BITS --------------------------------
CONSTANT OPCODE_POP: 			std_logic_vector(4 downto 0) := "01110";
CONSTANT OPCODE_LOAD: 			std_logic_vector(4 downto 0) := "11110";
CONSTANT OPCODE_PUSH:  			std_logic_vector(4 downto 0) := "01101";
CONSTANT OPCODE_STORE:  		std_logic_vector(4 downto 0) := "11111";
CONSTANT OPCODE_RET: 			std_logic_vector(4 downto 0) := "11100";
CONSTANT OPCODE_CALL: 			std_logic_vector(4 downto 0) := "11011";
CONSTANT OPCODE_IN_PORT: 		std_logic_vector(4 downto 0) := "10000";
CONSTANT OPCODE_OUT_PORT: 		std_logic_vector(4 downto 0) := "10001";
----------------------------------------------------------------------

CONSTANT PORT_ADDRESS: std_logic_vector(8 DOWNTO 0) := "111111100";

SIGNAL BIT_REGISTER_INPUT: std_logic_vector(1 DOWNTO 0);
SIGNAL INT_HANDLING_BIT: std_logic_vector(1 DOWNTO 0);
SIGNAL VCC: std_logic := '1';

BEGIN
  BIT_REGISTER: ENTITY work.REG GENERIC MAP(n => 2) PORT MAP (BIT_REGISTER_INPUT, VCC, CLK, RST, INT_HANDLING_BIT);
	
	BIT_REGISTER_INPUT(0) <= '1' WHEN (INT_HANDLING_BIT(0) = '0' AND IBUBBLE_IN = '1')
	ELSE '0';
		
	-- Pass registers indexes to WB stage
	Rdst_INDEX_OUT <= Rdst_INDEX_IN;
	Rsrc_INDEX_OUT <= Rsrc_INDEX_IN;

	-- Pass SRC result (needed by MUL in WB stage)
	SRC_RESULT <= ADDRESS_or_SP_or_SRC_RESULT;

	-- Pass WB control signals to WB stage
	WB_SIGNALS_OUT <= WB_SIGNALS_IN;

	-- Pass opcode bits to be saved in the WB buffer to be checked if the previous opcode is needed
	OPCODE_OUT <= OPCODE_IN;

	-- Save (Don't pass) IBUBBLE in 1st step of INT else pass it
	IBUBBLE_OUT <= '0' WHEN (IBUBBLE_IN = '1' and INT_HANDLING_BIT(0) = '0')
	ELSE IBUBBLE_IN;

	-- Read from RAM when MEM_READ = '1'
	RAM_READ_EN <= MEM_SIGNALS(0);

	-- Write in RAM when MEM_WRITE || Saving PC in the 1st step of the IBUBBLE
	RAM_WRITE_EN <= '1' WHEN (MEM_SIGNALS(1) = '1' or (INT_HANDLING_BIT(0) = '0' and IBUBBLE_IN = '1'))
	ELSE '0';

	-- Pass RAM data on read || Pass ALU data
	RAM_VALUE_or_DST_RESULT <= RAM_DATA_OUT WHEN MEM_SIGNALS(0) = '1'
	ELSE DATA;

	-- Address = 1 when reading int ISR (2nd step of the IBUBBLE)
	--         = port address when OPCODE = IN/OUT instruction
	--         = address sent by ALU || SP value 
	RAM_ADDRESS <= ("000000001") WHEN INT_HANDLING_BIT(0) = '1'
	ELSE PORT_ADDRESS WHEN ((OPCODE_IN = OPCODE_IN_PORT) or (OPCODE_IN = OPCODE_OUT_PORT)) 
	ELSE ADDRESS_or_SP_or_SRC_RESULT(8 DOWNTO 0);

	-- RAM input data = previous RAM output (mem-to-mem forwarding) when (POP/LOAD -> PUSH/STORE) || (RET -> INT)
	--                = PC when opcode = CALL
	--                = ALU data
	RAM_DATA_IN <= PREV_RAM_VALUE WHEN ((PREV_OPCODE = OPCODE_POP and OPCODE_IN = OPCODE_PUSH) or
										(PREV_OPCODE = OPCODE_POP and OPCODE_IN = OPCODE_STORE) or 
										(PREV_OPCODE = OPCODE_PUSH and OPCODE_IN = OPCODE_PUSH) or 
										(PREV_OPCODE = OPCODE_PUSH and OPCODE_IN = OPCODE_STORE) or 
										(PREV_OPCODE = OPCODE_RET and IBUBBLE_IN = '1'))
	ELSE ("0000000" & PC) WHEN OPCODE_IN = OPCODE_CALL
	ELSE DATA;

END MEMORY_ARCH;
