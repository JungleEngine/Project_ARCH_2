LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***
--***	This is the ALU stage
--***	ALU buffer means the buffer before ALU stage
--***
--***

ENTITY EXECUTE IS
 PORT (	

 		--from Fetch Stage
 		immediate_val_fetch_stage: IN std_logic_vector(15 DOWNTO 0);


 		--from Decode Stage
		ibubble_alu_buffer		: IN std_logic;--Stall signal sent by Decode stage
		opcode_decode_stage		: IN std_logic_vector(4 DOWNTO 0);--Opcode bits sent by Decode stage
		wb_signals,mem_signals : IN std_logic_vector(1 downto 0);
		pc : IN std_logic_vector(8 DOWNTO 0);


 		--from buffer before ALU
 		src_addr_alu_buffer,dst_addr_alu_buffer
 		: IN std_logic_vector(2 DOWNTO 0);
 		--opcode stored in buffer before alu
 		opcode_alu_buffer
 		: IN std_logic_vector(4 DOWNTO 0);
 		SP_or_EA_val_alu_buffer
 		: IN std_logic_vector(8 DOWNTO 0);


 		--from buffer before Memory write back signals
 		wb_ctrl_sig_src_mem_buffer,
		wb_ctrl_sig_dst_mem_buffer
		: IN std_logic;
		--from buffer before Memory after ALU
		src_addr_mem_buffer,dst_addr_mem_buffer
		: IN std_logic_vector(2 DOWNTO 0);
		--from buffer before Memory , values of either the result of ALU or whatever it passes
		result_src_val_mem_buffer,result_dst_val_mem_buffer
		: IN std_logic_vector(15 DOWNTO 0);


		-- from buffer before Write back and after Memory Stage
		src_addr_wb_buffer,
		dst_addr_wb_buffer
		: IN std_logic_vector(2 DOWNTO 0);
		src_val_wb_buffer,
		dst_val_wb_buffer
		:IN std_logic_vector(15 DOWNTO 0);
		-- from buffer before Write back and after Memory stage
		wb_ctrl_sig_src_wb_buffer,
		wb_ctrl_sig_dst_wb_buffer
		: IN std_logic;



		------------------------------------------------------------------------
		-- Register File
		------------------------------------------------------------------------
		src_val_reg_file,
		dst_val_reg_file
		: IN std_logic_vector(15 DOWNTO 0);
		-------------------------< SP register signals -----------------------------------------
		dec_SP: OUT std_logic;	-- Signal sent by ALU stage to decrement SP
		-------------------------- SP register signals />-----------------------------------------

		FR_IN_VAL: IN std_logic_vector(3 DOWNTO 0);
		FR_OUT_VAL: OUT std_logic_vector(3 DOWNTO 0);
		FR_WRITE_EN: OUT std_logic;
		------------------------------------------------------------------------
		--Output to be passed to the next stage buffer
		------------------------------------------------------------------------
		result_src_val, --SP , EA , ALU source output val
		result_dst_val --ALU destination output val , destination register from alu operands selection
		: OUT std_logic_vector(15 DOWNTO 0);

		result_src_addr,
		result_dst_addr
		: OUT std_logic_vector(2 DOWNTO 0);

		IBUBBLE_OUT: OUT std_logic;
		MEM_SIGNALS_OUT: OUT std_logic_vector(1 DOWNTO 0);
		WB_SIGNALS_OUT: OUT std_logic_vector(1 DOWNTO 0);
		OPCODE_OUT: OUT std_logic_vector(4 DOWNTO 0);
		PC_OUT: OUT std_logic_vector(8 DOWNTO 0)

	);
END ENTITY EXECUTE;

ARCHITECTURE EXECUTE_ARCH OF EXECUTE IS
	CONSTANT CONST_PUSH: std_logic_vector(4 downto 0) := "01101";
	CONSTANT CONST_CALL: std_logic_vector(4 downto 0) := "11011";

	SIGNAL
	src_in_mem_buffer_src,
	src_in_mem_buffer_dst,
	dst_in_mem_buffer_src,
	dst_in_mem_buffer_dst,
	src_in_wb_buffer_src,
	src_in_wb_buffer_dst,
	dst_in_wb_buffer_src,
	dst_in_wb_buffer_dst,
	dst_in_immediate --TODO: wtf is this??
	: std_logic; 

	SIGNAL
	ALU_source_input,ALU_destination_input,
	ALU_source_output,ALU_destination_output:std_logic_vector(15 DOWNTO 0);


BEGIN

	ALU_Hazard_Detection_Unit: ENTITY work.alu_hazard_detection PORT MAP (
		dst_addr_alu_buffer,
		src_addr_alu_buffer,
		opcode_alu_buffer,
		src_addr_mem_buffer,
		dst_addr_mem_buffer,
		wb_ctrl_sig_src_mem_buffer,
		wb_ctrl_sig_dst_mem_buffer,
		src_in_mem_buffer_src,
		src_in_mem_buffer_dst,
		dst_in_mem_buffer_src,
		dst_in_mem_buffer_dst,
		src_addr_wb_buffer,
		dst_addr_wb_buffer,
		wb_ctrl_sig_src_wb_buffer,
		wb_ctrl_sig_dst_wb_buffer,
		src_in_wb_buffer_src,
		src_in_wb_buffer_dst,
		dst_in_wb_buffer_src,
		dst_in_wb_buffer_dst,
		dst_in_immediate
		);
	
	ALU_Operands_Selection_Unit: ENTITY work.alu_operands_selection PORT MAP(
		result_dst_val_mem_buffer,
		result_src_val_mem_buffer,
		dst_val_reg_file,
		src_val_reg_file,
		immediate_val_fetch_stage,
		src_val_wb_buffer,
		dst_val_wb_buffer,
		dst_in_mem_buffer_src,
		dst_in_mem_buffer_dst,
		src_in_mem_buffer_src,
		src_in_mem_buffer_dst,
		src_in_wb_buffer_src,
		dst_in_wb_buffer_dst,
		dst_in_wb_buffer_src,
		dst_in_wb_buffer_dst,
		dst_in_immediate,
		ALU_destination_input,
		ALU_source_input
		);

	ALU_Output_Selection_Unit: ENTITY work.alu_output_selection PORT MAP(
		opcode_alu_buffer,
		ALU_source_output,
		SP_or_EA_val_alu_buffer,
		result_src_val,
		ALU_destination_output,
		ALU_destination_input,
		result_dst_val
		);

	ALU: ENTITY work.alu PORT MAP (
		A 				=> ALU_destination_input,
		B 				=> ALU_source_input,
  		FLAG_REG 		=> FR_IN_VAL,
       	SEL 			=> opcode_alu_buffer,
       	FLAG_REG_INPUT  => FR_OUT_VAL,
       	FLAG_REG_WRITE  => FR_WRITE_EN,
       	F_SRC 			=> ALU_source_output,
       	F_DST 			=> ALU_destination_output
		);





	--passing addresses of the registers to the next stage
	result_src_addr<=src_addr_alu_buffer;
	result_dst_addr<=dst_addr_alu_buffer;

	OPCODE_OUT <= opcode_alu_buffer;
	IBUBBLE_OUT <= ibubble_alu_buffer;
	MEM_SIGNALS_OUT <= mem_signals;
	WB_SIGNALS_OUT<= wb_signals;
	PC_OUT <= pc;

	--TODO: this is not right, check all conditions and check what decode is sending
	dec_SP <= '1' when (ibubble_alu_buffer='1' OR opcode_alu_buffer = CONST_PUSH OR opcode_alu_buffer = CONST_CALL)
	else '0';

END EXECUTE_ARCH;

