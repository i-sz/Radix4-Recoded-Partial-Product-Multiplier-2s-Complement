----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:48:50 10/27/2014 
-- Design Name: 
-- Module Name:    recoding_cell - Behavioral 
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

entity RECODING_CELL is
	port (
    	y : in std_logic_vector(2 downto 0);
		one : out std_logic;
		two : out std_logic;
		neg : out std_logic
	);
end RECODING_CELL;

architecture RADIX_4_RECODING_CELL of RECODING_CELL is

begin

      neg <= y(2);
      one <= y(1) xor y(0);
      two <= (y(2) and not(y(1)) and not(y(0))) 
          or (not(y(2)) and y(1) and y(0));

end architecture;
