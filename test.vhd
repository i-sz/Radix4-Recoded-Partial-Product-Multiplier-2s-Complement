-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
	use IEEE.MATH_REAL.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
  
	constant m : integer := 8;
	constant n : integer := 8;

          SIGNAL x : std_logic_vector(n-1 downto 0);
          SIGNAL y :  std_logic_vector(m-1 downto 0);
			 signal res : std_logic_vector((m + natural(ceil(real(m)/real(2))) * 2 + 1)-1 downto 0);
			 
			 component MULTIPLIER is

					generic (
						m : integer := m;
						n : integer := n
					);
					
					port (
						x : in std_logic_vector(n-1 downto 0);
						y : in std_logic_vector(m-1 downto 0);
						res : out std_logic_vector((m + natural(ceil(real(m)/real(2))) * 2 + 1)-1 downto 0)
					);

				end component;
          

  BEGIN

  -- Component Instantiation
          uut: MULTIPLIER PORT MAP(
                  x => x, y => y, res => res
          );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes

		x <= (others => '1'); -- x = -1
		y <= "11111001";			-- y = -7

        wait for 100 ns;

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
