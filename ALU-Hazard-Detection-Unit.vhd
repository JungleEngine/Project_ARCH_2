LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


--***
--***	This component is responsible for detecting
--***	location of alu operands
--***

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
		src_write_back_buffer_after_alu,
		dst_write_back_buffer_after_alu : IN std_logic;

		src_in_result_src,src_in_result_dst,
		dst_in_result_src,dst_in_result_dst : OUT std_logic;
		-------------------------ALU to ALU forwarding----------------------------------


		-------------------------Memory to ALU forwarding-------------------------------
		--Address of previous-previous(load , nothing , use) 
		--saved in the buffer after Memory Stage
		memory_src,memory_dst	: IN std_logic_vector(2 DOWNTO 0);

		--write back signals stored in buffer after Memory from previous operation
		--to either write the value back in the registers or not
		--this is caused by hazard in previous-previous operation
		src_write_back_buffer_after_memory,
		dst_write_back_buffer_after_memory : IN std_logic;

		src_in_memory_src,src_in_memory_dst,
		dst_in_memory_src,dst_in_memory_dst : OUT std_logic;
		-------------------------Memory to ALU forwarding-------------------------------



		-------------------------Immediate Value-------------------------------
		--This signal is received from the decoding stage if this is an operation
		--which requires immediate value forwarding
		LDM_operation : IN std_logic;
		--this is valid for either load,store or shifting with immediate value
		dst_in_immediate	: OUT std_logic

		-------------------------Immediate Value-------------------------------


);
END ENTITY alu_hazard_detection;

ARCHITECTURE alu_hazard_detection_arch OF alu_hazard_detection IS
BEGIN

	---------------------------ALU to ALU---------------------------------------
	src_in_result_dst <= '1'
		when( register_src=result_dst AND dst_write_back_buffer_after_alu = '1' )
	else '0';
	
	src_in_result_src <= '1'
		when( register_src=result_src AND src_write_back_buffer_after_alu = '1' )
	else '0';

	dst_in_result_dst <= '1'
		when( register_dst=result_dst AND dst_write_back_buffer_after_alu = '1' )
	else '0';

	dst_in_result_src <= '1'
		when( register_dst=result_src AND src_write_back_buffer_after_alu = '1' )
	else '0';
	---------------------------ALU to ALU---------------------------------------



	---------------------------Memory to ALU------------------------------------
	src_in_memory_dst <= '1'
		when( register_src=memory_dst AND dst_write_back_buffer_after_memory = '1' )
	else '0';

	src_in_memory_src <= '1'
		when( register_src=memory_src AND src_write_back_buffer_after_memory = '1' )
	else '0';

	dst_in_memory_dst <= '1'
		when( register_dst=memory_dst AND dst_write_back_buffer_after_memory = '1' )
	else '0';

	dst_in_memory_src <= '1'
		when( register_dst=memory_src AND src_write_back_buffer_after_memory = '1' )
	else '0';
	---------------------------Memory to ALU------------------------------------


	-----------------------Fetch to ALU (immediate)-----------------------------
	dst_in_immediate<=LDM_operation;
	-----------------------Fetch to ALU (immediate)-----------------------------


END alu_hazard_detection_arch;

