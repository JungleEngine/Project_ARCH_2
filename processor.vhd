LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***	This is a 5-stage pipelined processor based on MIPS architecture
--***

ENTITY processor IS
	PORT(
 		CLK : IN std_logic;
 		RST : IN std_logic;
 		INTERRUPT_PIN : IN std_logic
		);
END ENTITY processor;


ARCHITECTURE processor_arch OF processor IS

SIGNAL GND: std_logic_vector(40 DOWNTO 0) := (OTHERS => '0');
SIGNAL VCC: std_logic_vector(40 DOWNTO 0) := (OTHERS => '1');

SIGNAL FETCH_DECODE_IN_IR_VAL: std_logic_vector(15 DOWNTO 0);
SIGNAL FETCH_DECODE_IN_PC_VAL: std_logic_vector(8 DOWNTO 0);
SIGNAL FETCH_DECODE_IN_IBUBBLE: std_logic;
SIGNAL FETCH_DECODE_OUT_IR_VAL: std_logic_vector(15 DOWNTO 0);
SIGNAL FETCH_DECODE_OUT_PC_VAL: std_logic_vector(8 DOWNTO 0);
SIGNAL FETCH_DECODE_OUT_IBUBBLE: std_logic;
SIGNAL FETCH_DECODE_BUFFER_OUT: std_logic_vector(26 DOWNTO 0);
SIGNAL FETCH_DECODE_BUFFER_IN: std_logic_vector(26 DOWNTO 0) ;


