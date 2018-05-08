LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE ieee.std_logic_signed.all;

entity ALU is 
  port(	
        A, B 			: in std_logic_vector(15 downto 0 );
  		FLAG_REG 		: in std_logic_vector(3 downto 0);
       	SEL 			: in std_logic_vector(4 downto 0);
       	SHIFT_AMOUNT 	: in std_logic_vector(3 downto 0);
       	FLAG_REG_INPUT 	: out std_logic_vector(3 downto 0);
       	FLAG_REG_WRITE 	: out std_logic;
       	F_SRC:out std_logic_vector(15 downto 0 );
       	F_DST:out std_logic_vector(15 downto 0 )

       );
end entity ALU;
--end entity alu--

--TODO: negative bit in flag register isn't set in any instruction!!

ARCHITECTURE STRUCT OF ALU IS
  SIGNAL SIGNAL_FLAG_REGISTER_OUTPUT:STD_LOGIC_VECTOR(3 DOWNTO 0 ); --C --Z
  SIGNAL SIGNAL_FLAG_REGISTER_INPUT:STD_LOGIC_VECTOR(3 DOWNTO 0 );  --C --Z
  SIGNAL SIGNAL_OPERATION_OUTPUT:STD_LOGIC_VECTOR(15 downto 0);

  SIGNAL SIGNAL_ADDER_A:STD_LOGIC_VECTOR(15 downto 0);	
  SIGNAL SIGNAL_ADDER_B:STD_LOGIC_VECTOR(15 downto 0);	
  SIGNAL SIGNAL_ADDER_OUTPUT:STD_LOGIC_VECTOR(15 downto 0);	
  SIGNAL SIGNAL_ADDER_CARRY_OUTPUT:STD_LOGIC;	
  SIGNAL SIGNAL_ADDER_CARRY_CIN:STD_LOGIC;
  --SIGNAL MUL_RESULT:STD_LOGIC_VECTOR(31 downto 0);
  --constants
   	-- OPcodes constants.
	CONSTANT CONST_OPCODE_NOP 	: std_logic_vector(4 downto 0):="00000";
	CONSTANT CONST_OPCODE_MOV 	: std_logic_vector(4 downto 0):="00001";
	CONSTANT CONST_OPCODE_ADD 	: std_logic_vector(4 downto 0):="00010";
	CONSTANT CONST_OPCODE_MUL 	: std_logic_vector(4 downto 0):="00011";
	CONSTANT CONST_OPCODE_SUB 	: std_logic_vector(4 downto 0):="00100";
	CONSTANT CONST_OPCODE_AND 	: std_logic_vector(4 downto 0):="00101";
	CONSTANT CONST_OPCODE_OR 	: std_logic_vector(4 downto 0):="00110";
	CONSTANT CONST_OPCODE_RLC 	: std_logic_vector(4 downto 0):="00111";
	CONSTANT CONST_OPCODE_RRC 	: std_logic_vector(4 downto 0):="01000";
	CONSTANT CONST_OPCODE_SHL 	: std_logic_vector(4 downto 0):="01001";
	CONSTANT CONST_OPCODE_SHR 	: std_logic_vector(4 downto 0):="01010";
	CONSTANT CONST_OPCODE_SETC 	: std_logic_vector(4 downto 0):="01011";
	CONSTANT CONST_OPCODE_CLRC 	: std_logic_vector(4 downto 0):="01100";
	CONSTANT CONST_OPCODE_PUSH 	: std_logic_vector(4 downto 0):="01101";
	CONSTANT CONST_OPCODE_POP 	: std_logic_vector(4 downto 0):="01110";
	CONSTANT CONST_OPCODE_OUT 	: std_logic_vector(4 downto 0):="01111";
	CONSTANT CONST_OPCODE_IN 	: std_logic_vector(4 downto 0):="10000";
	CONSTANT CONST_OPCODE_NOT 	: std_logic_vector(4 downto 0):="10001";
	CONSTANT CONST_OPCODE_DEC 	: std_logic_vector(4 downto 0):="10010";
	CONSTANT CONST_OPCODE_INC 	: std_logic_vector(4 downto 0):="10011";
	CONSTANT CONST_OPCODE_RTI 	: std_logic_vector(4 downto 0):="11010";
	CONSTANT CONST_OPCODE_CALL 	: std_logic_vector(4 downto 0):="11011";
	CONSTANT CONST_OPCODE_RET 	: std_logic_vector(4 downto 0):="11100";
	CONSTANT CONST_OPCODE_LDM 	: std_logic_vector(4 downto 0):="11101";
	CONSTANT CONST_OPCODE_LDD 	: std_logic_vector(4 downto 0):="11110";
	CONSTANT CONST_OPCODE_STD 	: std_logic_vector(4 downto 0):="11111";

  --end constants
  BEGIN

  N_ADDER: ENTITY work.NAdder generic map(n=>16)  PORT MAP (SIGNAL_ADDER_A,SIGNAL_ADDER_B,SIGNAL_ADDER_CARRY_CIN,SIGNAL_ADDER_OUTPUT,SIGNAL_ADDER_CARRY_OUTPUT);
  
  SIGNAL_FLAG_REGISTER_INPUT<= SIGNAL_FLAG_REGISTER_INPUT;
  FLAG_REG_INPUT <= SIGNAL_FLAG_REGISTER_OUTPUT;
  -------------------------------------------------
  ----DECODING SEL --------------------------------
  -- Z-N-C
 
  PROCESS (A, B, FLAG_REG, SEL, SIGNAL_ADDER_OUTPUT)
  	--VARIABLE VARIABLE_OPERATION_OUTPUT:std_logic_vector( n downto 0);
  	VARIABLE VARIABLE_TEMP_OUTPUT:STD_LOGIC_VECTOR(15 downto 0);
  	VARIABLE MUL_RESULT:STD_LOGIC_VECTOR(31 downto 0);
	BEGIN

		SIGNAL_FLAG_REGISTER_OUTPUT <= SIGNAL_FLAG_REGISTER_INPUT;

		IF SEL=CONST_OPCODE_MUL THEN
			--MUL_RESULT<=std_logic_vector(to_unsigned(to_integer(unsigned(A))*to_integer(unsigned(B)),32));
			MUL_RESULT:=A*B;
			F_SRC <= MUL_RESULT(31 downto 16);
			F_DST <= MUL_RESULT(15 downto 0);
			FLAG_REG_WRITE <= '0';
		ELSIF SEL=CONST_OPCODE_NOP THEN
			SIGNAL_ADDER_A<=(others=>'0');
			SIGNAL_ADDER_B<=(others=>'0');
			SIGNAL_ADDER_CARRY_CIN<='0';
			SIGNAL_FLAG_REGISTER_INPUT<=(others=>'0');
			F_SRC <= (others=>'0');
			F_DST <= (others=>'0');
			FLAG_REG_WRITE <= '0';

			--------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_DEC THEN
			SIGNAL_ADDER_A<=B;
			SIGNAL_ADDER_CARRY_CIN<='1';
			SIGNAL_ADDER_B(0)<='0';
			SIGNAL_ADDER_B(15 downto 1)<=(others=>'1');
			FLAG_REG_WRITE <= '1';
			F_SRC <=(others=>'0');
			SIGNAL_FLAG_REGISTER_INPUT(1)<=SIGNAL_ADDER_OUTPUT(15);
			F_DST <= SIGNAL_ADDER_OUTPUT;
			IF ( SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;
			--------------------------------------------------------------------
			--------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_NOT THEN
			VARIABLE_TEMP_OUTPUT:= NOT B;
			FLAG_REG_WRITE <= '1';
			F_SRC <=(others=>'0');
			F_DST <= VARIABLE_TEMP_OUTPUT;
			SIGNAL_FLAG_REGISTER_OUTPUT(1)<=VARIABLE_TEMP_OUTPUT(15);
			IF ( VARIABLE_TEMP_OUTPUT=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;
			--------------------------------------------------------------------
			--------------------------------------------------------------------

		ELSIF SEL = CONST_OPCODE_INC THEN
			SIGNAL_ADDER_B<=(others=>'0');
			SIGNAL_ADDER_A<= B;
			SIGNAL_ADDER_CARRY_CIN<='1';
			F_SRC <= (others=>'0');
			F_DST <= SIGNAL_ADDER_OUTPUT;
			FLAG_REG_WRITE <= '1';	
			SIGNAL_FLAG_REGISTER_OUTPUT(1)<= SIGNAL_ADDER_OUTPUT(15);	
			IF ( SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;
			---------------------------------------------------------------------
			--------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_ADD THEN
			SIGNAL_ADDER_A<=A;
			SIGNAL_ADDER_B<=B;
			SIGNAL_ADDER_CARRY_CIN<='0';
			F_SRC <= (others=>'0');
			F_DST <= SIGNAL_ADDER_OUTPUT;
			FLAG_REG_WRITE <= '1';	
			IF (SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000"))THEN
			SIGNAL_FLAG_REGISTER_OUTPUT(0)<='1';
			ELSE
			SIGNAL_FLAG_REGISTER_OUTPUT(0)<='0';
			END IF;
			SIGNAL_FLAG_REGISTER_INPUT(1) <= SIGNAL_ADDER_OUTPUT(15);
			--SIGNAL_FLAG_REGISTER_INPUT(2) <= SIGNAL_ADDER_CARRY_OUTPUT;
			----------------------------------------------------------------------
			------------------------------------------------------

		ELSIF SEL=CONST_OPCODE_SUB THEN
			SIGNAL_ADDER_B<=(not B);
			SIGNAL_ADDER_A<= A;
			SIGNAL_ADDER_CARRY_CIN<='1';
			--SIGNAL_FLAG_REGISTER_INPUT(2)<=SIGNAL_ADDER_CARRY_OUTPUT;
			SIGNAL_FLAG_REGISTER_INPUT(1)<=SIGNAL_ADDER_OUTPUT(15);
			F_SRC <= (others=>'0');
			F_DST <= SIGNAL_ADDER_OUTPUT;
			FLAG_REG_WRITE <= '1';
			IF ( SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;

			--------------------------------------------------------------------
			---------------------------------------------------------------------

		ELSIF SEL=CONST_OPCODE_OR THEN
			VARIABLE_TEMP_OUTPUT:= A OR B;
			F_SRC<=(others=>'0');
			F_DST<=VARIABLE_TEMP_OUTPUT;
			--SIGNAL_FLAG_REGISTER_INPUT(2)<=SIGNAL_FLAG_REGISTER_OUTPUT(2);
			SIGNAL_FLAG_REGISTER_OUTPUT(1)<=VARIABLE_TEMP_OUTPUT(15);
			FLAG_REG_WRITE <= '1';
			IF ( SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;


		ELSIF SEL=CONST_OPCODE_AND THEN
			VARIABLE_TEMP_OUTPUT:=A AND B;
			F_SRC<=(others=>'0');
			F_DST<=VARIABLE_TEMP_OUTPUT;
			SIGNAL_FLAG_REGISTER_OUTPUT(1)<=VARIABLE_TEMP_OUTPUT(15);
			FLAG_REG_WRITE <= '1';
			IF ( SIGNAL_ADDER_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0) <= '1';
				ELSE	SIGNAL_FLAG_REGISTER_INPUT(0) <= '0';
			END IF;	
		-------------------------------------------------------------------------
		------------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_RRC THEN
			VARIABLE_TEMP_OUTPUT:= (SIGNAL_FLAG_REGISTER_OUTPUT(0) & B(15 downto 1 ));--edit Cin
			F_SRC <= (others=>'0');
			F_DST<=VARIABLE_TEMP_OUTPUT;
			SIGNAL_FLAG_REGISTER_INPUT(2)<=B(0);
			FLAG_REG_WRITE <= '1';
			IF ( VARIABLE_TEMP_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0)<='1';
				ELSE  	SIGNAL_FLAG_REGISTER_INPUT(0)<='0';
			END IF;
		------------------------------------------------------------------------
		--TODO:this is wrong, this should be shifted by Immediate value
		ELSIF SEL=CONST_OPCODE_SHR THEN
			F_SRC <= (others=>'0');
			--F_DST <= std_logic_vector(shift_right(A,SHIFT_AMOUNT));
			F_DST <= std_logic_vector(unsigned(A) sll to_integer(unsigned(SHIFT_AMOUNT)) );
			FLAG_REG_WRITE <= '0';
		-------------------------------------------------------------------------
		--TODO:this is wrong, this should be shifted by Immediate value
		ELSIF SEL=CONST_OPCODE_SHL THEN
			F_SRC <= (others=>'0');
			F_DST <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(SHIFT_AMOUNT))) );
			FLAG_REG_WRITE <= '0';
		------------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_RLC THEN
			VARIABLE_TEMP_OUTPUT:=( B(14 downto 0 )& SIGNAL_FLAG_REGISTER_OUTPUT(0) );
			F_SRC <= (others=>'0');
			F_DST<=VARIABLE_TEMP_OUTPUT;
			FLAG_REG_WRITE <='1';
			SIGNAL_FLAG_REGISTER_INPUT(2)<=B(15);
			IF ( VARIABLE_TEMP_OUTPUT(15 downto 0)=(x"0000")) THEN 
				SIGNAL_FLAG_REGISTER_INPUT(0)<='1';
				ELSE  SIGNAL_FLAG_REGISTER_INPUT(0)<='0';
			END IF;
		--------------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_SETC THEN
			VARIABLE_TEMP_OUTPUT:=( others=> '0');
			F_SRC <= (others=>'0');
			F_DST<=(others=>'0');
			FLAG_REG_WRITE <='1';
			SIGNAL_FLAG_REGISTER_INPUT(2)<='1';
 		---------------------------------------------------------------------
		ELSIF SEL=CONST_OPCODE_CLRC THEN
			VARIABLE_TEMP_OUTPUT:=( others=> '0');
			F_SRC <= (others=>'0');
			F_DST<=(others=>'0');
			SIGNAL_FLAG_REGISTER_INPUT(2)<='0';
			FLAG_REG_WRITE <='1';
		--------------------------------------------------------------------------

		ELSIF SEL=CONST_OPCODE_MOV THEN
			VARIABLE_TEMP_OUTPUT:=( others=> '0');
			F_SRC <= (others=>'0');
			F_DST <= A;
			FLAG_REG_WRITE <='0';
		--------------------------------------------------------------------------
		-------------------------------------------------------------------------

		ELSE 
			SIGNAL_ADDER_A<=(others=>'0');
			SIGNAL_ADDER_B<=(others=>'0');
			SIGNAL_ADDER_CARRY_CIN<='0';
			SIGNAL_FLAG_REGISTER_INPUT<=(others=>'0');
			F_SRC <= (others=>'0');
			F_DST <= B;
			FLAG_REG_WRITE <= '0';
		END IF;

  END PROCESS;



END STRUCT;

  