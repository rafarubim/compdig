library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd is
	generic(
		stringN: integer := 12;
		N: integer := 20
	);
	port(
		clk: in std_logic;
		opcode: std_logic_vector(4 downto 0);
		rewrite: std_logic;
		data: out std_logic_vector(3 downto 0);
		enable: out std_logic;
		rw: out std_logic;
		rs: out std_logic;
		dsf: out std_logic -- Disable StrataFlash
	);
end lcd;

architecture lcdArch of lcd is
	-- CPU message
	type charArray is array(0 to stringN-1) of std_logic_vector(7 downto 0);
	signal charsToWrite: charArray := (others => "00100000");
	signal currentChar, nCurrentChar: unsigned(3 downto 0) := (others => '0');
	-- Finite state machines
	type stage is (initS,confS,writS,finishS);
	type init is (i0,e1,i2,e3,i4,e5,i6,e7,i8);
	type conf is (d0,c1,d2,c3,d4,c5,d6,c7,d8,c9,d10,c11,d12,c13,d14,c15,d16); 
	type writ is (decode,w0,n1,w2,n3,w4);
	-- States
	signal sstate, nsstate: stage:= initS;
	signal istate, nistate: init:= i0;
	signal cstate, ncstate: conf:= d0;
	signal wstate, nwstate: writ:= decode;
	-- Counters
	signal icounter, nicounter: unsigned(N-1 downto 0):= (others => '0');
	signal ccounter, nccounter: unsigned(N-1 downto 0):= (others => '0');
	signal wcounter, nwcounter: unsigned(N-1 downto 0):= (others => '0');
	-- Cycle constants
	constant d750k: unsigned(N-1 downto 0):= to_unsigned(750000-1, N);
	constant d205k: unsigned(N-1 downto 0):= to_unsigned(205000-1, N);
	constant d100k: unsigned(N-1 downto 0):= to_unsigned(100000-1, N);
	constant d5k: unsigned(N-1 downto 0):= to_unsigned(5000-1, N);
	constant d2k: unsigned(N-1 downto 0):= to_unsigned(2000-1, N);
	constant d12c: unsigned(N-1 downto 0):= to_unsigned(12-1, N);
	-- Control stage
	signal iend: std_logic:= '0';
	signal cend: std_logic:= '0';
	signal wend: std_logic:= '0';
	
	signal pulse: std_logic := '0';
