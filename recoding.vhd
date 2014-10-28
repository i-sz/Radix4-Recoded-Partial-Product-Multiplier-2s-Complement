----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:52:12 10/27/2014 
-- Design Name: 
-- Module Name:    recoding - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity RECODING is
	generic (
    	m : integer; 
		h : integer
   ); -- h = ceiling(m/2);
    
	port ( 
    	y : in std_logic_vector(m-1 downto 0);
		one : out std_logic_vector(h-1 downto 0);
		two : out std_logic_vector(h-1 downto 0);
		neg : out std_logic_vector(h-1 downto 0)
   );
end RECODING;

architecture RADIX_4_RECODING of RECODING is

	component RECODING_CELL is
      port (
          y : in std_logic_vector(2 downto 0);
          one : out std_logic;
          two : out std_logic;
          neg : out std_logic
      );
    end component;
    
--first_decoding
signal y_s1, y_s2, y_s3, y_s4 : std_logic_vector(2 downto 0);    

begin
  
  y_s1 <= y(1) & y(0) & '0' ;
  

	FIRST_RECODING_GROUP: RECODING_CELL port map ( y => y_s1, one => one(0), two => two(0), neg => neg(0) );
    
    MIDDLE_RECODING_GROUPS: for i in 1 to h-2 generate
      y_s2 <=  y(2*i+1) & y(2*i) & y(2*i-1);
    	MID_RECODING_GROUP: RECODING_CELL port map ( y =>y_s2, one => one(i), two => two(i), neg => neg(i) );
    end generate;
    
    LAST_RECODING_GROUP_EVEN_LENGTH: if h*2 = m generate
     y_s3 <= y(m-1) & y(m-2) & y(m-3); 
    	LRG_EVEN: RECODING_CELL port map ( y => y_s3, one => one(h-1), two => two(h-1), neg => neg(h-1) );
    end generate;
    
    LAST_RECODING_GROUP_ODD_LENGTH: if h*2 /= m generate
     y_s4 <= y(m-1) & y(m-1) & y(m-2);
    	LRG_ODD: RECODING_CELL port map ( y => y_s4 , one => one(h-1), two => two(h-1), neg => neg(h-1) );
    end generate;

end architecture;


