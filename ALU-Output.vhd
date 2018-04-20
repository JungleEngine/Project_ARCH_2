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
		buffered_SP, --previous value of stack pointer passed through the buffer before ALU
		current_SP, --this is the actual value of the stack pointer
		alu_src_output
		: IN std_logic_vector(15 DOWNTO 0);

		EA_unextended	--Effective Adrress
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
	CONSTANT PUSH:std_logic_vector(4 downto 0):="01101";
	CONSTANT POP :std_logic_vector(4 downto 0):="01110";
	CONSTANT LDD :std_logic_vector(4 downto 0):="11110";--TODO check what Decode stage is sending!
	CONSTANT STD :std_logic_vector(4 downto 0):="11111";--TODO check what Decode stage is sending!
	CONSTANT LDM :std_logic_vector(4 downto 0):="11101";--TODO check what Decode stage is sending!
BEGIN
	result_src <= 
		current_SP							when (opcode=POP)
	else
		buffered_SP							when (opcode=PUSH)
	else
		(others<='0')&EA_unextended 		when (opcode=LDD OR opcode=STD)
	else
		alu_src_output;


	destination <=
		dst_from_operands_selection_unit	when (opcode)
	else
		alu_dst_output;

END alu_output_selection_arch;
