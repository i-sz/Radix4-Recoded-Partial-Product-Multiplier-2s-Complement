library IEEE;
use IEEE.std_logic_1164.all;

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

											library IEEE;
											use IEEE.std_logic_1164.all;

											entity RECODING is
												generic (
												    	m : integer :=8; 
													        h : integer :=4
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

																															begin

																																FIRST_RECODING_GROUP: RECODING_CELL port map ( y => y(1) & y(0) & '0', one => one(0), two => two(0), neg => neg(0) );
																																    
																																        MIDDLE_RECODING_GROUPS: for i in 1 to h-2 generate
																																	    	MID_RECODING_GROUP: RECODING_CELL port map ( y => y(2*i+1) & y(2*i) & y(2*i-1), one => one(i), two => two(i), neg => neg(i) );
																																		    end generate;
																																		        
																																			    LAST_RECODING_GROUP_EVEN_LENGTH: if h*2 = m generate
																																			        	LRG_EVEN: RECODING_CELL port map ( y => y(m-1) & y(m-2) & y(m-3), one => one(h-1), two => two(h-1), neg => neg(h-1) );
																																					    end generate;
																																					        
																																						    LAST_RECODING_GROUP_ODD_LENGTH: if h*2 /= m generate
																																						        	LRG_ODD: RECODING_CELL port map ( y => y(m-1) & y(m-1) & y(m-2), one => one(h-1), two => two(h-1), neg => neg(h-1) );
																																								    end generate;

																																								    end architecture;

																																								    library IEEE;
																																								    use IEEE.std_logic_1164.all;
																																								    use IEEE.numeric_std.all;

																																								    entity PPGEN is
																																								    	
																																									    generic(
																																									        	n : integer;
																																											        h : integer
																																												        -- k : integer
																																														); -- k = n + ? (sign ext.}
																																															
																																															    port ( 
																																															        	x : in std_logic_vector(n-1 downto 0);
																																																			one : in std_logic;
																																																					two : in std_logic;
																																																							neg : in std_logic;
																																																							        prev_neg : in std_logic;
																																																										pp : out std_logic_vector(2*n-1 downto 0);
																																																										        shift_amount : in integer
																																																												);
																																																												end PPGEN;

																																																												architecture PARALLEL_PRODUCT of PPGEN is

																																																													signal x2x, pp_ini, pp_ext, pp_shift : std_logic_vector(n-1 downto 0);

																																																													begin

																																																													    x2x <= x(n-1 downto 1) & "0";

																																																													    	MULTIPLE_GENERATOR: for i in 0 to n-1 generate
																																																																pp_ini(i) <= not((x(i) and one) or (x2x(i) and two)) when neg = '1' 
																																																																        				else ((x(i) and one) or (x2x(i) and two));
																																																																					    end generate;
																																																																					        
																																																																						    pp_ext <= std_logic_vector(resize(signed(pp_ini), 2*n));
																																																																						        pp_shift <= pp_ext sll (shift_amount * 2);
																																																																							    
																																																																							        process(pp_shift, shift_amount)
																																																																								    begin
																																																																								        	if shift_amount = 0 then
																																																																										        	pp_shift(n) <= pp_shift(n-1);
																																																																												            pp_shift(n+1) <= pp_shift(n-1);
																																																																													                pp_shift(n+2) <= not(pp_shift(n-1));
																																																																															        elsif shift_amount = h then
																																																																																            pp_shift((shift_amount-1) * 2) <= pp_shift((shift_amount-1) * 2) or prev_neg;
																																																																																	                pp <= pp_shift;
																																																																																			        else
																																																																																				        	pp_shift((shift_amount-1) * 2) <= pp_shift((shift_amount-1) * 2) or prev_neg;
																																																																																						            pp_shift(n + shift_amount * 2) <= not(pp_shift(n + shift_amount * 2 - 1));
																																																																																							                pp_shift(n + shift_amount * 2 + 1) <= '1';
																																																																																									            pp <= pp_shift;
																																																																																										            end if;
																																																																																											        end process;

																																																																																												end architecture;
