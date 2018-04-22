LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***	This is a 5-stage pipelined processor based on MIPS architecture
--***

ENTITY processor IS
 PORT (	
 		CLK : IN std_logic;
 		RST : IN std_logic;
 		INTERRUPT_PIN : IN std_logic
	);
END ENTITY processor;

ARCHITECTURE processor_arch OF processor IS

SIGNAL GND: std_logic_vector(40 DOWNTO 0) := (OTHERS => '0');
SIGNAL VCC: std_logic_vector(40 DOWNTO 0) := (OTHERS => '1');

SIGNAL FETCH_DECODE_BUFFER_OUTPUT: std_logic_vector(25 DOWNTO 0);
SIGNAL FETCH_STAGE_IR_VAL: std_logic_vector(8 DOWNTO 0);
SIGNAL FETCH_STAGE_PC_VAL: std_logic_vector(15 DOWNTO 0);
SIGNAL FETCH_STAGE_IBUBBLE: std_logic;

SIGNAL DECODE_EXECUTE_BUFFER_OUTPUT: std_logic_vector(34 DOWNTO 0);
SIGNAL DECODE_STAGE_STALL: std_logic;
SIGNAL DECODE_STAGE_IBUBBLE: std_logic;
SIGNAL DECODE_STAGE_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_STAGE_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_STAGE_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_STAGE_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_STAGE_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL DECODE_STAGE_PC_OUT: std_logic_vector(15 DOWNTO 0);
SIGNAL DECODE_STAGE_EA_OR_SH_VALUE: std_logic_vector(8 DOWNTO 0);

SIGNAL EXECUTE_MEMORY_BUFFER_OUTPUT: std_logic_vector(56 DOWNTO 0);
SIGNAL EXECUTE_STAGE_IBUBBLE: std_logic;
SIGNAL EXECUTE_STAGE_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_STAGE_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_STAGE_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL EXECUTE_STAGE_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_STAGE_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_STAGE_ALU_DATA: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_STAGE_ADDRESS_SP_SRCRESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_STAGE_PC: std_logic_vector(15 DOWNTO 0);

SIGNAL MEMORY_WRITEBACK_BUFFER_OUTPUT: std_logic_vector(45 DOWNTO 0);
SIGNAL MEMORY_STAGE_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL MEMORY_STAGE_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL MEMORY_STAGE_RAM_VALUE_or_DST_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_STAGE_SRC_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_STAGE_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL MEMORY_STAGE_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);

SIGNAL INST_MEM_IR: std_logic_vector(15 DOWNTO 0);
SIGNAL INST_MEM_ADDRESS: std_logic_vector(15 DOWNTO 0);

SIGNAL DATA_MEM_ADDRESS: std_logic_vector(15 DOWNTO 0);
SIGNAL DATA_MEM_DATA_IN: std_logic_vector(15 DOWNTO 0);
SIGNAL DATA_MEM_DATA_OUT: std_logic_vector(15 DOWNTO 0);
SIGNAL SIG_DECODE_STAGE_OUTPUT: std_logic_vector(8 DOWNTO 0);

SIGNAL DECODE_FETCH_PC_SELECTION_BIT: std_logic;
SIGNAL WRITEBACK_FETCH_PC_SELECTION_BIT: std_logic;

