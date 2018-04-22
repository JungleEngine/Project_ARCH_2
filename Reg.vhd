LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY REG IS
  generic(n : integer :=32);
     PORT( 
     d :IN std_logic_vector(n-1 downto 0); 
     en,clk,rst : IN std_logic;   
     q : OUT std_logic_vector(n-1 downto 0));
END REG;

ARCHITECTURE REG_ARCH OF REG IS
BEGIN
	PROCESS(clk,rst)
	BEGIN
		IF(rst = '1') THEN
			q <= (others =>'0');
		ELSIF rising_edge(clk) and en='1' THEN     
		 	q <= d;
		END IF;
	END PROCESS;
END REG_ARCH;

