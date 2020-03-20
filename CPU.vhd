library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
	generic(
		opN: integer := 5;
		wordN: integer := 5;
		addrN: integer := 5;
		countN: integer := 5;
		cpuClkN: integer := 26
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		zero: out std_logic;
		negative: out std_logic;
		memoryWord: out std_logic_vector(wordN-1 downto 0);
		cpuClkOut: out std_logic;
		lcdData: out std_logic_vector(3 downto 0);
		lcdEn: out std_logic;
		lcdRw: out std_logic;
		lcdRs: out std_logic;
		sfEn: out std_logic -- Disable StrataFlash
	);
end CPU;

architecture CPUArch of CPU is
	-- Ports
	signal inZero: std_logic := '0';
	signal inNegative: std_logic := '0';

	-- CPU Registers
	signal regA, nextRegA: std_logic_vector(wordN-1 downto 0) := (others => '0');
	signal regB, nextRegB: std_logic_vector(wordN-1 downto 0) := (others => '0');
	
	-- Control Unit
	signal cpuClkCounter: unsigned(cpuClkN-1 downto 0) := (others => '0');
	signal cpuClk: std_logic:= '0';
	signal regPC, nextRegPC: std_logic_vector(addrN-1 downto 0) := (others => '0'); -- Program counter
	signal regIR, nextRegIR: std_logic_vector(4 downto 0) := (others => '0'); -- Instruction register
	
	-- FSM
	type FSM is (
		idle,
		fetch,
		decode,
		exeReadRAM, -- Execute memory read to regA
		exeWriteRAM, -- Execute memory write from regA
		exeMoveA2B, -- Execute move from regA to regB
		exeMoveB2A, -- Execute move from regB to regA
		exeALU2A, -- Execute ALU operation, save in regA
		exeALU2B, -- Execute ALU operation, save in regB
		exeJZ, -- Execute jump to address if zero
		exeJN, -- Execute jump to address if negative
		exeJMP, -- Execute jump to address
		halt
	);
	signal state, nextState: FSM := idle;
	signal counter, nextCounter: unsigned(countN downto 0) := (others => '0');
	
	-- External to CPU
	signal opA, opB: std_logic_vector(opN-1 downto 0) := (others => '0');
	
	-- RAM signals
	signal wrEn: std_logic := '0';
	signal addr: std_logic_vector(addrN-1 downto 0) := (others => '0');
	signal dataIn: std_logic_vector(wordN-1 downto 0) := (others => '0');
	signal dataOut: std_logic_vector(wordN-1 downto 0) := (others => '0');
	
	-- ALU signals
	signal op: std_logic := '0';
	signal opcodeALU: std_logic_vector(4 downto 0) := (others => '0');
	signal result: std_logic_vector(opN-1 downto 0) := (others => '0');
	
	-- LCD signals
	signal rewrite: std_logic := '0';
	
	component RAM
		port(
			clk: in std_logic;
			reset: in std_logic;
			wrEn: in std_logic; -- write enable
			addr: in std_logic_vector(addrN-1 downto 0);
			dataIn: in std_logic_vector(wordN-1 downto 0);
			dataOut: out std_logic_vector(wordN-1 downto 0);
			memoryWord: out std_logic_vector(wordN-1 downto 0)
		);
	end component;
	
	component ALU
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
	end component;
	
	component LCD
		port(
			clk: in std_logic;
			opcode: in std_logic_vector(4 downto 0);
			rewrite: in std_logic;
			data: out std_logic_vector(3 downto 0);
			enable: out std_logic;
			rw: out std_logic;
			rs: out std_logic;
			dsf: out std_logic
		);
	end component;
	
