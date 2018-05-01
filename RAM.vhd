LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY RAM IS
	PORT(
		CLK: IN std_logic;
		WRITE_ENABLE: IN std_logic;
		ADDRESS: IN std_logic_vector(8 DOWNTO 0);
		DATA_IN: IN std_logic_vector(15 DOWNTO 0);
		DATA_OUT: OUT std_logic_vector(15 DOWNTO 0)
	);
END ENTITY RAM;

ARCHITECTURE RAM_ARCH OF RAM IS  

TYPE RAM_TYPE IS ARRAY(0 TO 512) of std_logic_vector(15 DOWNTO 0);
SIGNAL RAM: RAM_TYPE;

BEGIN

	PROCESS(CLK) IS
		BEGIN
		IF (rising_edge(CLK) and WRITE_ENABLE = '1') THEN
			RAM(to_integer(unsigned(ADDRESS))) <= DATA_IN;
		END IF;
	END PROCESS;

	DATA_OUT <= RAM(to_integer(unsigned(ADDRESS)));

END RAM_ARCH;
