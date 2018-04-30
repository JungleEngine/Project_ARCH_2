LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY WB_DECODER IS
	Port ( 
		X1,X2 : IN STD_LOGIC_VECTOR (2 downto 0);
		Y : OUT STD_LOGIC_VECTOR (5 downto 0)
		);
END WB_DECODER;

ARCHITECTURE BEHAVIORAL OF WB_DECODER IS
BEGIN
	Y <= "000001" WHEN (X1 = "000" or X2 = "000")
	ELSE "000010" WHEN (X1 = "001" or X2 = "001")
	ELSE "000100" WHEN (X1 = "010" or X2 = "010")
	ELSE "001000" WHEN (X1 = "011" or X2 = "011")
	ELSE "010000" WHEN (X1 = "100" or X2 = "100")
	ELSE "100000" WHEN (X1 = "101" or X2 = "101")
	ELSE "000000";
END BEHAVIORAL;