begin
	--
	process(clk)
	begin
		if rising_edge(clk) then
			icounter <= nicounter;
			ccounter <= nccounter;
			wcounter <= nwcounter;
			sstate <= nsstate;
			istate <= nistate;
			cstate <= ncstate;
			wstate <= nwstate;
			currentChar <= nCurrentChar;
		end if;
	end process;
	
	process(istate, icounter, sstate)
	begin
		nistate <= istate;
		nicounter <= icounter;
		iend <= '0';
		if sstate = initS then
			case istate is
				when i0 =>
					nicounter <= icounter + 1;
					if icounter >= d750k then
						nistate <= e1;
						nicounter <= (others => '0');
					end if;
				when e1 =>
					nicounter <= icounter + 1;
					if icounter >= d12c then
						nistate <= i2;
						nicounter <= (others => '0');
					end if;
				when i2 =>
					nicounter <= icounter + 1;
					if icounter >= d205k then
						nistate <= e3;
						nicounter <= (others => '0');
					end if;
				when e3 =>
					nicounter <= icounter + 1;
					if icounter >= d12c then
						nistate <= i4;
						nicounter <= (others => '0');
					end if;
				when i4 =>
					nicounter <= icounter + 1;
					if icounter >= d5k then
						nistate <= e5;
						nicounter <= (others => '0');
					end if;
				when e5 =>
					nicounter <= icounter + 1;
					if icounter >= d12c then
						nistate <= i6;
						nicounter <= (others => '0');
					end if;
				when i6 =>
					nicounter <= icounter + 1;
					if icounter >= d2k then
						nistate <= e7;
						nicounter <= (others => '0');
					end if;
				when e7 =>
					nicounter <= icounter + 1;
					if icounter >= d12c then
						nistate <= i8;
						nicounter <= (others => '0');
					end if;
				when i8 =>
					nicounter <= icounter + 1;
					if icounter >= d2k then
						nistate <= i0;
						nicounter <= (others => '0');
						iend <= '1';
					end if;
			end case;
		end if;
	end process;
	
	process(cstate, ccounter, sstate)
	begin
		ncstate <= cstate;
		nccounter <= ccounter;
		cend <= '0';
		if sstate = confS then
			case cstate is
				when d0 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c1;
						nccounter <= (others => '0');
					end if;
				when c1 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d2;
						nccounter <= (others => '0');
					end if;
				when d2 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c3;
						nccounter <= (others => '0');
					end if;
				when c3 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d4;
						nccounter <= (others => '0');
					end if;
				when d4 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c5;
						nccounter <= (others => '0');
					end if;
				when c5 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d6;
						nccounter <= (others => '0');
					end if;
				when d6 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c7;
						nccounter <= (others => '0');
					end if;
				when c7 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d8;
						nccounter <= (others => '0');
					end if;
				when d8 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c9;
						nccounter <= (others => '0');
					end if;
				when c9 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d10;
						nccounter <= (others => '0');
					end if;
				when d10 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c11;
						nccounter <= (others => '0');
					end if;
				when c11 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d12;
						nccounter <= (others => '0');
					end if;
				when d12 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c13;
						nccounter <= (others => '0');
					end if;
				when c13 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d14;
						nccounter <= (others => '0');
					end if;
				when d14 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= c15;
						nccounter <= (others => '0');
					end if;
				when c15 =>
					nccounter <= ccounter + 1;
					if ccounter >= d12c then
						ncstate <= d16;
						nccounter <= (others => '0');
					end if;
				when d16 =>
					nccounter <= ccounter + 1;
					if ccounter >= d100k then
						ncstate <= d0;
						nccounter <= (others => '0');
						cend <= '1';
					end if;
				end case;
			end if;
	end process;
	
	process(wstate,wcounter, sstate, opcode, currentChar)
	begin
		nwstate <= wstate;
		nwcounter <= wcounter;
		nCurrentChar <= currentChar;
		wend <= '0';
		if sstate = writS then
			case wstate is
				when decode =>
					case opcode is
						when "00001" => -- MOV A, [end]
							charsToWrite(0) <= "01001101"; -- M
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010110"; -- V
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01011011"; -- [
							charsToWrite(8) <= "01100101"; -- e
							charsToWrite(9) <= "01101110"; -- n
							charsToWrite(10) <= "01100100"; -- d
							charsToWrite(11) <= "01011101"; -- ]
						when "00010" => -- MOV [end], A
							charsToWrite(0) <= "01001101"; -- M
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010110"; -- V
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01011011"; -- [
							charsToWrite(5) <= "01100101"; -- e
							charsToWrite(6) <= "01101110"; -- n
							charsToWrite(7) <= "01100100"; -- d
							charsToWrite(8) <= "01011101"; -- ]
							charsToWrite(9) <= "00101100"; -- ,
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "01000001"; -- A
						when "00011" => -- MOV A, B
							charsToWrite(0) <= "01001101"; -- M
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010110"; -- V
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000010"; -- B
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "00100" => -- MOV B, A
							charsToWrite(0) <= "01001101"; -- M
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010110"; -- V
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000010"; -- B
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000001"; -- A
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "00101" => -- ADD A, B
							charsToWrite(0) <= "01000001"; -- A
							charsToWrite(1) <= "01000100"; -- D
							charsToWrite(2) <= "01000100"; -- D
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000010"; -- B
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "00110" => -- SUB A, B
							charsToWrite(0) <= "01010011"; -- S
							charsToWrite(1) <= "01010101"; -- U
							charsToWrite(2) <= "01000010"; -- B
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000010"; -- B
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "00111" => -- AND A, B
							charsToWrite(0) <= "01000001"; -- A
							charsToWrite(1) <= "01001110"; -- N
							charsToWrite(2) <= "01000100"; -- D
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000010"; -- B
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01000" => -- OR A, B
							charsToWrite(0) <= "01001111"; -- O
							charsToWrite(1) <= "01010010"; -- R
							charsToWrite(2) <= "00100000"; -- ' '
							charsToWrite(3) <= "01000001"; -- A
							charsToWrite(4) <= "00101100"; -- ,
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "01000010"; -- B
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01001" => -- XOR A, B
							charsToWrite(0) <= "01011000"; -- X
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010010"; -- R
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00101100"; -- ,
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "01000010"; -- B
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01010" => -- NOT A
							charsToWrite(0) <= "01001110"; -- N
							charsToWrite(1) <= "01001111"; -- O
							charsToWrite(2) <= "01010100"; -- T
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01011" => -- NAND A, B
							charsToWrite(0) <= "01001110"; -- N
							charsToWrite(1) <= "01000001"; -- A
							charsToWrite(2) <= "01001110"; -- N
							charsToWrite(3) <= "01000100"; -- D
							charsToWrite(4) <= "00100000"; -- ' '
							charsToWrite(5) <= "01000001"; -- A
							charsToWrite(6) <= "00101100"; -- ,
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "01000010"; -- B
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01100" => -- JZ [end]
							charsToWrite(0) <= "01001010"; -- J
							charsToWrite(1) <= "01011010"; -- Z
							charsToWrite(2) <= "00100000"; -- ' '
							charsToWrite(3) <= "01011011"; -- [
							charsToWrite(4) <= "01100101"; -- e
							charsToWrite(5) <= "01101110"; -- n
							charsToWrite(6) <= "01100100"; -- d
							charsToWrite(7) <= "01011101"; -- ]
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01101" => -- JN [end]
							charsToWrite(0) <= "01001010"; -- J
							charsToWrite(1) <= "01001110"; -- N
							charsToWrite(2) <= "00100000"; -- ' '
							charsToWrite(3) <= "01011011"; -- [
							charsToWrite(4) <= "01100101"; -- e
							charsToWrite(5) <= "01101110"; -- n
							charsToWrite(6) <= "01100100"; -- d
							charsToWrite(7) <= "01011101"; -- ]
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01110" => -- HALT
							charsToWrite(0) <= "01001000"; -- H
							charsToWrite(1) <= "01000001"; -- A
							charsToWrite(2) <= "01001100"; -- L
							charsToWrite(3) <= "01010100"; -- T
							charsToWrite(4) <= "00100000"; -- ' '
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "01111" => -- JMP [end]
							charsToWrite(0) <= "01001010"; -- J
							charsToWrite(1) <= "01001101"; -- M
							charsToWrite(2) <= "01010000"; -- P
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01011011"; -- [
							charsToWrite(5) <= "01100101"; -- e
							charsToWrite(6) <= "01101110"; -- n
							charsToWrite(7) <= "01100100"; -- d
							charsToWrite(8) <= "01011101"; -- ]
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "10000" => -- INC A
							charsToWrite(0) <= "01001001"; -- I
							charsToWrite(1) <= "01001110"; -- N
							charsToWrite(2) <= "01000011"; -- C
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "10001" => -- INC B
							charsToWrite(0) <= "01001001"; -- I
							charsToWrite(1) <= "01001110"; -- N
							charsToWrite(2) <= "01000011"; -- C
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000010"; -- B
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "10010" => -- DEC A
							charsToWrite(0) <= "01000100"; -- D
							charsToWrite(1) <= "01000101"; -- E
							charsToWrite(2) <= "01000011"; -- C
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000001"; -- A
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when "10011" => -- DEC B
							charsToWrite(0) <= "01000100"; -- D
							charsToWrite(1) <= "01000101"; -- E
							charsToWrite(2) <= "01000011"; -- C
							charsToWrite(3) <= "00100000"; -- ' '
							charsToWrite(4) <= "01000010"; -- B
							charsToWrite(5) <= "00100000"; -- ' '
							charsToWrite(6) <= "00100000"; -- ' '
							charsToWrite(7) <= "00100000"; -- ' '
							charsToWrite(8) <= "00100000"; -- ' '
							charsToWrite(9) <= "00100000"; -- ' '
							charsToWrite(10) <= "00100000"; -- ' '
							charsToWrite(11) <= "00100000"; -- ' '
						when others =>
					end case;
					nCurrentChar <= (others => '0');
					nwstate <= w0;
				when w0 =>
					nwcounter <= wcounter + 1;
					if wcounter >= d100k then
						nwstate <= n1;
						nwcounter <= (others => '0');
					end if;
				when n1 =>
					nwcounter <= wcounter + 1;
					if wcounter >= d12c then
						nwstate <= w2;
						nwcounter <= (others => '0');
					end if;
				when w2 =>
					nwcounter <= wcounter + 1;
					if wcounter >= d100k then
						nwstate <= n3;
						nwcounter <= (others => '0');
					end if;
				when n3 =>
					nwcounter <= wcounter + 1;
					if wcounter >= d12c then
						nwstate <= w4;
						nwcounter <= (others => '0');
					end if;
				when w4 =>
					nwcounter <= wcounter + 1;
					if wcounter >= d100k then
						if currentChar >= 11 then
							nCurrentChar <= (others => '0');
							nwstate <= decode;
							wend <= '1';
						else
							nCurrentChar <= currentChar + 1;
							nwstate <= w0;
						end if;
						nwcounter <= (others => '0');
					end if;
			end case;
		end if;
	end process;
	
	process(sstate,istate,cstate,wstate,charsToWrite)
		variable charToWrite: std_logic_vector(7 downto 0) := (others => '0');
	begin
