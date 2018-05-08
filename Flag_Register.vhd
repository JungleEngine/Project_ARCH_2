LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY FREG IS
	GENERIC(N : integer := 32);
		PORT( 
		D: IN std_logic_vector(N - 1 DOWNTO 0); 
		EN: IN std_logic;
		CLK: IN std_logic;
		RST: IN std_logic;
		Q: OUT std_logic_vector(N - 1 DOWNTO 0)
		);
END FREG;


ARCHITECTURE FREG_ARCH OF FREG IS
BEGIN
	PROCESS(CLK, RST, EN)
	BEGIN
	  
		IF(RST = '1') THEN
			Q <= (others =>'0');
			
		ELSIF (rising_edge(CLK) OR falling_edge(CLK)) and EN = '1' THEN     
		 	Q <= D;
		 	
		END IF;
	END PROCESS;
END FREG_ARCH;

