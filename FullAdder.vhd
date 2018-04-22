LIBRARY IEEE;

USE IEEE.std_logic_1164.all;


entity FullAdder is
    port(A,B:in std_logic;
    Cin:in std_logic;
    S:out std_logic;
    Cout:out std_logic );
  end entity;

architecture arch of fullAdder is
begin
  s<=A xor B xor cin;
   cout <= (a AND b) or (cin AND (a XOR b));

end arch;