--		type stage is (init,conf,writ,finish);
--		type init is (i0,e1,i2,e3,i4,e5,i6,e7,i8);
		data <= (others => '0');
		enable <= '0';
		rw <= '0';
		rs <= '0';
		case sstate is
			when initS =>
				case istate is
					when e1 =>
						data <= "0011";
						enable <= '1';
					when e3 =>
						data <= "0011";
						enable <= '1';
					when e5 =>
						data <= "0011";
						enable <= '1';
					when e7 =>
						data <= "0010";
						enable <= '1';
					when others =>
				end case;
			when confS =>
--		type conf is (d0,c1,d2,c3,d4,c5,d6,c7,d8,c9,d10,c11,d12,c13,d14,c15,d16);
				case cstate is
					when d0 =>
						data <= "0010";
						rs <= '0';
						rw <= '0';
					when c1 =>
						data <= "0010";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d2 =>
						data <= "1000";
						rs <= '0';
						rw <= '0';
					when c3 =>
						data <= "1000";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d4 =>
						data <= "0000";
						rs <= '0';
						rw <= '0';
					when c5 =>
						data <= "0000";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d6 =>
						data <= "0110";
						rs <= '0';
						rw <= '0';
					when c7 =>
						data <= "0110";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d8 =>
						data <= "0000";
						rs <= '0';
						rw <= '0';
					when c9 =>
						data <= "0000";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d10 =>
						data <= "1100";
						rs <= '0';
						rw <= '0';
					when c11 =>
						data <= "1100";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d12 =>
						data <= "0000";
						rs <= '0';
						rw <= '0';
					when c13 =>
						data <= "0000";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d14 =>
						data <= "0001";
						rs <= '0';
						rw <= '0';
					when c15 =>
						data <= "0001";
						enable <= '1';
						rs <= '0';
						rw <= '0';
					when d16 =>
						data <= "0001";
						rs <= '0';
						rw <= '0';
					when others =>
				end case;
			when writS =>
