LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

--***
--***	This component is responsible for choosing
--***	the right operands for the ALU
--***

ENTITY alu_operands IS
 PORT (	
 		clk : IN std_logic;
        we : IN std_logic;

		-------------------------< Possible ALU operands--------------------------------
		---------Previous ALU results saved in the buffer before Memory Stage---
		result_dst,result_src,
		---------Current value of r_src,r_dst from register file----------------
		r_dst,r_src
		---------Immediate value forwarded from Fetch stage---------------------
		immediate
		---------Value forwarded from memory stage if the operand is in memory--
		memory_forwarded	

		: IN std_logic_vector(15 DOWNTO 0)
		------------------------- Possible ALU operands />------------------------------
							
		-------------------------< Selectors for operands--------------------------------
		dst_in_result_src,dst_in_result_dst,	--this can be reduced into two selectors only
		src_in_result_src,src_in_result_dst,	
		
		src_in_mem,		--pop or load the src.	TODO:find if this is for previous command only or more than one level
		dst_in_mem,		--pop or load the dst

		dst_is_immediate,	--destination is an immediate value which is passed from fetch
						--TODO: differentiate between forwarded immediate value and the 5 bit shift immediate value
		: IN std_logic
		------------------------- Selectors for operands/>-------------------------------
		
		-------------------------< Operands out -----------------------------------------
		destination,src
		: OUT std_logic_vector(15 downto 0)
		------------------------- Operands out/>-----------------------------------------

						 );
END ENTITY alu_operands;

ARCHITECTURE alu_operands_arch OF alu_operands IS  
BEGIN

END alu_operands_arch;

