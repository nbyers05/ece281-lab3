--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
   
    port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );

end component thunderbird_fsm;

	--Inputs
	signal w_L : std_logic := '0';
	signal w_R : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	
	--Outputs
	signal w_tailight_L : std_logic_vector(2 downto 0) := "000"; 
	signal w_tailight_R : std_logic_vector(2 downto 0) := "000";
		
	-- Clock period definitions
	constant k_clk_period : time := 10 ns;
	
	
begin
	-- PORT MAPS ----------------------------------------
	-- Instantiate the Unit Under Test (UUT)
   uut: thunderbird_fsm port map (
          i_left => w_L,
          i_right => w_R,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L(0) => w_tailight_L(0),
          o_lights_L(1) => w_tailight_L(1),
          o_lights_L(2) => w_tailight_L(2),
          o_lights_R(2) => w_tailight_R(2),
          o_lights_R(1) => w_tailight_R(1),
          o_lights_R(0) => w_tailight_R(0)
          
        );
	
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
	clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	
	-- Simulation process
	-- Use 220 ns for simulation
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1'; w_L <= '0'; w_R <= '0';
		wait for k_clk_period;
		assert (w_tailight_L = "000" and w_tailight_R = "000") report "bad reset" severity failure;
		
		w_reset <= '0';
		--Left turn signal test
		w_L <= '1'; w_R <= '0';
		wait for k_clk_period;
		assert (w_tailight_L = "001" and w_tailight_R = "000") report "left turn LA fail" severity failure;
		

		wait for k_clk_period;
		assert (w_tailight_L = "011" and w_tailight_R = "000") report "left turn LB fail" severity failure;
		
		wait for k_clk_period;
		assert (w_tailight_L = "111" and w_tailight_R = "000") report "left turn LC fail" severity failure;
		
		--Right turn signal test
		w_L <= '0'; w_R <= '1';
		wait for k_clk_period;
		assert (w_tailight_R = "001" and w_tailight_L = "000") report "left turn RA fail" severity failure;
		

		wait for k_clk_period;
		assert (w_tailight_R = "011" and w_tailight_L = "000") report "left turn RB fail" severity failure;
		
		wait for k_clk_period;
		assert (w_tailight_R = "111" and w_tailight_L = "000") report "left turn RC fail" severity failure;
		
		--Hazard Light Test
		w_L <= '1'; w_R <= '1';
    wait for k_clk_period;  
    wait for k_clk_period;  
    assert (w_tailight_R = "111" and w_tailight_L = "111") report "Hazard Light Fail";
		
		--Switching to Hazard during blinker test
		
		w_L <= '0'; w_R <= '1';
		wait for k_clk_period;
		
		assert (w_tailight_R = "001" and w_tailight_L = "000") report "left turn RA fail" severity failure;
		
		w_L <= '1'; w_R <= '1';
		wait for k_clk_period;
		assert (w_tailight_R = "011" and w_tailight_L = "000") report "Blinker to Hazard RB fail " severity failure;
		

          
          
     wait;
   end process;		
end test_bench;
