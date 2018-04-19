LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEMORY IS
	PORT(

		-------------------- CONTROL SIGNALS ------------------------
		MEM_READ: IN std_logic;
		MEM_WRITE: IN std_logic;
		WB_SIGNALS_IN: IN std_logic_vector(2 DOWNTO 0);
		IBUBBLE_IN: IN std_logic;
		INT: IN std_logic;
		OPCODE: IN std_logic_vector(2 DOWNTO 0);
		-------------------------------------------------------------

		------------------ REGISTERS SELECTION ----------------------
		Rdst_INDEX_IN: IN std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX_IN: IN std_logic_vector(2 DOWNTO 0);
		-------------------------------------------------------------

		---------------------- INPUT DATA ---------------------------
		DATA: IN std_logic_vector(15 DOWNTO 0);
		ADDRESS_or_SP_or_SRC_RESULT: IN std_logic_vector(15 DOWNTO 0);
		RAM_DATA_OUT: IN std_logic_vector(15 DOWNTO 0);
		PREV_RAM_VALUE: IN std_logic_vector(15 DOWNTO 0);
		PC: IN std_logic_vector(8 DOWNTO 0);
		-------------------------------------------------------------

		




		-------------------- CONTROL SIGNALS ------------------------
		IBUBBLE_OUT: OUT std_logic;
		WB_SIGNALS_OUT: OUT std_logic_vector(2 DOWNTO 0);
		RAM_WRITE_EN: OUT std_logic;
		PREV_OPCODE: OUT std_logic_vector(2 DOWNTO 0);
		-------------------------------------------------------------

		---------------------- OUTPUT DATA --------------------------
		RAM_VALUE_or_DST_RESULT: OUT std_logic_vector(15 DOWNTO 0);
		SRC_RESULT: OUT std_logic_vector(15 DOWNTO 0);
		RAM_DATA_IN: IN std_logic_vector(15 DOWNTO 0);
		RAM_ADDRESS: IN std_logic_vector(15 DOWNTO 0);
		-------------------------------------------------------------

		------------------ REGISTERS SELECTION ----------------------
		Rdst_INDEX_OUT: OUT std_logic_vector(2 DOWNTO 0);
		Rsrc_INDEX_OUT: OUT std_logic_vector(2 DOWNTO 0)
		-------------------------------------------------------------

	);
END MEMORY;

ARCHITECTURE MEMORY_ARCH OF MEMORY IS
BEGIN
	
	-- Pass registers indexes to WB stage
	Rdst_INDEX_OUT <= Rdst_INDEX_IN;
	Rsrc_INDEX_OUT <= Rsrc_INDEX_IN;

	-- Pass WB control signals to WB stage
	WB_SIGNALS_OUT <= WB_SIGNALS_IN;

	-- Pass RAM data on read || Pass ALU data
	RAM_VALUE_or_DST_RESULT <= RAM_DATA_OUT WHEN MEM_READ = '1'
	ELSE DATA;

	-- Write in RAM when MEM_WRITE || Saving PC in the 1st step of the IBUBBLE
	RAM_WRITE_EN <= '1' WHEN (MEM_WRITE = '1' or (INT_HANDLING_BIT = '0' and IBUBBLE_IN = '1'))
	ELSE '0';

	-- Address = 1 when reading int ISR (2nd step of the IBUBBLE)
	--         = port address when OPCODE = IN/OUT instruction
	--         = address sent by ALU || SP value 
	RAM_ADDRESS <= (OTHERS => '0' & '1') WHEN INT_HANDLING_BIT = '1'
	ELSE PORT_ADDRESS WHEN OPCODE = --IN/OUT
	ELSE ADDRESS_or_SP_or_SRC_RESULT;

	

	-- TODO:


	-- Input data for RAM = previous RAM output (mem-to-mem forwarding) when (POP/LOAD -> PUSH/STORE) || (RET -> INT)
	--                    = PC when opcode = CALL
	--                    = ALU data

	-- Handling IN/OUT instructions

END MEMORY_ARCH;
