LIBRARY IEEE;

USE IEEE.std_logic_1164.all;

entity NAdder is 
 generic (n:integer:=16); 
  port(A,B:in std_logic_vector(n-1 downto 0);
    Cin:in std_logic;
    S:out std_logic_vector(n-1 downto 0);
    Cout:out std_logic );
    
  end entity NAdder;
  
  architecture arch of NAdder is 
  
  --single bit full adder
  component FullAdder is
    port(A,B:in std_logic;
    Cin:in std_logic;
    S:out std_logic;
    Cout:out std_logic );
  end component;
  
  --signals
  signal temp:std_logic_vector(n-1 downto 0 );
  
  begin 
  fa:FullAdder port map (A(0),B(0),Cin,S(0),temp(0));
    
  loop1: for i in 1 to n-1 generate
    fx:FullAdder port map(A(i),B(i),temp(i-1),S(i),temp(i));
    end generate;
    
  cout<=temp(n-1);
  
 

  


  
  end arch;





