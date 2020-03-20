LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY CPUTb IS
END CPUTb;
 
ARCHITECTURE behavior OF CPUTb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPU
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         zero : OUT  std_logic;
         negative : OUT  std_logic;
         memoryWord : OUT  std_logic_vector(4 downto 0);
         lcdData : OUT  std_logic_vector(3 downto 0);
         lcdEn : OUT  std_logic;
         lcdRw : OUT  std_logic;
         lcdRs : OUT  std_logic;
         sfEn : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal zero : std_logic;
   signal negative : std_logic;
   signal memoryWord : std_logic_vector(4 downto 0);
   signal lcdData : std_logic_vector(3 downto 0);
   signal lcdEn : std_logic;
   signal lcdRw : std_logic;
   signal lcdRs : std_logic;
   signal sfEn : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CPU PORT MAP (
          clk => clk,
          reset => reset,
          zero => zero,
          negative => negative,
          memoryWord => memoryWord,
          lcdData => lcdData,
          lcdEn => lcdEn,
          lcdRw => lcdRw,
          lcdRs => lcdRs,
          sfEn => sfEn
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

      wait;
   end process;

END;