begin
	RAMInst: RAM port map (
		clk => cpuClk,
		reset => reset,
		wrEn => wrEn,
		addr => addr,
		dataIn => dataIn,
		dataOut => dataOut,
		memoryWord => memoryWord
	);
	
	ALUInst: ALU port map (
		clk => cpuClk,
		op => op,
		reset => reset,
		opA => opA,
		opB => opB,
		opcode => opcodeALU,
		zero => inZero,
		negative => inNegative,
		result => result
	);
	
	LCDInst: LCD port map (
		clk => clk,
		opcode => regIR,
		rewrite => rewrite,
		data => lcdData,
		enable => lcdEn,
		rw => lcdRw,
		rs => lcdRs,
		dsf => sfEn
	);
	
	newClock: process(clk)
	begin
		if rising_edge(clk) then
			cpuClkCounter <= cpuClkCounter + 1;
		end if;
	end process newClock;

	sync: process(cpuClk, reset)
	begin
		if reset = '1' then
			regA <= (others => '0');
			regB <= (others => '0');
			regPC <= (others => '0');
			regIR <= (others => '0');
		elsif rising_edge(cpuClk) then
			state <= nextState;
			regA <= nextRegA;
			regB <= nextRegB;
			regPC <= nextRegPC;
			regIR <= nextRegIR;
			counter <= nextCounter;
		end if;
	end process sync;
	
	async: process(state, regA, regB, regPC, regIR, counter, dataOut, inZero, inNegative, result)
	begin
		nextState <= state;
		nextRegA <= regA;
		nextRegB <= regB;
		nextRegPC <= regPC;
		nextRegIR <= regIR;
		nextCounter <= counter;
		
		wrEn <= '0';
		rewrite <= '0';
		
		case state is
			when idle =>
				nextState <= fetch;
				nextCounter <= (others => '0');
			when fetch =>
				addr <= regPC;
				nextCounter <= counter + 1;
				if counter >= 1 then
					nextRegIR <= dataOut;
					nextCounter <= (others => '0');
					nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
					nextState <= decode;
				end if;
			when decode =>
				rewrite <= '1';
				case regIR is
					when "00001" => -- MOV A, [end]
						addr <= regPC;
						nextCounter <= counter + 1;
						if counter >= 1 then
							addr <= dataOut;
							nextCounter <= (others => '0');
							nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
							nextState <= exeReadRAM;
						end if;
					when "00010" => -- MOV [end], A
						addr <= regPC;
						nextCounter <= counter + 1;
						if counter >= 1 then
							addr <= dataOut;
							wrEn <= '1';
							nextCounter <= (others => '0');
							nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
							nextState <= exeWriteRAM;
						end if;
					when "00011" => -- MOV A, B
						nextState <= exeMoveB2A;
					when "00100" => -- MOV B, A
						nextState <= exeMoveA2B;
					when "00101" => -- ADD A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "00101";
						nextState <= exeALU2A;
					when "00110" => -- SUB A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "00110";
						nextState <= exeALU2A;
					when "00111" => -- AND A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "00111";
						nextState <= exeALU2A;
					when "01000" => -- OR A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "01000";
						nextState <= exeALU2A;
					when "01001" => -- XOR A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "01001";
						nextState <= exeALU2A;
					when "01010" => -- NOT A
						opA <= regA;
						opcodeALU <= "01010";
						nextState <= exeALU2A;
					when "01011" => -- NAND A, B
						opA <= regA;
						opB <= regB;
						opcodeALU <= "01011";
						nextState <= exeALU2A;
					when "01100" => -- JZ [end]
						addr <= regPC;
						nextCounter <= counter + 1;
						if counter >= 1 then
							addr <= dataOut;
							nextCounter <= (others => '0');
							nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
							nextState <= exeJZ;
						end if;
					when "01101" => -- JN [end]
						addr <= regPC;
						nextCounter <= counter + 1;
						if counter >= 1 then
							addr <= dataOut;
							nextCounter <= (others => '0');
							nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
							nextState <= exeJN;
						end if;
					when "01110" => -- HALT
						nextState <= halt;
					when "01111" => -- JMP [end]
						addr <= regPC;
						nextCounter <= counter + 1;
						if counter >= 1 then
							addr <= dataOut;
							nextCounter <= (others => '0');
							nextRegPC <= std_logic_vector(unsigned(regPC) + 1);
							nextState <= exeJMP;
						end if;
					when "10000" => -- INC A
						opA <= regA;
						opcodeALU <= "10000";
						nextState <= exeALU2A;
					when "10001" => -- INC B
						opA <= regB;
						opcodeALU <= "10000";
						nextState <= exeALU2B;
					when "10010" => -- DEC A
						opA <= regA;
						opcodeALU <= "10010";
						nextState <= exeALU2A;
					when "10011" => -- DEC B
						opA <= regB;
						opcodeALU <= "10010";
						nextState <= exeALU2B;
					when others =>
				end case;
			when exeReadRAM =>
				nextRegA <= dataOut;
				nextState <= fetch;
			when exeWriteRAM =>
				wrEn <= '1';
				dataIn <= regA;
				nextState <= fetch;
			when exeMoveA2B =>
				nextRegB <= regA;
				nextState <= fetch;
			when exeMoveB2A =>
				nextRegA <= regB;
				nextState <= fetch;
			when exeALU2A =>
				op <= '1';
				nextCounter <= counter + 1;
				if counter >= 1 then
					nextRegA <= result;
					op <= '0';
					nextCounter <= (others => '0');
					nextState <= fetch;
				end if;
			when exeALU2B =>
				op <= '1';
				nextCounter <= counter + 1;
				if counter >= 1 then
					nextRegB <= result;
					op <= '0';
					nextCounter <= (others => '0');
					nextState <= fetch;
				end if;
			when exeJZ =>
				if inZero = '1' then
					nextRegPC <= dataOut;
				end if;
				nextState <= fetch;
			when exeJN =>
				if inNegative = '1' then
					nextRegPC <= dataOut;
				end if;
				nextState <= fetch;
			when exeJMP =>
				nextRegPC <= dataOut;
				nextState <= fetch;
			when halt =>
			when others =>
		end case;
	end process async;
	
	cpuClk <= cpuClkCounter(cpuClkN-1);
	cpuClkOut <= cpuClk;
	zero <= inZero;
	negative <= inNegative;
	
end CPUArch;

