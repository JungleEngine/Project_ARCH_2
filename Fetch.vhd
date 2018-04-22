LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY FETCH IS
 PORT (
		INTERRUPT_PIN :	                in  std_logic;
		PC_RST   :                      in  std_logic_vector;       
    DECODING_STAGE_OUTPUT :         in  std_logic_vector        (8 DOWNTO 0);
		PC :                           	in  std_logic_vector      	(8  DOWNTO 0);
		RST_ADDRESS   :               	in  std_logic_vector      	(8 DOWNTO 0);
		INTERRUPT_ADDRESS :             in  std_logic_vector      	(8 DOWNTO 0);
		MEMORY_STAGE_OUTPUT :           in  std_logic_vector      	(8 DOWNTO 0);
		MEMORY_OUTPUT :					in  std_logic_vector      	(15 DOWNTO 0);
		MEMORY_SELECTOR_MEMORY_STAGE:   in  std_logic;
		DECODE_SELECTOR_DECODE_STAGE:   in  std_logic;
		DECODE_SELECTOR_DECODE_STAGE:   in  std_logic;
		
		SELECTOR_IR_OUT :				in  std_logic;
		IR_OUTPUT_TO_DECODE :			out std_logic_vector     	(15 downto 0);
		PC_OUTPUT_TO_DECODE :			out std_logic_vector     	(8 downto 0);
		I_BUBBLE :						out std_logic;
		PC_WRITE :						out std_logic;
		PC_REGISTER_INPUT :				out std_logic_vector     	(8 downto 0);
		MEMORY_READ_ADDRESS :			out std_logic_vector     	(8 downto 0);
		MEMORY_READ :					out std_logic
       );
END ENTITY FETCH;

ARCHITECTURE FETCH_ARCH OF FETCH IS  
  --TYPE ram_type IS ARRAY(0 TO 2047) of std_logic_vector(15 DOWNTO 0);
    -- SIGNAL ram : ram_type ;
    SIGNAL SIG_PC_PLUS_1 : std_logic_vector(8 downto 0);
    SIGNAL SIG_IR_MUX_OUTPUT : std_logic_vector(15 downto 0);
    SIGNAL SIG_PC_MUX_OUTPUT : std_logic_vector(8 downto 0);
  BEGIN
  PROCESS(	  SELECTOR_IR_OUT, SELECTOR_PC, PC, SIG_PC_MUX_OUTPUT, MEMORY_OUTPUT, INTERRUPT_ADDRESS, RST_ADDRESS, 
		      DECODING_STAGE_OUTPUT, MEMORY_STAGE_OUTPUT, MEMORY_OUTPUT, SIG_PC_PLUS_1, INTERRUPT_PIN, SIG_IR_MUX_OUTPUT,
              SIG_PC_MUX_OUTPUT
          )
  BEGIN  
    -- Set PC_WRITE  to 1, always write in pc.
    PC_WRITE <= '1';

    -- Read from memory.
    MEMORY_READ_ADDRESS <= pc;

    -- Send PC to decode stage.
    PC_OUTPUT_TO_DECODE <= PC;
    -- PC input from mux.
    PC_REGISTER_INPUT <= SIG_PC_MUX_OUTPUT;

    --TODO: pass ibubble in the next cycle
    -- Send interrupt bubble to decode stage.
    I_BUBBLE <= INTERRUPT_PIN;

    -- IR output.
    IR_OUTPUT_TO_DECODE <= SIG_IR_MUX_OUTPUT;


    SIG_PC_PLUS_1 <=  std_logic_vector(unsigned(PC) + 1);

	-- IR mux output.
	IF INTERRUPT_PIN = '0' THEN
	  SIG_IR_MUX_OUTPUT <= MEMORY_OUTPUT;
	ELSE
	  SIG_IR_MUX_OUTPUT <= (x"0000");
	END IF;

	-- SIG_PC_INPUT from mux.
	IF MEMORY_SELECTOR_MEMORY_STAGE = '1' THEN
	  SIG_PC_MUX_OUTPUT <= MEMORY_STAGE_OUTPUT;
	ELSIF INTERRUPT_PIN='1' THEN
	  SIG_PC_MUX_OUTPUT <= PC;
	ELSIF DECODE_SELECTOR_DECODE_STAGE = '1' THEN
	  SIG_PC_MUX_OUTPUT <= DECODING_STAGE_OUTPUT;
	ELSE
	  SIG_PC_MUX_OUTPUT <= SIG_PC_PLUS_1;
	END IF;

  END PROCESS;
END FETCH_ARCH;