SIGNAL DECODE_EXECUTE_IN_IBUBBLE: std_logic;
SIGNAL DECODE_EXECUTE_IN_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_PC_OUT: std_logic_vector(8 DOWNTO 0);
SIGNAL DECODE_EXECUTE_IN_EA_OR_SP_SH_VALUE: std_logic_vector(8 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_IBUBBLE: std_logic;
SIGNAL DECODE_EXECUTE_OUT_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_PC_OUT: std_logic_vector(8 DOWNTO 0);
SIGNAL DECODE_EXECUTE_OUT_EA_OR_SP_SH_VALUE: std_logic_vector(8 DOWNTO 0);
SIGNAL DECODE_STAGE_STALL: std_logic;
SIGNAL DECODE_EXECUTE_BUFFER_OUT: std_logic_vector(33 DOWNTO 0);
SIGNAL DECODE_EXECUTE_BUFFER_IN: std_logic_vector(33 DOWNTO 0) := DECODE_EXECUTE_IN_IBUBBLE&
																  DECODE_EXECUTE_IN_WB_SIGNALS&
																  DECODE_EXECUTE_IN_MEM_SIGNALS&
																  DECODE_EXECUTE_IN_Rsrc_INDEX&
																  DECODE_EXECUTE_IN_Rdst_INDEX&
																  DECODE_EXECUTE_IN_OPCODE&
																  DECODE_EXECUTE_IN_PC_OUT&
																  DECODE_EXECUTE_IN_EA_OR_SP_SH_VALUE;

SIGNAL EXECUTE_MEMORY_IN_IBUBBLE: std_logic;
SIGNAL EXECUTE_MEMORY_IN_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_ALU_DATA: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_IN_PC: std_logic_vector(8 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_IBUBBLE: std_logic;
SIGNAL EXECUTE_MEMORY_OUT_MEM_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_ALU_DATA: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_OUT_PC: std_logic_vector(8 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_BUFFER_OUT: std_logic_vector(56 DOWNTO 0);
SIGNAL EXECUTE_MEMORY_BUFFER_IN: std_logic_vector(56 DOWNTO 0) := EXECUTE_MEMORY_IN_IBUBBLE&
																  EXECUTE_MEMORY_IN_MEM_SIGNALS&
																  EXECUTE_MEMORY_IN_WB_SIGNALS&
																  EXECUTE_MEMORY_IN_OPCODE&
																  EXECUTE_MEMORY_IN_Rdst_INDEX&
																  EXECUTE_MEMORY_IN_Rsrc_INDEX&
																  EXECUTE_MEMORY_IN_ALU_DATA&
																  EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT&
																  EXECUTE_MEMORY_IN_PC;

SIGNAL MEMORY_WRITEBACK_IN_IBUBBLE: std_logic;
SIGNAL MEMORY_WRITEBACK_IN_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_IN_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_IN_SRC_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_IN_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_IN_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_IBUBBLE: std_logic;
SIGNAL MEMORY_WRITEBACK_OUT_WB_SIGNALS: std_logic_vector(1 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_OPCODE: std_logic_vector(4 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_SRC_RESULT: std_logic_vector(15 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_Rdst_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_OUT_Rsrc_INDEX: std_logic_vector(2 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_BUFFER_OUT: std_logic_vector(45 DOWNTO 0);
SIGNAL MEMORY_WRITEBACK_BUFFER_IN: std_logic_vector(45 DOWNTO 0) := MEMORY_WRITEBACK_IN_IBUBBLE&
																	MEMORY_WRITEBACK_IN_WB_SIGNALS&
																	MEMORY_WRITEBACK_IN_OPCODE&
																	MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT&
																	MEMORY_WRITEBACK_IN_SRC_RESULT&
																	MEMORY_WRITEBACK_IN_Rdst_INDEX&
																	MEMORY_WRITEBACK_IN_Rsrc_INDEX;

SIGNAL INST_MEM_IR: std_logic_vector(15 DOWNTO 0);
SIGNAL INST_MEM_ADDRESS: std_logic_vector(8 DOWNTO 0);
SIGNAL DATA_MEM_ADDRESS: std_logic_vector(8 DOWNTO 0);
SIGNAL DATA_MEM_DATA_IN: std_logic_vector(15 DOWNTO 0);
SIGNAL DATA_MEM_DATA_OUT: std_logic_vector(15 DOWNTO 0);
SIGNAL SIG_DATA_MEM_WRITE: std_logic;

SIGNAL SIG_DECODE_STAGE_OUTPUT: std_logic_vector(8 DOWNTO 0);

SIGNAL DECODE_FETCH_PC_SELECTION_BIT: std_logic;
SIGNAL WRITEBACK_FETCH_PC_SELECTION_BIT: std_logic;

SIGNAL SP_INC: std_logic;
SIGNAL SP_DEC: std_logic;

SIGNAL PC_WRITE_ENABLE: std_logic;
SIGNAL WRITEBACK_FLAG_REGISTER_WRITE_ENABLE: std_logic;
SIGNAL ALU_FLAG_REGISTER_WRITE_ENABLE: std_logic;
SIGNAL DECODE_FLAG_REGISTER_WRITE_ENABLE: std_logic;

SIGNAL WRITEBACK_FLAG_REGISTER_DATA: std_logic_vector(3 DOWNTO 0);
SIGNAL ALU_FLAG_REGISTER_DATA: std_logic_vector(3 DOWNTO 0);
SIGNAL DECODE_FLAG_REGISTER_DATA: std_logic_vector(3 DOWNTO 0);

SIGNAL WRITEBACK_REGISTERS_BUS: std_logic_vector(31 DOWNTO 0);
SIGNAL REGISTERS_ALU_BUS: std_logic_vector(31 DOWNTO 0);
SIGNAL REGISTERS_DECODE_BUS: std_logic_vector(15 DOWNTO 0);

SIGNAL PC_VALUE: std_logic_vector(8 DOWNTO 0);
SIGNAL SP_VALUE: std_logic_vector(8 DOWNTO 0);
SIGNAL FR_VALUE: std_logic_vector(3 DOWNTO 0);
SIGNAL FETCH_PC_VALUE: std_logic_vector(8 DOWNTO 0);
SIGNAL SIG_BUFFER_IBUBBLE_FROM_MEMORY_STAGE: std_logic;
SIGNAL DECODE_DECODE_OUT_PC_SELECTION_BIT :std_logic;

BEGIN

	FETCH_DECODE_BUFFER_IN <= 	DECODE_FETCH_PC_SELECTION_BIT&

								FETCH_DECODE_IN_IR_VAL&
			 			   		FETCH_DECODE_IN_PC_VAL&
			 			   		FETCH_DECODE_IN_IBUBBLE
			 			   		;
			 			   		
	DECODE_EXECUTE_BUFFER_IN <= DECODE_EXECUTE_IN_IBUBBLE&
																  DECODE_EXECUTE_IN_WB_SIGNALS&
																  DECODE_EXECUTE_IN_MEM_SIGNALS&
																  DECODE_EXECUTE_IN_Rsrc_INDEX&
																  DECODE_EXECUTE_IN_Rdst_INDEX&
																  DECODE_EXECUTE_IN_OPCODE&
																  DECODE_EXECUTE_IN_PC_OUT&
																  DECODE_EXECUTE_IN_EA_OR_SP_SH_VALUE;		 			   		
  
   EXECUTE_MEMORY_BUFFER_IN <= EXECUTE_MEMORY_IN_IBUBBLE&
																  EXECUTE_MEMORY_IN_MEM_SIGNALS&
																  EXECUTE_MEMORY_IN_WB_SIGNALS&
																  EXECUTE_MEMORY_IN_OPCODE&
																  EXECUTE_MEMORY_IN_Rdst_INDEX&
																  EXECUTE_MEMORY_IN_Rsrc_INDEX&
																  EXECUTE_MEMORY_IN_ALU_DATA&
																  EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT&
																  EXECUTE_MEMORY_IN_PC;

 MEMORY_WRITEBACK_BUFFER_IN <= MEMORY_WRITEBACK_IN_IBUBBLE&
								MEMORY_WRITEBACK_IN_WB_SIGNALS&
								MEMORY_WRITEBACK_IN_OPCODE&
								MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT&
								MEMORY_WRITEBACK_IN_SRC_RESULT&
								MEMORY_WRITEBACK_IN_Rdst_INDEX&
								MEMORY_WRITEBACK_IN_Rsrc_INDEX;


  	FETCH_DECODE_OUT_IR_VAL <= FETCH_DECODE_BUFFER_OUT(25 DOWNTO 10);
	FETCH_DECODE_OUT_PC_VAL <= FETCH_DECODE_BUFFER_OUT(9 DOWNTO 1);
	FETCH_DECODE_OUT_IBUBBLE <= FETCH_DECODE_BUFFER_OUT(0);
	DECODE_DECODE_OUT_PC_SELECTION_BIT <= FETCH_DECODE_BUFFER_OUT(26);

	DECODE_EXECUTE_OUT_IBUBBLE <= DECODE_EXECUTE_BUFFER_OUT(33);
	DECODE_EXECUTE_OUT_WB_SIGNALS <= DECODE_EXECUTE_BUFFER_OUT(32 DOWNTO 31);
	DECODE_EXECUTE_OUT_MEM_SIGNALS <= DECODE_EXECUTE_BUFFER_OUT(30 DOWNTO 29);
	DECODE_EXECUTE_OUT_Rsrc_INDEX <= DECODE_EXECUTE_BUFFER_OUT(28 DOWNTO 26);
	DECODE_EXECUTE_OUT_Rdst_INDEX <= DECODE_EXECUTE_BUFFER_OUT(25 DOWNTO 23);
	DECODE_EXECUTE_OUT_OPCODE <= DECODE_EXECUTE_BUFFER_OUT(22 DOWNTO 18);
	DECODE_EXECUTE_OUT_PC_OUT <= DECODE_EXECUTE_BUFFER_OUT(17 DOWNTO 9);
	DECODE_EXECUTE_OUT_EA_OR_SP_SH_VALUE <= DECODE_EXECUTE_BUFFER_OUT(8 DOWNTO 0);
	
	EXECUTE_MEMORY_OUT_IBUBBLE <= EXECUTE_MEMORY_BUFFER_OUT(56);
	EXECUTE_MEMORY_OUT_MEM_SIGNALS <= EXECUTE_MEMORY_BUFFER_OUT(55 DOWNTO 54);
	EXECUTE_MEMORY_OUT_WB_SIGNALS <= EXECUTE_MEMORY_BUFFER_OUT(53 DOWNTO 52);
	EXECUTE_MEMORY_OUT_OPCODE <= EXECUTE_MEMORY_BUFFER_OUT(51 DOWNTO 47);
	EXECUTE_MEMORY_OUT_Rdst_INDEX <= EXECUTE_MEMORY_BUFFER_OUT(46 DOWNTO 44);
	EXECUTE_MEMORY_OUT_Rsrc_INDEX <= EXECUTE_MEMORY_BUFFER_OUT(43 DOWNTO 41);
	EXECUTE_MEMORY_OUT_ALU_DATA <= EXECUTE_MEMORY_BUFFER_OUT(40 DOWNTO 25);
	EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT <= EXECUTE_MEMORY_BUFFER_OUT(24 DOWNTO 9);
	EXECUTE_MEMORY_OUT_PC <= EXECUTE_MEMORY_BUFFER_OUT(8 DOWNTO 0);

  MEMORY_WRITEBACK_OUT_IBUBBLE <= MEMORY_WRITEBACK_BUFFER_OUT(45);
	MEMORY_WRITEBACK_OUT_WB_SIGNALS <= MEMORY_WRITEBACK_BUFFER_OUT(44 DOWNTO 43);
	MEMORY_WRITEBACK_OUT_OPCODE <= MEMORY_WRITEBACK_BUFFER_OUT(42 DOWNTO 38);
	MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT <= MEMORY_WRITEBACK_BUFFER_OUT(37 DOWNTO 22);
	MEMORY_WRITEBACK_OUT_SRC_RESULT <= MEMORY_WRITEBACK_BUFFER_OUT(21 DOWNTO 6);
	MEMORY_WRITEBACK_OUT_Rdst_INDEX <= MEMORY_WRITEBACK_BUFFER_OUT(5 DOWNTO 3);
	MEMORY_WRITEBACK_OUT_Rsrc_INDEX <= MEMORY_WRITEBACK_BUFFER_OUT(2 DOWNTO 0);
																	
	REGISTER_FILE: ENTITY work.REG_FILE PORT MAP (
		CLK					=> CLK,
		RST					=> RST,
		SP_INC				=> SP_INC,
		SP_DEC				=> SP_DEC,
		PC_ENABLE 			=> PC_WRITE_ENABLE,
		WB_FR_ENABLE 		=> WRITEBACK_FLAG_REGISTER_WRITE_ENABLE,
		ALU_FR_ENABLE 		=> ALU_FLAG_REGISTER_WRITE_ENABLE,
		DECODE_FR_ENABLE 	=> DECODE_FLAG_REGISTER_WRITE_ENABLE,
		WB_WRITE_ENABLE => MEMORY_WRITEBACK_OUT_WB_SIGNALS,
		WB_Rdst_INDEX 		=> MEMORY_WRITEBACK_OUT_Rdst_INDEX,
		WB_Rsrc_INDEX 		=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,
		ALU_Rdst_INDEX 		=> DECODE_EXECUTE_OUT_Rdst_INDEX,
		ALU_Rsrc_INDEX		=> DECODE_EXECUTE_OUT_Rsrc_INDEX,
		DECODE_Rdst_INDEX 	=> DECODE_EXECUTE_IN_Rdst_INDEX,
		PC_IN_DATA 			=> FETCH_PC_VALUE,
		WB_FR_DATA			=> WRITEBACK_FLAG_REGISTER_DATA,
		ALU_FR_DATA			=> ALU_FLAG_REGISTER_DATA,
		DECODE_FR_DATA		=> DECODE_FLAG_REGISTER_DATA,
		IN_BUS				=> WRITEBACK_REGISTERS_BUS,
		ALU_OUT_BUS			=> REGISTERS_ALU_BUS,
		DECODE_OUT_BUS		=> REGISTERS_DECODE_BUS,
		PC_OUT_DATA			=> PC_VALUE,
		SP_OUT_DATA			=> SP_VALUE,
		FR_OUT_DATA			=> FR_VALUE
		);

	INST_MEMORY: ENTITY work.RAM PORT MAP (
		CLK,
		GND(0),
		INST_MEM_ADDRESS,
		VCC(15 DOWNTO 0), --DUMMY,
		INST_MEM_IR
		);

	DATA_MEMORY: ENTITY work.RAM PORT MAP (
		CLK,
		SIG_DATA_MEM_WRITE,
		DATA_MEM_ADDRESS,
		DATA_MEM_DATA_IN,
		DATA_MEM_DATA_OUT
		);

	FETCH_STAGE: ENTITY work.FETCH PORT MAP (
		INTERRUPT_PIN					=> INTERRUPT_PIN,
		DECODING_STAGE_OUTPUT 			=> SIG_DECODE_STAGE_OUTPUT,
		PC 								=> PC_VALUE,
		MEMORY_STAGE_OUTPUT				=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT(8 DOWNTO 0),
		MEMORY_OUTPUT 					=> INST_MEM_IR,
		MEMORY_SELECTOR_MEMORY_STAGE	=> WRITEBACK_FETCH_PC_SELECTION_BIT,
		DECODE_SELECTOR_DECODE_STAGE	=> DECODE_FETCH_PC_SELECTION_BIT,
		IR_OUTPUT_TO_DECODE 			=> FETCH_DECODE_IN_IR_VAL,
		PC_OUTPUT_TO_DECODE				=> FETCH_DECODE_IN_PC_VAL,
		I_BUBBLE 						=> FETCH_DECODE_IN_IBUBBLE,
		PC_WRITE 						=> PC_WRITE_ENABLE,
		PC_REGISTER_INPUT				=> FETCH_PC_VALUE,
		MEMORY_READ_ADDRESS 			=> INST_MEM_ADDRESS
	);

	FETCH_DECODE_BUFFER: ENTITY work.REG GENERIC MAP(n => 27) PORT MAP (
		CLK		=>	CLK,
		D 		=>	FETCH_DECODE_BUFFER_IN,
		RST		=>	RST,
		EN 		=>	VCC(0),
		Q 		=>	FETCH_DECODE_BUFFER_OUT
	);


	DECODE_STAGE: ENTITY work.DECODE PORT MAP (
		EXECUTE_MEMORY_WB_SIGNALS => EXECUTE_MEMORY_OUT_WB_SIGNALS,
		EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT => EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT,
		EXECUTE_MEMORY_OUT_ALU_DATA => EXECUTE_MEMORY_OUT_ALU_DATA,
		BUFFERED_PC_SELECTOR_BIT => DECODE_DECODE_OUT_PC_SELECTION_BIT,
		I_BUBBLE 				=> FETCH_DECODE_OUT_IBUBBLE,
		ALU_MEMR 				=> DECODE_EXECUTE_OUT_MEM_SIGNALS(0),
		MEM_MEMR				=> EXECUTE_MEMORY_OUT_MEM_SIGNALS(0),
		ALU_RSRC 				=> DECODE_EXECUTE_OUT_Rsrc_INDEX,
		ALU_RDST				=> DECODE_EXECUTE_OUT_Rdst_INDEX,
		MEM_RSRC 				=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		MEM_RDST				=> EXECUTE_MEMORY_OUT_Rdst_INDEX,
		ALU_WB_SIGNALS 			=> DECODE_EXECUTE_OUT_WB_SIGNALS,
		PC 						=> FETCH_DECODE_OUT_PC_VAL,
		IR 		 				=> FETCH_DECODE_OUT_IR_VAL,
		ALU_STAGE_OUTPUT_SRC	=> EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT,
		ALU_STAGE_OUTPUT_DST	=> EXECUTE_MEMORY_IN_ALU_DATA,
		OPCODE_FROM_EXECUTE		=> DECODE_EXECUTE_OUT_OPCODE,
		REGISTER_FILE_OUTPUT 	=> REGISTERS_DECODE_BUS,
		FLAG_REG 				=> FR_VALUE,
		SP 						=> SP_VALUE,
		FLAGS_REG_WRITE 		=> DECODE_FLAG_REGISTER_WRITE_ENABLE,
		SP_INC					=> SP_INC,
		FLAG_REG_OUT			=> DECODE_FLAG_REGISTER_DATA,
		PC_SELECTOR_BIT			=> DECODE_FETCH_PC_SELECTION_BIT,
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

	DECODE_EXECUTE_BUFFER: ENTITY work.REG GENERIC MAP(n => 34) PORT MAP (
		CLK		=>	CLK,
		D 		=>	DECODE_EXECUTE_BUFFER_IN,
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>  DECODE_EXECUTE_BUFFER_OUT
		);

	EXECUTE_STAGE: ENTITY work.EXECUTE PORT MAP (
	  buffered_ibubble => EXECUTE_MEMORY_OUT_IBUBBLE,
	  buffer_ibubble => SIG_BUFFER_IBUBBLE_FROM_MEMORY_STAGE,
 		immediate_val_fetch_stage 	=> FETCH_DECODE_OUT_IR_VAL,
		ibubble_alu_buffer			=> DECODE_EXECUTE_OUT_IBUBBLE,
		wb_signals          		=> DECODE_EXECUTE_OUT_WB_SIGNALS,
		mem_signals         		=> DECODE_EXECUTE_OUT_MEM_SIGNALS,
		pc                  		=> DECODE_EXECUTE_OUT_PC_OUT,
 		src_addr_alu_buffer			=> DECODE_EXECUTE_OUT_Rsrc_INDEX,
 		dst_addr_alu_buffer			=> DECODE_EXECUTE_OUT_Rdst_INDEX,
 		opcode_alu_buffer			=> DECODE_EXECUTE_OUT_OPCODE,
 		SP_or_EA_val_alu_buffer		=> DECODE_EXECUTE_OUT_EA_OR_SP_SH_VALUE,
 		wb_ctrl_sig_src_mem_buffer	=> EXECUTE_MEMORY_OUT_WB_SIGNALS(1),--TODO
		wb_ctrl_sig_dst_mem_buffer 	=> EXECUTE_MEMORY_OUT_WB_SIGNALS(0),--TODO
		src_addr_mem_buffer			=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		dst_addr_mem_buffer			=> EXECUTE_MEMORY_OUT_Rdst_INDEX,
		result_src_val_mem_buffer	=> EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT,
		result_dst_val_mem_buffer	=> EXECUTE_MEMORY_OUT_ALU_DATA,
		src_addr_wb_buffer			=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,
		dst_addr_wb_buffer			=> MEMORY_WRITEBACK_OUT_Rsrc_INDEX,
		src_val_wb_buffer			=> MEMORY_WRITEBACK_OUT_SRC_RESULT,
		dst_val_wb_buffer			=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		wb_ctrl_sig_src_wb_buffer	=> MEMORY_WRITEBACK_OUT_WB_SIGNALS(1),
		wb_ctrl_sig_dst_wb_buffer	=> MEMORY_WRITEBACK_OUT_WB_SIGNALS(0),
		src_val_reg_file			=> REGISTERS_ALU_BUS(15 DOWNTO 0),
		dst_val_reg_file			=> REGISTERS_ALU_BUS(31 DOWNTO 16),
		dec_SP						=> SP_DEC,	-- Signal sent by ALU stage to decrement SP
		FR_IN_VAL					=> FR_VALUE,
		FR_OUT_VAL					=> ALU_FLAG_REGISTER_DATA,
		FR_WRITE_EN 				=> ALU_FLAG_REGISTER_WRITE_ENABLE,
		result_src_val 				=> EXECUTE_MEMORY_IN_ADDRESS_SP_SRCRESULT,
		result_dst_val 				=> EXECUTE_MEMORY_IN_ALU_DATA,
		result_src_addr				=> EXECUTE_MEMORY_IN_Rsrc_INDEX,
		result_dst_addr				=> EXECUTE_MEMORY_IN_Rdst_INDEX,
		IBUBBLE_OUT					=> EXECUTE_MEMORY_IN_IBUBBLE,
		MEM_SIGNALS_OUT				=> EXECUTE_MEMORY_IN_MEM_SIGNALS,
		WB_SIGNALS_OUT				=> EXECUTE_MEMORY_IN_WB_SIGNALS,
		OPCODE_OUT					=> EXECUTE_MEMORY_IN_OPCODE,
		PC_OUT						=> EXECUTE_MEMORY_IN_PC
	);

	EXECUTE_MEMORY_BUFFER: ENTITY work.REG GENERIC MAP(n => 57) PORT MAP (
		CLK		=>	CLK,
		D 		=> EXECUTE_MEMORY_BUFFER_IN,
		RST 	=>	RST,
		EN 		=>	VCC(0),
		Q 		=>  EXECUTE_MEMORY_BUFFER_OUT
	);

	MEMORY_STAGE: ENTITY work.MEMORY PORT MAP (
		IBUBBLE_IN					=> EXECUTE_MEMORY_OUT_IBUBBLE,
		CLK           				=> CLK,
		RST           				=> RST,
		MEM_SIGNALS 				=> EXECUTE_MEMORY_OUT_MEM_SIGNALS,
		WB_SIGNALS_IN				=> EXECUTE_MEMORY_OUT_WB_SIGNALS,
		PREV_OPCODE					=> MEMORY_WRITEBACK_OUT_OPCODE,
		OPCODE_IN					=> EXECUTE_MEMORY_OUT_OPCODE,
		Rdst_INDEX_IN				=> EXECUTE_MEMORY_OUT_Rdst_INDEX,
		Rsrc_INDEX_IN				=> EXECUTE_MEMORY_OUT_Rsrc_INDEX,
		DATA 						=> EXECUTE_MEMORY_OUT_ALU_DATA,
		ADDRESS_or_SP_or_SRC_RESULT => EXECUTE_MEMORY_OUT_ADDRESS_SP_SRCRESULT,
		RAM_DATA_OUT				=> DATA_MEM_DATA_OUT,
		PREV_RAM_VALUE				=> MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		PC							=> EXECUTE_MEMORY_OUT_PC,
		SIG_BUFFER_IBUBBLE    => SIG_BUFFER_IBUBBLE_FROM_MEMORY_STAGE,
		IBUBBLE_OUT					=> MEMORY_WRITEBACK_IN_IBUBBLE,
		RAM_WRITE_EN				=> SIG_DATA_MEM_WRITE,
		WB_SIGNALS_OUT				=> MEMORY_WRITEBACK_IN_WB_SIGNALS,
		OPCODE_OUT					=> MEMORY_WRITEBACK_IN_OPCODE,
		RAM_VALUE_or_DST_RESULT		=> MEMORY_WRITEBACK_IN_RAM_VALUE_or_DST_RESULT,
		SRC_RESULT					=> MEMORY_WRITEBACK_IN_SRC_RESULT,
		RAM_DATA_IN					=> DATA_MEM_DATA_IN,
		RAM_ADDRESS					=> DATA_MEM_ADDRESS,
		Rdst_INDEX_OUT				=> MEMORY_WRITEBACK_IN_Rdst_INDEX,
		Rsrc_INDEX_OUT				=> MEMORY_WRITEBACK_IN_Rsrc_INDEX
		);

	MEMORY_WRITEBACK_BUFFER: ENTITY work.REG GENERIC MAP(n => 46) PORT MAP (
		CLK		=> CLK,
		D 		=> MEMORY_WRITEBACK_BUFFER_IN,
		RST 	=> GND(0),
		EN 		=> VCC(0),
		Q 		=> MEMORY_WRITEBACK_BUFFER_OUT
	);

	WRITEBACK_STAGE: ENTITY work.WB PORT MAP (
		IBUBBLE 				=> MEMORY_WRITEBACK_OUT_IBUBBLE,
		RST => RST,
		WB_SIGNALS 				=> MEMORY_WRITEBACK_OUT_WB_SIGNALS,
		RAM_VALUE_or_DST_RESULT => MEMORY_WRITEBACK_OUT_RAM_VALUE_or_DST_RESULT,
		SRC_RESULT 				=> MEMORY_WRITEBACK_OUT_SRC_RESULT,
		OPCODE 					=> MEMORY_WRITEBACK_OUT_OPCODE,
		PC_WRITE_EN 			=> WRITEBACK_FETCH_PC_SELECTION_BIT,
		FR_WRITE_EN 			=> WRITEBACK_FLAG_REGISTER_WRITE_ENABLE,
		FR_DATA 				=> WRITEBACK_FLAG_REGISTER_DATA,
		OUT_BUS 				=> WRITEBACK_REGISTERS_BUS
		);

END processor_arch;



-- TODO:
-- Register file
-- Reset and interrupt are not handled yet!!!
-- REGISTER FLAG / SIZE PC
