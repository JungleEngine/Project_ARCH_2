LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***	This component is responsible for choosing
--***	the right operands for the ALU
--***

--@parameters
--result_dst_val_mem_buffer,result_src_val_mem_buffer,dst_val_reg_file,src_val_reg_file,immediate,src_val_wb_buffer,dst_val_wb_buffer,
--dst_in_mem_buffer_src,dst_in_mem_buffer_dst,src_in_mem_buffer_src,src_in_mem_buffer_dst,
--src_in_wb_buffer_src,dst_in_wb_buffer_dst,dst_in_wb_buffer_src,dst_in_wb_buffer_dst,dst_in_immediate,destination,source
ENTITY alu_operands_selection IS
 PORT (	
 		-------------------------< Possible ALU operands--------------------------------
		---------Previous ALU results saved in the buffer before Memory Stage---
		result_dst_val_mem_buffer,result_src_val_mem_buffer,
		---------Current value of r_src,r_dst from register file----------------
		dst_val_reg_file,src_val_reg_file,
		---------Immediate value forwarded from Fetch stage when immediate opcode
		immediate_val_fetch_stage,
		---------Value forwarded from memory stage if the operand is in memory--
		src_val_wb_buffer,dst_val_wb_buffer	

		: IN std_logic_vector(15 DOWNTO 0);
		------------------------- Possible ALU operands />-------------------------------
		
		-------------------------< Selectors for operands--------------------------------
		dst_in_mem_buffer_src,dst_in_mem_buffer_dst,	--this can be reduced into two selectors only
		src_in_mem_buffer_src,src_in_mem_buffer_dst,	
		
		src_in_wb_buffer_src,src_in_wb_buffer_dst,		--pop or load the src.	TODO:find if this is for previous command only or more than one level
		dst_in_wb_buffer_src,dst_in_wb_buffer_dst,		--pop or load the dst

		dst_in_immediate	--destination is an immediate value which is passed from fetch
						--TODO: differentiate between forwarded immediate value and the 5 bit shift immediate value
						--TODO: on ALU accept shift as input and select it with the opcode
		: IN std_logic;
		------------------------- Selectors for operands/>-------------------------------
		
		-------------------------< Operands out -----------------------------------------
		ALU_destination_input,ALU_source_input
		: OUT std_logic_vector(15 downto 0)
		------------------------- Operands out/>-----------------------------------------
						 );
END ENTITY alu_operands_selection;

ARCHITECTURE alu_operands_selection_arch OF alu_operands_selection IS  

BEGIN
	ALU_source_input <= 
		src_val_wb_buffer						when (src_in_wb_buffer_src='1')
	else		
		dst_val_wb_buffer						when (src_in_wb_buffer_dst='1')
	else
		result_src_val_mem_buffer 				when (src_in_mem_buffer_src='1')
	else
		result_dst_val_mem_buffer 				when (src_in_mem_buffer_dst='1')
	else
		src_val_reg_file;

	ALU_destination_input <=
		immediate_val_fetch_stage 				when (dst_in_immediate='1')
	else
		src_val_wb_buffer						when (dst_in_wb_buffer_src='1')
	else		
		dst_val_wb_buffer						when (dst_in_wb_buffer_dst='1')
	else
		result_src_val_mem_buffer 				when (dst_in_mem_buffer_src='1')
	else
		result_dst_val_mem_buffer 				when (dst_in_mem_buffer_dst='1')
	else
		dst_val_reg_file;
		
END alu_operands_selection_arch;

