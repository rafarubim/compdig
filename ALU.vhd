library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity ALU is
	generic(
		opN: integer := 5
	);
	port(
		clk: in std_logic;
		op: in std_logic; -- operation (1 clock pulse)
		reset: in std_logic;
		opA: in std_logic_vector(opN-1 downto 0); -- operandA
		opB: in std_logic_vector(opN-1 downto 0); -- operandB
		opcode: in std_logic_vector(4 downto 0);
		zero: out std_logic;
		negative: out std_logic;
		result: out std_logic_vector(opN-1 downto 0)
	);
end ALU;

architecture ALUArch of ALU is
begin
	sync: process(clk, reset)
		variable resultVar: std_logic_vector(opN-1 downto 0) := (others => '0');
	begin
		if reset = '1' then -- Asynchronous reset
			result <= (others => '0');
			zero <= '0';
			negative <= '0';
		elsif rising_edge(clk) and op = '1' then
			result <= (others => '0');
			zero <= '0';
			negative <= '0';
			case opcode is
				when "00101" => -- Add
					resultVar := std_logic_vector(signed(opA) + signed(opB));
				when "00110" => -- Sub
					resultVar := std_logic_vector(signed(opA) - signed(opB));
				when "10000" => -- Inc
					resultVar := std_logic_vector(signed(opA) + 1);
				when "10010" => -- Dec
					resultVar := std_logic_vector(signed(opA) - 1);
				when "00111" => -- And
					resultVar := opA and opB;
				when "01000" => -- Or
					resultVar := opA or opB;
				when "01011" => -- Nand
					resultVar := opA nand opB;
				when "01001" => -- Xor
					resultVar := opA xor opB;
				when "01010" => -- Not
					resultVar := not opA;
				when others =>
			end case;
			if signed(resultVar) = 0 then
				zero <= '1';
			elsif signed(resultVar) < 0 then
				negative <= '1';
			end if;
			result <= resultVar;
		end if;	
	end process sync;
end ALUArch;

