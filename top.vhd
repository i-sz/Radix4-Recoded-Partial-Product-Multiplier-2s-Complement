----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:14:01 10/27/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
use IEEE.MATH_REAL.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MULTIPLIER is

	generic (
		m : integer := 8;
		n : integer := 8
	);
	
	port (
		x : in std_logic_vector(n-1 downto 0);
		y : in std_logic_vector(m-1 downto 0);
		res : out std_logic_vector((m + natural(ceil(real(m)/real(2))) * 2 + 1)-1 downto 0)
	);
	
	constant h : integer := natural(ceil(real(m)/real(2)));

end entity;

architecture RADIX_4_RECODING_2S_COMPLEMENT_MULTIPLIER of MULTIPLIER is

	component RECODING is
		generic (
			m : integer; 
			h : integer
		);
		 
		port ( 
			y : in std_logic_vector(m-1 downto 0);
			one : out std_logic_vector(h-1 downto 0);
			two : out std_logic_vector(h-1 downto 0);
			neg : out std_logic_vector(h-1 downto 0)
		);
	end component;
	
	component PPGEN is
		generic(
			n : integer;
			h : integer;
			index : integer
			-- k : integer
		); -- k = n + ? (sign ext.}
		
		port ( 
			x : in std_logic_vector(n-1 downto 0);
			one : in std_logic;
			two : in std_logic;
			neg : in std_logic;
			prev_neg : in std_logic;
			y_recoding_group : in integer;
			pp : out std_logic_vector((n+2*h+1)-1 downto 0)
		);
	end component;
	
	type pp_matrix is array (0 to natural(ceil(real(m)/real(2))) - 1) of std_logic_vector((n+2*h+1)-1 downto 0);
	
	signal one, two : std_logic_vector(h-1 downto 0);
	signal neg : std_logic_vector(h-1 downto 0);
	signal pp : pp_matrix;

begin

	RECODING_BLOCK: RECODING generic map (
		m => m,
		h => natural(ceil(real(m)/real(2)))
	) port map (
		y => y,
		one => one,
		two => two,
		neg => neg
	);
	
	FIRST_PPGEN_BLOCK: PPGEN generic map (
		n => n,
		h => natural(ceil(real(m)/real(2))),
		index => 0
	) port map (
		x => x,
		one => one(0),
		two => two(0),
		neg => neg(0),
		prev_neg => 'X',
		y_recoding_group => 0,
		pp => pp(0)
	);
	
	PPGEN_BLOCKS: for i in 1 to (natural(ceil(real(m)/real(2))) - 1) generate
		PPGEN_BLOCK: PPGEN generic map (
			n => n,
			h => natural(ceil(real(m)/real(2))),
			index => i
		) port map (
			x => x,
			one => one(i),
			two => two(i),
			neg => neg(i),
			prev_neg => neg(i-1),
			y_recoding_group => i,
			pp => pp(i)
		);
	end generate;
	
	process(pp, neg)
		variable sum : unsigned((n+2*h+1)-1 downto 0);
		variable sum_as_array: std_logic_vector((n+2*h+1)-1 downto 0);
	begin
		sum_as_array := (((natural(ceil(real(m)/real(2)))-1) * 2) => neg(natural(ceil(real(m)/real(2))) - 1), 
									others => '0');
		sum := unsigned(sum_as_array);
		for i in 0 to (natural(ceil(real(m)/real(2))) - 1) loop
			sum := sum + unsigned(pp(i));
		end loop;
		res <= std_logic_vector(sum);--, (m + natural(ceil(real(m)/real(2))) * 2 + 1)-1);
	end process;

end architecture;

