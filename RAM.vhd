library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity RAM is
	generic(
		wordN: integer := 5;
		addrN: integer := 5
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		wrEn: in std_logic; -- write enable
		addr: in std_logic_vector(addrN-1 downto 0);
		dataIn: in std_logic_vector(wordN-1 downto 0);
		dataOut: out std_logic_vector(wordN-1 downto 0);
		memoryWord: out std_logic_vector(wordN-1 downto 0)
	);
end RAM;

architecture RAMArch of RAM is
	type memory is array(0 to 2**addrN-1) of std_logic_vector(wordN-1 downto 0);
	signal ram: memory := (
		0 => "00001",
		1 => "11110",
		2 => "00100",
		3 => "00001",
		4 => "10000",
		5 => "00101",
		6 => "00010",
		7 => "11111",
		8 => "01110",
		30 => std_logic_vector(to_signed(-8, 5)),
		16 => std_logic_vector(to_signed(7, 5)),
		others => "00000"
		);
	signal inAddr: std_logic_vector(addrN-1 downto 0) := (others => '0');
begin
	process(clk, reset)
	begin
		if reset = '1' then
			inAddr <= (others => '0');
		elsif rising_edge(clk) then
			if(wrEn = '1') then
				ram(to_integer(unsigned(addr))) <= dataIn;
			end if;
			inAddr <= addr;
		end if;	
	end process;
	
	dataOut <= ram(to_integer(unsigned(inAddr)));
	memoryWord <= ram(30);
end RAMArch;