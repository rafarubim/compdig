LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
USE ieee.numeric_std.ALL;
 
ENTITY ALUTb IS
END ALUTb;
 
ARCHITECTURE behavior OF ALUTb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         clk : IN  std_logic;
         op : IN  std_logic;
         reset : IN  std_logic;
         opA : IN  std_logic_vector(4 downto 0);
         opB : IN  std_logic_vector(4 downto 0);
         opcode : IN  std_logic_vector(4 downto 0);
         zero : OUT  std_logic;
         negative : OUT  std_logic;
         result : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal op : std_logic := '0';
   signal reset : std_logic := '0';
   signal opA : std_logic_vector(4 downto 0) := (others => '0');
   signal opB : std_logic_vector(4 downto 0) := (others => '0');
   signal opcode : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal zero : std_logic;
   signal negative : std_logic;
   signal result : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          clk => clk,
          op => op,
          reset => reset,
          opA => opA,
          opB => opB,
          opcode => opcode,
          zero => zero,
          negative => negative,
          result => result
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		
		wait for clk_period/2;
		
		-- Expected result: "00101"

      opA <= "00100";
		opB <= "00001";
		opcode <= "00101"; -- Addition
		op <= '1';
		wait for clk_period;
		op <= '0';
		wait for clk_period;
		
		-- Expected result: "00000", zero flag on
		
		opA <= "10000";
		opB <= "10000";
		opcode <= "00101"; -- Addition
		op <= '1';
		wait for clk_period;
		op <= '0';
		wait for clk_period;
		
		-- Expected result: "11100", negative flag on
		
		opA <= std_logic_vector(to_signed(-1, 5));
		opB <= std_logic_vector(to_signed(-3, 5));
		opcode <= "00101"; -- Addition
		op <= '1';
		wait for clk_period;
		op <= '0';
		wait for clk_period;
		
		-- Expected result: "00010"

      opA <= "00110";
		opB <= "00011";
		opcode <= "00111"; -- And
		op <= '1';
		wait for clk_period;
		op <= '0';
		wait for clk_period;
		
		-- Expected result: "00111"

      opA <= "00110";
		opB <= "00011";
		opcode <= "01000"; -- Or
		op <= '1';
		wait for clk_period;
		op <= '0';
		wait for clk_period;

      wait;
   end process;

END;
