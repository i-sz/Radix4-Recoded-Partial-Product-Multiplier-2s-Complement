----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:45 10/27/2014 
-- Design Name: 
-- Module Name:    ppgen - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PPGEN is
	
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
end PPGEN;

architecture PARALLEL_PRODUCT of PPGEN is

	signal x_extended, x_double, pp_ini : std_logic_vector(n downto 0); -- extension by 1 bit to avoid data loss when 2x
	signal pp_ext, pp_shift, pp_sign, pp_ones : std_logic_vector((n+2*h+1)-1 downto 0);

begin

	x_extended <= x(n-1) & x(n-1 downto 0);
	x_double <= x(n-1 downto 0) & '0';
	
	MULTIPLE_GENERATOR: for i in 0 to n generate
		pp_ini(i) <= not((x_extended(i) and one) or (x_double(i) and two)) when neg = '1' 
							else ((x_extended(i) and one) or (x_double(i) and two));
	end generate;

	pp_ext <= std_logic_vector(resize(unsigned(pp_ini), n+2*h+1)); -- unsigned because 4.13 doesn't show full sign extension
	
	process(pp_ext, prev_neg, y_recoding_group)
		variable temp_pp_sign : std_logic_vector((n+2*h+1)-1 downto 0);
	begin
		temp_pp_sign := (others => '0');
		if y_recoding_group = 0 then
			temp_pp_sign(n downto 0) := pp_ext(n downto 0);
			temp_pp_sign(n+1) := pp_ext(n);
			temp_pp_sign(n+2) := pp_ext(n);
			temp_pp_sign(n+3) := not(pp_ext(n));
--			<= ( n downto 0 => pp_ext(n downto 0),
--								n+1 => pp_ext(n),
--								n+2 => pp_ext(n),
--								n+3 => not(pp_ext(n)),
--								others => '0' );
		else
			temp_pp_sign(0) := prev_neg;
			temp_pp_sign(n+2 downto 2) := pp_ext(n downto 0);
			temp_pp_sign(n+3) := not(pp_ext(n+2));
--			<= ( 0 => prev_neg,
--								n+2 downto 2 => pp_ext(n downto 0),
--								n+3 => not(pp_ext(n+2)),
--								others => '0' );
		end if;
		pp_sign <= temp_pp_sign;
	end process;
	
	--pp_shift <= std_logic_vector(unsigned(pp_ext) sll (y_recoding_group * 2));
	pp_shift <= std_logic_vector(unsigned(pp_sign) sll (y_recoding_group * 2));
	
	process(pp_shift, y_recoding_group)
		variable tmp_pp_ones : std_logic_vector((n+2*h+1)-1 downto 0);
	begin
		tmp_pp_ones := pp_shift;
		if y_recoding_group = 0 then
			for i in 0 to h-2 loop
				tmp_pp_ones(n+4+i*2) := '1';
			end loop;
		end if;
		pp_ones <= tmp_pp_ones;
	end process;
	
--	process(pp_shift, y_recoding_group) -- stupid, I should have formed the terms and then shift them :(
--	begin
--		if y_recoding_group = 0 then
--			pp_sign <= pp_shift((n+2*h+1)-1 downto n+4) & not(pp_shift(n)) & pp_shift(n) & pp_shift(n) & pp_shift(n downto 0);
--			-- I should really use 'left and 'right more often :(
--		else
--			pp_sign <= pp_shift((n+2*h+1)-1 downto (n+2*y_recoding_group)+1) & not(pp_shift(n+2*y_recoding_group-1))
--								& pp_shift(n+2*y_recoding_group downto 2*y
--		end if;
--	end process;
--	process(pp_shift, y_recoding_group)
--	begin
--	
--		if y_recoding_group = 0 then
--			pp_shift(n+1) <= pp_shift(n);
--			pp_shift(n+2) <= pp_shift(n);
--			pp_shift(n+3) <= not(pp_shift(n));
--			for i in 0 to h-2 loop
--				pp_shift(n+4+i*2) <= '1';
--			end loop;
--			pp <= pp_shift;
--		else
--			pp_shift((y_recoding_group - 1) * 2) <= prev_neg;
--			pp_shift(n + (y_recoding_group) * 2 + 1) <= not(pp_shift(n + (y_recoding_group) * 2));
--			pp <= pp_shift;
--		end if;
--	
--	end process;

	pp <= pp_ones;
	--pp <= pp_shift

end architecture;