--		type writ is (w0,n1,w2,n3,w4);
				charToWrite := charsToWrite(to_integer(currentChar));
				case wstate is
					when w0 =>
						data <= charToWrite(7 downto 4);
						rs <= '1';
						rw <= '0';
					when n1 =>
						data <= charToWrite(7 downto 4);
						enable <= '1';
						rs <= '1';
						rw <= '0';
					when w2 =>
						data <= charToWrite(3 downto 0);
						rs <= '1';
						rw <= '0';
					when n3 =>
						data <= charToWrite(3 downto 0);
						enable <= '1';
						rs <= '1';
						rw <= '0';
					when w4 =>
						data <= charToWrite(3 downto 0);
						rs <= '1';
						rw <= '0';
					when others =>
				end case;
			when finishS =>
		end case;
	end process;
	
	process(clk)
   variable idle : boolean := true;
	begin
		if rising_edge(clk) then
			pulse <= '0';     -- default action
			if idle then
				if rewrite = '1' then
					pulse <= '1';  -- overrides default FOR THIS CYCLE ONLY
					idle := false;
				end if;
			else
				if rewrite = '0' then
					idle := true;
				end if;
			end if;
	  end if;
	end process;
	
	nsstate <= confS when iend = '1' else
		writS when cend = '1' else
		finishS when wend = '1' else
		confS when sstate = finishS and pulse = '1' else
		sstate;
	
	dsf <= '1';

end lcdArch;