BEGIN
	
	REGISTER_FILE: ENTITY work.REGISTER_FILE PORT MAP (
		);

	INST_RAM: ENTITY work.RAM PORT MAP (
		CLK,
		GND(0),
		INST_MEM_ADDRESS,
		DUMMY,
		INST_MEM_IR
		);

	DATA_RAM: ENTITY work.RAM PORT MAP (
		CLK,
		EXECUTE_MEMORY_OUT_MEM_SIGNALS(1),
		DATA_MEM_ADDRESS,
		DATA_MEM_DATA_IN,
		DATA_MEM_DATA_OUT
		);


	FETCH_STAGE: ENTITY work.FETCH PORT MAP (
		INTERRUPT_PIN					=> INTERRUPT_PIN,
		DECODING_STAGE_OUTPUT 			=> SIG_DECODE_STAGE_OUTPUT,
		MEMORY_STAGE_OUTPUT				=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		MEMORY_OUTPUT 					=> INST_MEM_IR,
		MEMORY_READ_ADDRESS 			=> INST_MEM_ADDRESS,
		MEMORY_SELECTOR_MEMORY_STAGE	=> WRITEBACK_FETCH_PC_SELECTION_BIT,
		DECODE_SELECTOR_DECODE_STAGE	=> DECODE_FETCH_PC_SELECTION_BIT,
		IR_OUTPUT_TO_DECODE 			=> FETCH_DECODE_IN_IR_VAL,
		PC_OUTPUT_TO_DECODE				=> FETCH_DECODE_IN_PC_VAL,
		I_BUBBLE 						=> FETCH_DECODE_IN_IBUBBLE,

		------------------------------------------------------------------------
		--Register File
			PC :                           	in  std_logic_vector      	(8  DOWNTO 0);
			PC_REGISTER_INPUT
		------------------------------------------------------------------------
	);

	FETCH_DECODE_BUFFER: ENTITY work.REG GENERIC MAP(n => 26) PORT MAP (
		CLK		=>	CLK,

		D 		=>(
					FETCH_DECODE_IN_IR_VAL&
					FETCH_DECODE_IN_PC_VAL&
					FETCH_DECODE_IN_IBUBBLE
					),
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>(
					FETCH_DECODE_OUT_IR_VAL&
					FETCH_DECODE_OUT_PC_VAL&
					FETCH_DECODE_OUT_IBUBBLE
					)
	);

	DECODE_STAGE: ENTITY work.DECODE PORT MAP (
		I_BUBBLE 				=> FETCH_DECODE_OUT_IBUBBLE,
		ALU_MEMR 				=> DECODE_EXECUTE_OUT_MEM_SIGNALS(0),
		MEM_MEMR				=> EXECUTE_MEMORY_OUT_MEM_SIGNALS(0),
		ALU_RSRC 				=> DECODE_EXECUTE_OUT_Rsrc_INDEX,
		ALU_RDST				=> DECODE_EXECUTE_OUT_Rdst_INDEX,
		MEM_RSRC 				=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		MEM_RDST				=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		ALU_WB_SIGNALS 			=> DECODE_EXECUTE_OUT_WB_SIGNALS,
		PC 						=> FETCH_DECODE_OUT_PC_VAL,
		IR 		 				=> FETCH_DECODE_OUT_IR_VAL,
		ALU_STAGE_OUTPUT_SRC	=> EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT,
		ALU_STAGE_OUTPUT_DST	=> EXECUTE_MEMORY_IN_ALU_DATA,
		OPCODE_FROM_EXECUTE		=> DECODE_EXECUTE_OUT_OPCODE,

		------------------------------------------------------------------------
		--Register File
			REGISTER_FILE_OUTPUT 	: in std_logic_vector(15 downto 0);
			FLAG_REG 				: in std_logic_vector(3 downto 0);
			SP 						: in std_logic_vector(8 downto 0);
			FLAGS_REG_WRITE 		: out std_logic;
			SP_INC					: out std_logic;
			FLAG_REG_OUT			: out std_logic_vector(3 downto 0);
		------------------------------------------------------------------------

		PC_SELECTOR_BIT			=>DECODE_FETCH_PC_SELECTION_BIT,
		I_BUBBLE_OUT			=> DECODE_EXECUTE_IN_IBUBBLE,
		WB_SIGNALS              => DECODE_EXECUTE_IN_WB_SIGNALS,
		MEM_SIGNALS             => DECODE_EXECUTE_IN_MEM_SIGNALS,
		RSRC 					=> DECODE_EXECUTE_IN_Rsrc_INDEX,
		RDST 					=> DECODE_EXECUTE_IN_Rdst_INDEX,
		OPCODE   				=> DECODE_EXECUTE_IN_OPCODE,
		DECODING_STAGE_OUTPUT   => SIG_DECODE_STAGE_OUTPUT,
		PC_OUT         			=> DECODE_EXECUTE_IN_PC_OUT,
		EA_OR_SP_SH_VALUE       => DECODE_EXECUTE_IN_EA_OR_SP_SH_VALUE
		);

	DECODE_EXECUTE_BUFFER: ENTITY work.REG GENERIC MAP(n => 35) PORT MAP (
		CLK		=>	CLK,
		D 		=> (
					DECODE_EXECUTE_IN_IBUBBLE&
					DECODE_EXECUTE_IN_WB_SIGNALS&
					DECODE_EXECUTE_IN_MEM_SIGNALS&
					DECODE_EXECUTE_IN_Rsrc_INDEX&
					DECODE_EXECUTE_IN_Rdst_INDEX&
					DECODE_EXECUTE_IN_OPCODE&
					DECODE_EXECUTE_IN_PC_OUT&
					DECODE_EXECUTE_IN_EA_OR_SP_SH_VALUE
					),
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>  (
					DECODE_EXECUTE_OUT_IBUBBLE&
					DECODE_EXECUTE_OUT_WB_SIGNALS&
					DECODE_EXECUTE_OUT_MEM_SIGNALS&
					DECODE_EXECUTE_OUT_Rsrc_INDEX&
					DECODE_EXECUTE_OUT_Rdst_INDEX&
					DECODE_EXECUTE_OUT_OPCODE&
					DECODE_EXECUTE_OUT_PC_OUT&
					DECODE_EXECUTE_OUT_EA_OR_SP_SH_VALUE
					),
		);

	EXECUTE_STAGE: ENTITY work.EXECUTE PORT MAP (
 		immediate_val_fetch_stage 	=> FETCH_DECODE_OUT_IR_VAL,
		ibubble_alu_buffer			=> DECODE_EXECUTE_OUT_IBUBBLE,
 		src_addr_alu_buffer			=> DECODE_EXECUTE_OUT_Rsrc_INDEX,
 		dst_addr_alu_buffer			=> DECODE_EXECUTE_OUT_Rdst_INDEX,
 		opcode_alu_buffer			=> DECODE_EXECUTE_OUT_OPCODE,
 		SP_or_EA_val_alu_buffer		=> DECODE_EXECUTE_OUT_EA_OR_SP_SH_VALUE,
 		wb_ctrl_sig_src_mem_buffer	=> EXECUTE_MEMORY_OUT_WB_SIGNALS(0),--TODO
		wb_ctrl_sig_dst_mem_buffer 	=> EXECUTE_MEMORY_OUT_WB_SIGNALS(1),--TODO
		src_addr_mem_buffer			=> EXECUTE_STAGE_Rsrc_INDEX,
		dst_addr_mem_buffer			=> EXECUTE_STAGE_Rdst_INDEX,
		result_src_val_mem_buffer	=> EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT,
		result_dst_val_mem_buffer	=> EXECUTE_MEMORY_OUT_ALU_DATA,
		src_addr_wb_buffer			=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,
		dst_addr_wb_buffer			=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,
		src_val_wb_buffer			=> MEMORY_WRITEBACK_OUT_SRC_RESULT,
		dst_val_wb_buffer			=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		wb_ctrl_sig_src_wb_buffer	=> MEMORY_WRITEBACK_OUT_WB_SIGNALS(0),
		wb_ctrl_sig_dst_wb_buffer	=> MEMORY_WRITEBACK_OUT_WB_SIGNALS(0),

		------------------------------------------------------------------------
		-- Register File
			------------------------------------------------------------------------
			src_val_reg_file,
			dst_val_reg_file: IN std_logic_vector(15 DOWNTO 0);
			dec_SP: OUT std_logic;	-- Signal sent by ALU stage to decrement SP
		------------------------------------------------------------------------

		result_src_val 				=> EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT,
		result_dst_val 				=> EXECUTE_MEMORY_IN_ALU_DATA,
		result_src_addr				=> EXECUTE_MEMORY_IN_Rsrc_INDEX,
		result_dst_addr				=> EXECUTE_MEMORY_IN_Rdst_INDEX,
		I_BUBBLE_OUT				=> EXECUTE_MEMORY_IN_IBUBBLE,
		MEM_SIGNALS_OUT				=> EXECUTE_MEMORY_IN_MEM_SIGNALS,
		WB_SIGNALS_OUT				=> EXECUTE_MEMORY_IN_WB_SIGNALS,
		OPCODE_OUT					=> EXECUTE_MEMORY_IN_OPCODE,
		PC_OUT						=> EXECUTE_MEMORY_IN_PC
	);

	EXECUTE_MEMORY_BUFFER: ENTITY work.REG GENERIC MAP(n => 57) PORT MAP (
		CLK		=>	CLK,
		D 		=> (
					EXECUTE_MEMORY_IN_IBUBBLE&
					EXECUTE_MEMORY_IN_MEM_SIGNALS&
					EXECUTE_MEMORY_IN_WB_SIGNALS&
					EXECUTE_MEMORY_IN_OPCODE&
					EXECUTE_MEMORY_IN_Rdst_INDEX&
					EXECUTE_MEMORY_IN_Rsrc_INDEX&
					EXECUTE_MEMORY_IN_ALU_DATA&
					EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT&
					EXECUTE_MEMORY_IN_PC
					),
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>  (
					EXECUTE_MEMORY_OUT_IBUBBLE&
					EXECUTE_MEMORY_OUT_MEM_SIGNALS&
					EXECUTE_MEMORY_OUT_WB_SIGNALS&
					EXECUTE_MEMORY_OUT_OPCODE&
					EXECUTE_MEMORY_OUT_Rdst_INDEX&
					EXECUTE_MEMORY_OUT_Rsrc_INDEX&
					EXECUTE_MEMORY_OUT_ALU_DATA&
					EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT&
					EXECUTE_MEMORY_OUT_PC
					)
	);

	MEMORY_STAGE: ENTITY work.MEMORY PORT MAP (
		IBUBBLE_IN					=> EXECUTE_MEMORY_OUT_IBUBBLE,
		MEM_SIGNALS 				=> EXECUTE_MEMORY_OUT_MEM_SIGNALS,
		WB_SIGNALS_IN				=> EXECUTE_MEMORY_OUT_WB_SIGNALS,
		PREV_OPCODE					=> MEMORY_WRITEBACK_OUT_OPCODE,
		OPCODE_IN					=> EXECUTE_MEMORY_OUT_OPCODE,
		Rdst_INDEX_IN				=> EXECUTE_MEMORY_OUT_Rdst_INDEX,
		Rsrc_INDEX_IN				=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		DATA 						=> EXECUTE_MEMORY_OUT_ALU_DATA,
		ADDRESS_or_SP_or_SRC_RESULT => EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT,
		RAM_DATA_OUT:				=> DATA_MEM_DATA_OUT,
		PREV_RAM_VALUE				=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		PC:							=> EXECUTE_MEMORY_OUT_PC,
		IBUBBLE_OUT					=> MEMORY_WRITEBACK_IN_IBUBBLE,
		RAM_WRITE_EN				=> EXECUTE_MEMORY_OUT_MEM_SIGNALS(1),
		RAM_READ_EN					=> EXECUTE_MEMORY_OUT_MEM_SIGNALS(0),
		WB_SIGNALS_OUT				=> MEMORY_WRITEBACK_IN_WB_SIGNALS,
		OPCODE_OUT					=> MEMORY_WRITEBACK_IN_OPCODE,
		RAM_VALUE_or_DST_RESULT		=> MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT,
		SRC_RESULT					=> MEMORY_WRITEBACK_IN_SRC_RESULT,
		RAM_DATA_IN					=> DATA_MEM_DATA_IN,
		RAM_ADDRESS					=> DATA_MEM_ADDRESS,
		Rdst_INDEX_OUT				=> MEMORY_WRITEBACK_IN_Rdst_INDEX,
		Rsrc_INDEX_OUT:				=> MEMORY_WRITEBACK_IN_Rsrc_INDEX
		);

	MEMORY_WRITEBACK_BUFFER: ENTITY work.REG GENERIC MAP(n => 46) PORT MAP (
		CLK		=>	CLK,
		D 		=> (
					MEMORY_WRITEBACK_IN_IBUBBLE&
					MEMORY_WRITEBACK_IN_WB_SIGNALS&
					MEMORY_WRITEBACK_IN_OPCODE&
					MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT&
					MEMORY_WRITEBACK_IN_SRC_RESULT&
					MEMORY_WRITEBACK_IN_Rdst_INDEX&
					MEMORY_WRITEBACK_IN_Rsrc_INDEX
					),
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>  (
					MEMORY_WRITEBACK_OUT_IBUBBLE&
					MEMORY_WRITEBACK_OUT_WB_SIGNALS&
					MEMORY_WRITEBACK_OUT_OPCODE&
					MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT&
					MEMORY_WRITEBACK_OUT_SRC_RESULT&
					MEMORY_WRITEBACK_OUT_Rdst_INDEX&
					MEMORY_WRITEBACK_OUT_Rsrc_INDEX
					)
	);

	WRITEBACK_STAGE: ENTITY work.WB PORT MAP (
		IBUBBLE 				=> MEMORY_WRITEBACK_OUT_IBUBBLE,
		WB_SIGNALS 				=> MEMORY_WRITEBACK_OUT_WB_SIGNALS,
		RAM_VALUE_or_DST_RESULT => MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		SRC_RESULT 				=> MEMORY_WRITEBACK_OUT_SRC_RESULT,
		OPCODE 					=> MEMORY_WRITEBACK_OUT_OPCODE,
		Rdst_INDEX 				=> MEMORY_WRITEBACK_OUT_Rdst_INDEX,
		Rsrc_INDEX 				=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,

		----------------- REGISTERS ENABLES ----------------------
			PC_WRITE_EN 			=>WRITEBACK_FETCH_PC_SELECTION_BIT,
			REGISTERS_WRITE_ENABLES =>
			OUT_BUS: INOUT std_logic_vector(31 DOWNTO 0)
		----------------------------------------------------------
		);

END processor_arch;



-- TODO:
-- Register file
-- Reset and interrupt are not handled yet!!!
-- REGISTER FLAG / SIZE PC
