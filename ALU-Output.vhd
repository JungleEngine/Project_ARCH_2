LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


--***
--***	This component is responsible for choosing
--***	the values for the buffer after ALU
--***	either by passing ALU output, SP value, EA, OR simply Rdst value from
--***	ALU operands selection unit
--***


ENTITY alu_output_selection IS
 PORT (	
 		opcode
 		: IN std_logic_vector(4 DOWNTO 0);
		-------------------------< Possible Result SRC operands (Address)-----------------------

		alu_src_output
		: IN std_logic_vector(15 DOWNTO 0);

		buffered_SP_or_EA_unextended --previous value of stack pointer passed through the buffer before ALU
		: IN std_logic_vector(9 DOWNTO 0);

		result_src --value passed to the buffer after ALU
		: OUT std_logic_vector(15 DOWNTO 0);
		------------------------- Possible Result SRC operands />-------------------------------


		-------------------------< Possible Result DST operands (Value)-------------------------
		alu_dst_output,
		dst_from_operands_selection_unit --value of destination register choosen by the operands unit
		: IN std_logic_vector(15 DOWNTO 0);

		result_dst --value passed to the buffer after ALU
		: OUT std_logic_vector(15 DOWNTO 0)
		------------------------- Possible Result DST operands />-------------------------------
						 );
END ENTITY alu_output_selection;


ARCHITECTURE alu_output_selection_arch OF alu_output_selection IS  
	--TODO check if these are the only opcodes needed
	CONSTANT CONST_PUSH: std_logic_vector(4 downto 0) := "01101";
	CONSTANT CONST_POP : std_logic_vector(4 downto 0) := "01110";
	CONSTANT CONST_LDD : std_logic_vector(4 downto 0) := "11110";--TODO check what Decode stage is sending!
	CONSTANT CONST_STD : std_logic_vector(4 downto 0) := "11111";--TODO check what Decode stage is sending!
	CONSTANT CONST_LDM : std_logic_vector(4 downto 0) := "11101";--TODO check what Decode stage is sending!
BEGIN
	result_src <= 
		(others <= '0') & buffered_SP_or_EA_unextended	when (opcode = CONST_PUSH OR opcode = CONST_POP OR opcode = CONST_LDD OR opcode = CONST_STD)
	else
		alu_src_output;


	destination <=
		dst_from_operands_selection_unit				when (opcode = CONST_LDM OR opcode = CONST_STD OR opcode = CONST_PUSH OR opcode = CONST_OUT)
	else
		alu_dst_output;

END alu_output_selection_arch;
