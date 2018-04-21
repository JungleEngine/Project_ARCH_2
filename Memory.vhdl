LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEMORY IS
	PORT(

		-------------------- CONTROL SIGNALS ------------------------
		MEM_READ:										IN std_logic;
		MEM_WRITE:										IN std_logic;
		IBUBBLE_IN:										IN std_logic;
		WB_SIGNALS_IN:				 IN std_logic_vector(2 DOWNTO 0);
		OPCODE_IN:					 IN std_logic_vector(2 DOWNTO 0);
		PREV_OPCODE:				 IN std_logic_vector(2 DOWNTO 0);
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
		WB_SIGNALS_OUT:				 OUT std_logic_vector(2 DOWNTO 0);
		OPCODE_OUT:					 OUT std_logic_vector(2 DOWNTO 0);
		--------------------------------------------------------------

		---------------------- OUTPUT DATA ---------------------------
		RAM_VALUE_or_DST_RESULT:	OUT std_logic_vector(15 DOWNTO 0);
		SRC_RESULT:					OUT std_logic_vector(15 DOWNTO 0);
		RAM_DATA_IN:				OUT std_logic_vector(15 DOWNTO 0);
		RAM_ADDRESS:				OUT std_logic_vector(15 DOWNTO 0);
		--------------------------------------------------------------

		------------------ REGISTERS SELECTION ----------------------
		Rdst_INDEX_OUT:				OUT std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX_OUT:				OUT std_logic_vector(2 DOWNTO 0)
		-------------------------------------------------------------

	);
END MEMORY;

ARCHITECTURE MEMORY_ARCH OF MEMORY IS

------------------------- OPCODE BITS --------------------------------
CONSTANT OPCODE_POP_or_LOAD: 	std_logic_vector(2 downto 0) := "000";
CONSTANT OPCODE_PUSH_or_STORE:  std_logic_vector(2 downto 0) := "111";
CONSTANT OPCODE_RET: 			std_logic_vector(2 downto 0) := "001";
CONSTANT OPCODE_CALL: 			std_logic_vector(2 downto 0) := "010";
CONSTANT OPCODE_IN_or_OUT: 		std_logic_vector(2 downto 0) := "100";
----------------------------------------------------------------------

BEGIN

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
	IBUBBLE_OUT <= '0' WHEN (IBUBBLE_IN = '1' and INT_HANDLING_BIT = '0')
	ELSE IBUBBLE_IN;

	-- Read from RAM when MEM_READ = '1'
	RAM_READ_EN <= MEM_READ;

	-- Write in RAM when MEM_WRITE || Saving PC in the 1st step of the IBUBBLE
	RAM_WRITE_EN <= '1' WHEN (MEM_WRITE = '1' or (INT_HANDLING_BIT = '0' and IBUBBLE_IN = '1'))
	ELSE '0';

	-- Pass RAM data on read || Pass ALU data
	RAM_VALUE_or_DST_RESULT <= RAM_DATA_OUT WHEN MEM_READ = '1'
	ELSE DATA;

	-- Address = 1 when reading int ISR (2nd step of the IBUBBLE)
	--         = port address when OPCODE = IN/OUT instruction
	--         = address sent by ALU || SP value 
	RAM_ADDRESS <= (OTHERS => '0' & '1') WHEN INT_HANDLING_BIT = '1'
	ELSE PORT_ADDRESS WHEN OPCODE_IN = OPCODE_IN_or_OUT
	ELSE ADDRESS_or_SP_or_SRC_RESULT;

	-- RAM input data = previous RAM output (mem-to-mem forwarding) when (POP/LOAD -> PUSH/STORE) || (RET -> INT)
	--                = PC when opcode = CALL
	--                = ALU data
	RAM_DATA_IN <= PREV_RAM_VALUE WHEN ((PREV_OPCODE xor OPCODE_IN = "111") or (PREV_OPCODE = OPCODE_RET and IBUBBLE_IN = '1'))
	ELSE PC WHEN OPCODE_IN = OPCODE_CALL
	ELSE DATA;

END MEMORY_ARCH;
