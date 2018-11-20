----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2018 00:26:05
-- Design Name: 
-- Module Name: dut_vhdl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dut_vhdl is
    Port ( led : out STD_LOGIC_VECTOR (15 downto 0);
           led16_B : out STD_LOGIC;
           led16_G : out STD_LOGIC;
           led16_R : out STD_LOGIC;
           led17_B : out STD_LOGIC;
           led17_G : out STD_LOGIC;
           led17_R : out STD_LOGIC;
           segments : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC;
           digits : out STD_LOGIC_VECTOR (7 downto 0);
           btn_center : in STD_LOGIC;
           btn_up : in STD_LOGIC;
           btn_left : in STD_LOGIC;
           btn_right : in STD_LOGIC;
           btn_down : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0));
end dut_vhdl;

architecture Behavioral of dut_vhdl is

begin

led <= sw;

led16_B <= '0';
led16_G <= '0';
led16_R <= '1';

led17_B <= '0';
led17_G <= '1';
led17_R <= '0';

segments <= "0001000";
digits <= "01011010";



end Behavioral;
