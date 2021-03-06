----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2018 18:25:37
-- Design Name: 
-- Module Name: Instruction_Memory_module - Behavioral
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER

entity Instruction_Memory_module is
Port ( 
A: in std_logic_vector(31 downto 0);
RD: out std_logic_vector(31 downto 0)
);
end Instruction_Memory_module;

architecture Behavioral of Instruction_Memory_module is

signal fetched_instruction: std_logic_vector(31 downto 0);

    type Instruction_Memory is array (natural range<>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);--(0 TO 2**A'length) replace 10 to 15 with this
    constant MR_Instruction_Memory: Instruction_Memory:=(
    
    x"00",x"00",x"00",x"00",-- PC = 0 
    x"04",x"0A",x"00",x"68",--4 
    x"04",x"0B",x"00",x"10",--8
    x"04",x"0C",x"00",x"4E",--c
       x"04",x"0E",x"00",x"1F",--13
    x"1C",x"C3",x"00",x"00",--18
     x"04",x"0D",x"00",x"03",--10
    x"00",x"00",x"00",x"01",--1c
    x"00",x"61",x"48",x"01",--20
    x"01",x"22",x"48",x"01",--24
    x"15",x"2F",x"00",x"1F",--28
    x"01",x"29",x"48",x"01",--2c
    x"01",x"2F",x"48",x"01",--30
    x"09",x"AD",x"00",x"01",--34
    x"2C",x"0D",x"FF",x"EC",--38
    x"00",x"09",x"08",x"01",--3c
    x"20",x"C1",x"00",x"00",--40
    x"00",x"00",x"00",x"01",--
    x"00",x"22",x"40",x"01",--
    x"0D",x"08",x"00",x"1F",--
    x"1C",x"E4",x"00",x"68",--
    x"00",x"00",x"00",x"01",--
    x"00",x"81",x"48",x"01",--
    x"01",x"22",x"48",x"01",--
    x"28",x"08",x"00",x"14",
    x"15",x"2F",x"00",x"1F",--28
    x"01",x"29",x"48",x"01",--
    x"01",x"2F",x"48",x"01",--30
    x"09",x"08",x"00",x"01",--
    x"2C",x"08",x"FF",x"EC",--
    x"00",x"09",x"10",x"01",--
    x"20",x"E2",x"00",x"68",--
    x"00",x"00",x"00",x"01",--
    x"04",x"C6",x"00",x"04",
    x"04",x"E7",x"00",x"04",
    x"2C",x"CA",x"00",x"04",
    x"00",x"C6",x"30",x"03",
    x"2C",x"EB",x"00",x"04",
    x"00",x"E7",x"38",x"03",
    x"04",x"A5",x"00",x"01",
    x"2C",x"AC",x"FF",x"70", -- KEY GENERATION END  -- PERFECTLY WORKING WHEN INPUT IS ALL 0. 
    -- DONT YOU DARE CHANGE THE KEY GENERATION
    
    --ENCRYPTION
    x"1C",x"01",x"00",x"78",--
    x"00",x"00",x"00",x"01",
    x"1C",x"02",x"00",x"7C",
    x"00",x"00",x"00",x"01",
  --  x"1C",x"03",x"00",x"00",
    x"00",x"00",x"00",x"01",
   -- x"00",x"23",x"08",x"01",
   -- x"1C",x"04",x"00",x"04",
    x"00",x"00",x"00",x"01",--
    --x"00",x"44",x"10",x"01",
    x"04",x"0B",x"00",x"1F",
    x"04",x"0C",x"00",x"30",
    x"04",x"06",x"00",x"00",
    x"04",x"C6",x"00",x"04",
    x"00",x"22",x"20",x"07",--
    x"00",x"22",x"28",x"05",
    x"00",x"85",x"20",x"03",
    x"0C",x"45",x"00",x"1F",
    x"28",x"05",x"00",x"14",
    x"14",x"8D",x"00",x"1F",--
    x"00",x"84",x"20",x"01",
    x"00",x"8D",x"20",x"01",
    x"08",x"A5",x"00",x"01",
    x"2C",x"05",x"FF",x"EC",
    x"00",x"C6",x"38",x"01",--
    x"1C",x"E3",x"00",x"00",
    x"00",x"00",x"00",x"01",
    x"00",x"83",x"08",x"01",
    x"00",x"22",x"20",x"07",
    x"00",x"22",x"28",x"05",--
    x"00",x"85",x"20",x"03",
    x"0C",x"25",x"00",x"1F",
    x"28",x"05",x"00",x"14",
    x"14",x"8D",x"00",x"1F",
    x"00",x"84",x"20",x"01",--
    x"00",x"8D",x"20",x"01",
    x"08",x"A5",x"00",x"01",
    x"2C",x"05",x"FF",x"EC",
    x"04",x"E7",x"00",x"04",
    x"1C",x"E3",x"00",x"00",--
    x"00",x"00",x"00",x"01",
    x"00",x"83",x"10",x"01",
    x"2D",x"86",x"FF",x"88",
    
    --DECRYPTION
    x"04",x"0C",x"00",x"30",
    x"01",x"8C",x"68",x"01",--
    x"05",x"AE",x"00",x"04",
    x"1D",x"C4",x"00",x"00",
    x"00",x"00",x"00",x"01",
    x"00",x"44",x"10",x"03",
    x"0C",x"25",x"00",x"1F",--
    x"28",x"05",x"00",x"18",
    x"0C",x"4F",x"00",x"01",
    x"14",x"42",x"00",x"01",
    x"28",x"0F",x"00",x"04",
    x"00",x"51",x"10",x"01",--
    x"08",x"A5",x"00",x"01",
    x"2C",x"05",x"FF",x"E8",
    x"00",x"22",x"30",x"07",
    x"00",x"22",x"38",x"05",
    x"00",x"C7",x"10",x"03",--
    x"00",x"84",x"20",x"03",
    x"1D",x"A4",x"00",x"00",
    x"00",x"00",    x"00",x"01",
    x"00",x"24",x"08",x"03",
    x"0C",x"45",x"00",x"1F",--
    x"28",x"05",x"00",x"18",
    x"0C",x"2F",x"00",x"01",
    x"14",x"21",x"00",x"01",
    x"28",x"0F",x"00",x"04",
    x"00",x"31",x"08",x"01",--
    x"08",x"A5",x"00",x"01",
    x"2C",x"05",x"FF",x"E8",
    x"00",x"22",x"30",x"07",
    x"00",x"22",x"38",x"05",
    x"00",x"C7",x"08",x"03",--
    x"09",x"8C",x"00",x"04",
    x"2D",x"80",x"FF",x"7C",
   -- x"00",x"84",x"20",x"03",
--    x"1C",x"04",x"00",x"04",
--    x"00",x"00",x"00",x"01",
--    x"00",x"44",x"10",x"03",
--    x"00",x"84",x"20",x"03",
--    --x"1C",x"04",x"00",x"00",
--    x"00",x"00",x"00",x"01",
--    --x"00",x"24",x"08",x"03",
    x"FF",x"FF",x"FF",x"FF"



        );
begin

RD <= fetched_instruction;

fetched_instruction <= MR_Instruction_Memory(CONV_INTEGER(A))
                     & MR_Instruction_Memory(CONV_INTEGER(A)+1) 
                     & MR_Instruction_Memory(CONV_INTEGER(A)+2)
                     & MR_Instruction_Memory(CONV_INTEGER(A)+3);
end Behavioral;


--    x"00",x"00",x"00",x"00",-- PC = 0 
--    x"00",x"A6",x"F5",x"01",--ADD RTYPE PC = 4
--    x"00",x"A6",x"F5",x"03",--SUB RTYPE PC = 8   
--    x"00",x"EE",x"FF",x"05",--AND RTYPE PC = C
--    x"00",x"09",x"0A",x"07",-- OR RTYPE 
--    x"00",x"0D",x"0E",x"0F",--NOR RTYPE 
--    x"EE",x"01",x"02",x"03",--ADD ITYPE 
--    x"02",x"05",x"06",x"07",--SUB ITYPE
--    x"03",x"09",x"0A",x"0B",--AND ITYPE
--    x"04",x"0D",x"0E",x"0F",-- OR ITYPE
--    x"05",x"01",x"02",x"03",--SHR ITYPE
--    x"04",x"05",x"06",x"07",
--    x"08",x"09",x"0A",x"0B",
--    x"0C",x"0D",x"0E",x"0F",    
--    x"08",x"09",x"0A",x"0B",
--    x"0C",x"0D",x"0E",x"0F",    
--    x"00",x"01",x"02",x"03",
--    x"04",x"05",x"06",x"07",
--    x"08",x"09",x"0A",x"0B",
--    x"0C",x"0D",x"0E",x"0F",
--    x"00",x"01",x"02",x"03",
--    x"04",x"05",x"06",x"07",
--    x"08",x"09",x"0A",x"0B",
--    x"0C",x"0D",x"0E",x"0F",
--    x"00",x"01",x"02",x"03",
--    x"04",x"05",x"06",x"07",
--    x"08",x"09",x"0A",x"0B",
--    x"0C",x"0D",x"0E",x"0F",
--    x"00",x"01",x"02",x"03",
--    x"04",x"05",x"06",x"07",
--    x"08",x"09",x"0A",x"0B",
--    x"FF",x"0D",x"0E",x"0F"



-- x"00",x"00",x"00",x"00", -- 00
--    x"04",x"0C",x"00",x"0C",-- 01
--    x"01",x"8D",x"68",x"01",-- 002
--    x"05",x"AE",x"00",x"01",-- 003
--    x"1D",x"C3",x"00",x"00",-- 004
--    x"00",x"43",x"10",x"03",-- 005
--    x"04",x"42",x"00",x"1F",-- 006
--    x"28",x"04",x"00",x"0C",-- 007
--    x"14",x"42",x"00",x"01",-- 008
--    x"08",x"84",x"00",x"01",-- 009
--    x"2C",x"04",x"FF",x"F4",-- 010
--    x"00",x"22",x"28",x"07",-- 0011
--    x"00",x"22",x"30",x"05",-- 0012
--    x"00",x"A6",x"10",x"03",-- 0013
--    x"00",x"63",x"18",x"03",-- 0014
--    x"1D",x"A3",x"00",x"00",-- 0015
--    x"00",x"23",x"08",x"03",-- 0016
--    x"0C",x"44",x"00",x"1F",-- 0017
--    x"28",x"04",x"00",x"0C",-- 0018
--    x"14",x"21",x"00",x"01",-- 0019
--    x"08",x"84",x"00",x"01",-- 0020
--    x"2C",x"04",x"FF",x"F4",-- 00
--    x"00",x"22",x"28",x"07",-- 00
--    x"00",x"22",x"30",x"05",-- 00
--    x"00",x"A6",x"08",x"03",-- 00
--    x"09",x"8C",x"00",x"01",-- 00
--    x"2D",x"80",x"FF",x"94",-- 00
--    x"00",x"63",x"18",x"03",-- 00
--    x"1C",x"03",x"00",x"01",-- 00
--    x"00",x"43",x"10",x"03",-- 00
--    x"00",x"63",x"18",x"03",-- 00
--    x"1C",x"03",x"00",x"00",-- 00
--    x"00",x"23",x"08",x"03"-- 00