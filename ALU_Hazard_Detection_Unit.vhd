LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


--***
--***	This component is responsible for detecting
--***	location of alu operands
--***


-- @parameters
-- register_dst, register_src, opcode_buffer_before_alu, result_src, result_dst,
-- wb_ctrl_sig_src_mem_buffer, wb_ctrl_sig_dst_mem_buffer, src_in_mem_buffer_src, src_in_mem_buffer_dst,
-- dst_in_mem_buffer_src, dst_in_mem_buffer_dst, src_addr_wb_buffer, dst_addr_wb_buffer, wb_ctrl_sig_src_wb_buffer,
-- wb_ctrl_sig_dst_wb_buffer, src_in_wb_buffer_src, src_in_wb_buffer_dst, dst_in_wb_buffer_src, dst_in_wb_buffer_dst, 
-- LDM_operation, dst_in_immediate

ENTITY alu_hazard_detection IS
 PORT (	
		---------Current address of r_src,r_dst from register file----------------
		---------This comes from the buffer before ALU-------------------------
		register_dst,register_src : IN std_logic_vector(2 DOWNTO 0);
		--current value of opcode
		opcode_buffer_before_alu : IN std_logic_vector(4 DOWNTO 0);


		-------------------------ALU to ALU forwarding----------------------------------
		--Address of previous ALU results saved in the buffer before Memory Stage
		--This comes from the buffer after ALU-------------------------
		result_src,result_dst	: IN std_logic_vector(2 DOWNTO 0);

		--write back signals stored in buffer after ALU from previous operation
		--to either write the value back in the registers or not
		wb_ctrl_sig_src_mem_buffer,
		wb_ctrl_sig_dst_mem_buffer : IN std_logic;

		src_in_mem_buffer_src,src_in_mem_buffer_dst,
		dst_in_mem_buffer_src,dst_in_mem_buffer_dst : OUT std_logic;
		-------------------------ALU to ALU forwarding----------------------------------


		-------------------------Memory to ALU forwarding-------------------------------
		--Address of previous-previous(load , nothing , use)
		--saved in the buffer after Memory Stage
		src_addr_wb_buffer,dst_addr_wb_buffer	: IN std_logic_vector(2 DOWNTO 0);

		--write back signals stored in buffer after Memory from previous operation
		--to either write the value back in the registers or not
		--this is caused by hazard in previous-previous operation
		wb_ctrl_sig_src_wb_buffer,
		wb_ctrl_sig_dst_wb_buffer : IN std_logic;

		src_in_wb_buffer_src,src_in_wb_buffer_dst,
		dst_in_wb_buffer_src,dst_in_wb_buffer_dst : OUT std_logic;
		-------------------------Memory to ALU forwarding-------------------------------



		-------------------------Immediate Value-------------------------------
		--This signal is received from the decoding stage if this is an operation
		--which requires immediate value forwarding
		LDM_operation : IN std_logic;
		--this is valid for either load,store or shifting with immediate value
		-- TODO: check previous comment
		dst_in_immediate	: OUT std_logic
		-------------------------Immediate Value-------------------------------


);
END ENTITY alu_hazard_detection;

ARCHITECTURE alu_hazard_detection_arch OF alu_hazard_detection IS
BEGIN

	--------------------------- ALU to ALU ---------------------------------------
	src_in_mem_buffer_dst <= '1'
		when( register_src=result_dst AND wb_ctrl_sig_dst_mem_buffer = '1' )
	else '0';
	
	src_in_mem_buffer_src <= '1'
		when( register_src=result_src AND wb_ctrl_sig_src_mem_buffer = '1' )
	else '0';

	dst_in_mem_buffer_dst <= '1'
		when( register_dst=result_dst AND wb_ctrl_sig_dst_mem_buffer = '1' )
	else '0';

	dst_in_mem_buffer_src <= '1'
		when( register_dst=result_src AND wb_ctrl_sig_src_mem_buffer = '1' )
	else '0';
	--------------------------- ALU to ALU ---------------------------------------



	--------------------------- Memory to ALU ------------------------------------
	src_in_wb_buffer_dst <= '1'
		when( register_src=dst_addr_wb_buffer AND wb_ctrl_sig_dst_wb_buffer = '1' )
	else '0';

	src_in_wb_buffer_src <= '1'
		when( register_src=src_addr_wb_buffer AND wb_ctrl_sig_src_wb_buffer = '1' )
	else '0';

	dst_in_wb_buffer_dst <= '1'
		when( register_dst=dst_addr_wb_buffer AND wb_ctrl_sig_dst_wb_buffer = '1' )
	else '0';

	dst_in_wb_buffer_src <= '1'
		when( register_dst=src_addr_wb_buffer AND wb_ctrl_sig_src_wb_buffer = '1' )
	else '0';
	--------------------------- Memory to ALU ------------------------------------


	----------------------- Fetch to ALU (immediate) -----------------------------
	dst_in_immediate<=LDM_operation;
	----------------------- Fetch to ALU (immediate) -----------------------------


END alu_hazard_detection_arch;

