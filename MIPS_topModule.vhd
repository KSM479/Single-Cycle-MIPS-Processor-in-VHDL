library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity SevenSeg_Top is
    Port ( 
    SEL_MSB: in std_logic;--btnD
    RST: in std_logic;--btnC
    MANUAL_CLOCK: in std_logic;--btnU
    LOCK_DATA: in std_logic; -- btnL   
    INPUT_VALID: in std_logic; -- btnR
    switch_DATA_input: in std_logic_vector(15 downto 0);
    CLK 		: in   std_logic;
    seg 		: out  std_logic_vector (7 downto 0);
    an 		 : out  std_logic_vector (3 downto 0);
    led      : out  std_logic_vector(15 downto 0)
    );
end SevenSeg_Top;

architecture Behavioral of SevenSeg_Top is

TYPE     StateType IS (ST_IDLE,ST_Processor_Settings, ST_INPUT_Variables, ST_RUN_Processor);--, ST_READY);
SIGNAL	 state : StateType;

  signal Mr_MIPS_CLOCK: std_logic; --- the main clock of our processor
  signal Mr_MIPS_CLOCK_DMEM: std_logic; --- muxed clk to dmem to load data
  
  signal Mr_ConfigCLK: std_logic:='0';
  signal AutoSlow_CLOCK: std_logic:='0';
  signal AutoFast_CLK: std_logic:='0';
  signal AutoPeak_CLK: std_logic:='0';
  
  signal Clk_Mode: std_logic_vector(3 downto 0);
  signal locked_Clk_Mode: std_logic_vector(3 downto 0):="0000";
  signal Processing_Mode: integer range 0 to 5;
  signal processor_operation: std_logic_vector(3 downto 0):="0000";
  signal locked_processor_operation: std_logic_vector(3 downto 0):="0000";
  
  signal rhitvik: std_logic:='0';
  
  --signal START_PROCESSOR: std_logic:='0';
   
signal gar: std_logic;
signal state_Val: std_logic_vector (7 downto 0);

  signal Ninja_Counter: std_logic_vector (15 downto 0);
  signal LOCK_VAL_CONN: std_logic;
  --signal DMEM_INPUT_enable: std_logic;
  
--  signal DEB_LOCK_DATA: std_logic;
--  signal DEB_LOCK_DATAa: std_logic;
--  signal DEB_LOCK_DATAb: std_logic;
--  signal DEB_LOCK_DATAc: std_logic;
--  signal DEB_LOCK_DATAd: std_logic;
--  signal DEB_LOCK_DATAe: std_logic;
--  signal DEB_LOCK_DATAf: std_logic;
--  signal DEB_LOCK_DATAg: std_logic;
--  signal DEB_LOCK_DATAh: std_logic;
--  signal DEB_LOCK_DATAi: std_logic;
--  signal DEB_LOCK_DATAj: std_logic;
--  signal DEB_LOCK_DATAk: std_logic;
--  signal DEB_LOCK_DATAl: std_logic;
  
--    signal DEB_INPUT_VALID: std_logic;
--    signal DEB_INPUT_VALID_a: std_logic;
--    signal DEB_INPUT_VALID_b: std_logic;
--    signal DEB_INPUT_VALID_c: std_logic;
--    signal DEB_INPUT_VALID_d: std_logic;
--    signal DEB_INPUT_VALID_e: std_logic;
--    signal DEB_INPUT_VALID_f: std_logic;
--    signal DEB_INPUT_VALID_g: std_logic;
--    signal DEB_INPUT_VALID_h: std_logic;
--    signal DEB_INPUT_VALID_i: std_logic;
--    signal DEB_INPUT_VALID_j: std_logic;
--    signal DEB_INPUT_VALID_k: std_logic;
--    signal DEB_INPUT_VALID_l: std_logic;
    
  
  signal Secret_INPUT: std_logic_vector (7 downto 0);
  signal Secret_input_LOCATION: std_logic_vector (7 downto 0);

  Type Register_File_ARRAY is array (0 to 31) of std_logic_vector(31 downto 0);
  signal RF_ARRAY: Register_File_ARRAY;
  
  Type DatamMemory_ARRAY is array (0 to 32) of std_logic_vector(31 downto 0);
  signal DMEM_ARRAY: DatamMemory_ARRAY;
    
  signal branch_Out_debug_topModule: std_logic;
  signal branch1_BLT_BEQ_BNE_debug_topModule: std_logic_vector(4 downto 0);

 signal Fetched_instruction: std_logic_vector(31 downto 0);  
 signal RD_topModule:  std_logic_vector(31 downto 0);
 signal readAddress_out_topModule: std_logic_vector(6 downto 0);

-------------
signal MrInformation: std_logic_vector(31 downto 0);
signal MrTemp: std_logic_vector(15 downto 0);
---------------------------------------------------
signal PC_topModule: std_logic_vector(31 downto 0);
---------------------------------------------------
signal RD_insmem_topModule: std_logic_vector(31 downto 0);
---------------------------------------------------
signal opcode_topModule: std_logic_vector(5 downto 0);
signal funct_topModule: std_logic_vector(5 downto 0);

---RF to CONTROL UNIT CONNECTIONS--------------------
signal WE3_RegWrite_topModule: std_logic;--------- 
signal RegDst_topModule: std_logic; 
signal ALUSrc_topModule: std_logic;
---more RF CONNECTIONS-------------------------------
signal RD1_topModule:  std_logic_vector(31 downto 0);
signal RD2_topModule:  std_logic_vector(31 downto 0); 
signal WD3_topModule:  std_logic_vector(31 downto 0); 
signal WriteData_topModule: std_logic_vector(31 downto 0); 
signal PCplus4_topModule: std_logic_Vector(31 downto 0);
signal PCBranch_topModule: std_logic_vector(31 downto 0);
signal SrcA_topModule:  std_logic_vector(31 downto 0);
signal SrcB_topModule:  std_logic_vector(31 downto 0); 
signal MemtoReg_topModule,MemWrite_topModule: std_logic;
--signal branch_topModule : std_logic_vector(1 downto 0);
signal ALUop_topModule: std_logic_vector(2 downto 0);
  
signal ALU_result_topModule: std_logic_vector(31 downto 0);
signal Zero_topModule: std_logic;
signal PCSrc_topModule: std_logic;

signal Jump_topModule: std_logic_vector(25 downto 0);
signal jump_bit_topModule: std_logic;

signal Halt_topModule: std_logic;
--signal reg7_topModule: std_logic_vector(31 downto 0);
component Program_Counter_module is
Port ( 
     PC_out_to_topModule: out std_logic_vector(31 downto 0);
    PCplus4: out std_logic_vector(31 downto 0);
    RST_PCmodule: in std_logic;
    PCSrc_of_PCmodule: in std_logic;
    PCBranch_of_PCmodule: in std_logic_vector(31 downto 0);
    MIPS_CLK_of_PCmodule: in STD_logic;
    Jump_Raw_Address: in std_logic_vector(25 downto 0);
    JmpBit: in std_logic;     Haltbit: in std_logic
    );
    end component;

component Instruction_Memory_module is
Port (
A: in std_logic_vector(31 downto 0);
RD: out std_logic_vector(31 downto 0)
);
end component;

component Register_File is
Port ( 
RF_out0: out std_logic_vector(31 downto 0);
RF_out1: out std_logic_vector(31 downto 0);
RF_out2: out std_logic_vector(31 downto 0);
RF_out3: out std_logic_vector(31 downto 0);
RF_out4: out std_logic_vector(31 downto 0);
RF_out5: out std_logic_vector(31 downto 0);
RF_out6: out std_logic_vector(31 downto 0);
RF_out7: out std_logic_vector(31 downto 0);
RF_out8: out std_logic_vector(31 downto 0);
RF_out9: out std_logic_vector(31 downto 0);
RF_out10: out std_logic_vector(31 downto 0);
RF_out11: out std_logic_vector(31 downto 0);
RF_out12: out std_logic_vector(31 downto 0);
RF_out13: out std_logic_vector(31 downto 0);
RF_out14: out std_logic_vector(31 downto 0);
RF_out15: out std_logic_vector(31 downto 0);
RF_out16: out std_logic_vector(31 downto 0);
RF_out17: out std_logic_vector(31 downto 0);
RF_out18: out std_logic_vector(31 downto 0);
RF_out19: out std_logic_vector(31 downto 0);
RF_out20: out std_logic_vector(31 downto 0);
RF_out21: out std_logic_vector(31 downto 0);
RF_out22: out std_logic_vector(31 downto 0);
RF_out23: out std_logic_vector(31 downto 0);
RF_out24: out std_logic_vector(31 downto 0);
RF_out25: out std_logic_vector(31 downto 0);
RF_out26: out std_logic_vector(31 downto 0);
RF_out27: out std_logic_vector(31 downto 0);
RF_out28: out std_logic_vector(31 downto 0);
RF_out29: out std_logic_vector(31 downto 0);
RF_out30: out std_logic_vector(31 downto 0);
RF_out31: out std_logic_vector(31 downto 0);
 
    RST: in std_logic;
    MIPS_CLK_RF: in std_logic; 
    Instr: in std_logic_vector(31 downto 0);
    WD3: in std_logic_vector(31 downto 0);  
    WriteData: out std_logic_vector(31 downto 0);
    
    PCPlus4_RF_read: in std_logic_vector(31 downto 0);
    PCBranch_RF_out: out std_logic_vector(31 downto 0);-- goes to the counter
    
    OPcode_register_file: out std_logic_vector(5 downto 0); 
    funct_register_file: out std_logic_vector(5 downto 0);  
    
    SrcA: out std_logic_vector(31 downto 0);
    SrcB: out std_logic_vector(31 downto 0); 
    
    RD1_Feedback: out std_logic_vector(31 downto 0);
    RD2_Feedback: out std_logic_vector(31 downto 0);
    
    JUMP_ADDRESS: out std_logic_vector(25 downto 0);
    
    WE3_RF_read: in std_logic;  
    RegDst_RF_read: in std_logic; -- for destination address mux.. controlled via control unit
    ALUSrc_RF_read: in std_logic   
 );
end component;

component Control_Unit is
port (
    rs: in std_logic_vector(31 downto 0);
    rt: in std_logic_vector(31 downto 0);
    
    opcode: in std_logic_vector(5 downto 0);
    funct: in std_logic_vector(5 downto 0);
    MemtoReg: out std_logic; Zero: in std_logic;
    MemWrite: out std_logic;  ALUSrc: out std_logic; 
    RegDst: out std_logic; RegWrite: out std_logic;
    JMP: out std_logic; PCSrc: out std_logic;
    ALUop: out std_logic_vector(2 downto 0);
    Halt: out std_logic;
        
        branch_Out_debug: out std_logic;
        branch1_BLT_BEQ_BNE_debug: out std_logic_vector(4 downto 0)
);
end component;
 
component ALU is
Port (
Zero: out std_logic;
SrcA : in STD_LOGIC_VECTOR(31 DOWNTO 0);--srcA
SrcB : in STD_LOGIC_VECTOR(31 DOWNTO 0);--srcB
ALUControl : in STD_LOGIC_vector(2 DOWNTO 0);--ALUcontrol
ALUResult : out STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end component;

component datamem is
  PORT ( 
    DMEM_rst: in std_logic;
    Secret_INPUT_DMEM:in std_logic_vector (7 downto 0);
    Secret_input_LOCATION_DMEM:in std_logic_vector (7 downto 0);
    lock_value: in std_logic;
    Dmem_out0: out std_logic_vector(31 downto 0);
    Dmem_out1: out std_logic_vector(31 downto 0);
    Dmem_out2: out std_logic_vector(31 downto 0);
    Dmem_out3: out std_logic_vector(31 downto 0);
    Dmem_out4: out std_logic_vector(31 downto 0);
    Dmem_out5: out std_logic_vector(31 downto 0);
    Dmem_out6: out std_logic_vector(31 downto 0);
    Dmem_out7: out std_logic_vector(31 downto 0);
    Dmem_out8: out std_logic_vector(31 downto 0);
    Dmem_out9: out std_logic_vector(31 downto 0);
    Dmem_out10: out std_logic_vector(31 downto 0);
    Dmem_out11: out std_logic_vector(31 downto 0);
    Dmem_out12: out std_logic_vector(31 downto 0);
    Dmem_out13: out std_logic_vector(31 downto 0);
    Dmem_out14: out std_logic_vector(31 downto 0);
    Dmem_out15: out std_logic_vector(31 downto 0);
    Dmem_out16: out std_logic_vector(31 downto 0);
    Dmem_out17: out std_logic_vector(31 downto 0);
    Dmem_out18: out std_logic_vector(31 downto 0);
    Dmem_out19: out std_logic_vector(31 downto 0);
    Dmem_out20: out std_logic_vector(31 downto 0);
    Dmem_out21: out std_logic_vector(31 downto 0);
    Dmem_out22: out std_logic_vector(31 downto 0);
    Dmem_out23: out std_logic_vector(31 downto 0);
    Dmem_out24: out std_logic_vector(31 downto 0);
    Dmem_out25: out std_logic_vector(31 downto 0);
    Dmem_out26: out std_logic_vector(31 downto 0);
    Dmem_out27: out std_logic_vector(31 downto 0);
    Dmem_out28: out std_logic_vector(31 downto 0);
    Dmem_out29: out std_logic_vector(31 downto 0);
    Dmem_out30: out std_logic_vector(31 downto 0);
    Dmem_out31: out std_logic_vector(31 downto 0);
    Dmem_out32: out std_logic_vector(31 downto 0);

       
       MIPS_CLK_Dem: in std_logic;  -- Clock signal
       ALU_result: in std_logic_vector(31 DOWNTO 0);--32-bit address
       WD: in std_logic_vector (31 DOWNTO 0);--32-bit input
       WE: in std_logic; --Write Enable
       Result: out std_logic_vector(31 DOWNTO 0);-- read data
       MemtoReg: in std_logic;
       
       RD_out: out std_logic_vector(31 downto 0);
       readAddress_out: out std_logic_vector(6 downto 0)

     ); 
end component;

component Hex2LED --Converts a 4 bit hex value into the pattern to be displayed on the 7seg
port (CLK: in STD_LOGIC; X: in STD_LOGIC_VECTOR (3 downto 0); Y: out STD_LOGIC_VECTOR (7 downto 0)); 
end component; 

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;
signal Val : std_logic_vector(3 downto 0) := (others => '0');
signal HexVal: std_logic_vector(15 downto 0);
signal slowCLK: std_logic:='0';
signal i_cnt: std_logic_vector(19 downto 0):=x"00000";

begin
-----Creating a slowCLK of 500Hz using the board's 100MHz clock----
process(CLK)
begin
if (rising_edge(CLK)) then
    if (i_cnt=x"186A0")then --Hex(186A0)=Dec(100,000)
        slowCLK<=not slowCLK; --slowCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
        AutoFast_CLK <= not AutoFast_CLK;
        i_cnt<=x"00000";
        Ninja_Counter <= Ninja_Counter + '1';
        if ( Ninja_Counter = x"0014") then
            AutoSlow_CLOCK <= not AutoSlow_CLOCK;
            Ninja_Counter <= x"0001";
        end if;
    else
        i_cnt<=i_cnt+'1';
    end if;
end if;
end process;

-----We use the 500Hz slowCLK to run our 7seg display at roughly 60Hz-----
timer_inc_process : process (slowCLK)
begin
	if (rising_edge(slowCLK)) then
				if(Val="0100") then
				Val<="0001";
				else
				Val <= Val + '1'; --Val runs from 1,2,3,...8 on every rising edge of slowCLK
			end if;
		end if;
end process;

--This select statement selects one of the 7-segment diplay anode(active low) at a time. 
with Val select
	an <= "0111" when "0001",
				  "1011" when "0010",
				  "1101" when "0011",
				  "1110" when "0100",
				  "1111" when others;

--This select statement selects the value of HexVal to the necessary
--cathode signals to display it on the 7-segment
with Val select
	seg <=        NAME(0) when "0001", --NAME contains the pattern for each hex value to be displayed.
				  NAME(1) when "0010", --See below for the conversion
				  NAME(2) when "0011",
				  NAME(3) when "0100",
				  NAME(0) when others;

    HexVal <= MrTemp;
--HexVal<=x"F201";
--Trying to display ABCD on the 7segment display by first sending it to 
--Hex2LED for converting each Hex value to a pattern to be given to the cathode.
		
CONV5: Hex2LED port map (CLK => CLK, X => HexVal(15 downto 12), Y => NAME(0));
CONV6: Hex2LED port map (CLK => CLK, X => HexVal(11 downto 8), Y => NAME(1));
CONV7: Hex2LED port map (CLK => CLK, X => HexVal(7 downto 4), Y => NAME(2));
CONV8: Hex2LED port map (CLK => CLK, X => HexVal(3 downto 0), Y => NAME(3));

--Instantiation section of our mips processor
Program_Counter_map: Program_Counter_module port map (MIPS_CLK_of_PCmodule => Mr_MIPS_CLOCK, RST_PCmodule => RST, PC_out_to_topModule => PC_topModule,
                        PCSrc_of_PCmodule =>PCSrc_topModule,PCBranch_of_PCmodule => PCBranch_topModule, PCplus4 => PCplus4_topModule, 
                        Jump_Raw_Address => Jump_topModule ,  JmpBit => jump_bit_topModule ,Haltbit => Halt_topModule);
 
Instruction_Memory_map: Instruction_Memory_module port map (A => PC_topModule, RD => RD_insmem_topModule);

Resister_File_map: Register_File port map (
RST => RST, MIPS_CLK_RF => Mr_MIPS_CLOCK,  Instr => RD_insmem_topModule, WD3 => WD3_topModule,
WriteData => WriteData_topModule,PCPlus4_RF_read => PCplus4_topModule, JUMP_ADDRESS => Jump_topModule,
PCBranch_RF_out => PCBranch_topModule, OPcode_register_file => opcode_topModule, 
funct_register_file => funct_topModule, SrcA => SrcA_topModule, SrcB => SrcB_topModule,
ALUSrc_RF_read => ALUSrc_topModule,RD1_Feedback => RD1_topModule,  RD2_Feedback => RD2_topModule, 
WE3_RF_read => WE3_RegWrite_topModule,  RegDst_RF_read => RegDst_topModule,
    RF_out0  => RF_ARRAY(0), 
    RF_out1  => RF_ARRAY(1),
    RF_out2  => RF_ARRAY(2),
    RF_out3  => RF_ARRAY(3),
    RF_out4  => RF_ARRAY(4),
    RF_out5  => RF_ARRAY(5),
    RF_out6  => RF_ARRAY(6),
    RF_out7  => RF_ARRAY(7),
    RF_out8  => RF_ARRAY(8),
    RF_out9  => RF_ARRAY(9),
    RF_out10  => RF_ARRAY(10),
    RF_out11  => RF_ARRAY(11),
    RF_out12  => RF_ARRAY(12),
    RF_out13  => RF_ARRAY(13),
    RF_out14  => RF_ARRAY(14),
    RF_out15  => RF_ARRAY(15),
    RF_out16  => RF_ARRAY(16),
    RF_out17  => RF_ARRAY(17),
    RF_out18  => RF_ARRAY(18),
    RF_out19  => RF_ARRAY(19),
    RF_out20  => RF_ARRAY(20),
    RF_out21  => RF_ARRAY(21),
    RF_out22  => RF_ARRAY(22),
    RF_out23  => RF_ARRAY(23),
    RF_out24  => RF_ARRAY(24),
    RF_out25  => RF_ARRAY(25),
    RF_out26  => RF_ARRAY(26),
    RF_out27  => RF_ARRAY(27),
    RF_out28  => RF_ARRAY(28),
    RF_out29  => RF_ARRAY(29),
    RF_out30  => RF_ARRAY(30),
    RF_out31  => RF_ARRAY(31)
); 

Control_Unit_map: Control_Unit port map (opcode => opcode_topModule, funct=>funct_topModule,MemtoReg=>MemtoReg_topModule,MemWrite=>MemWrite_topModule,
                                            ALUSrc=>ALUSrc_topModule,RegDst=>RegDst_topModule, PCSrc => PCSrc_topModule, Zero => Zero_topModule,
                                                RegWrite=>WE3_RegWrite_topModule,JMP => jump_bit_topModule, ALUop => ALUop_topModule,
                                                rs => RD1_topModule, rt => RD2_topModule, Halt => Halt_topModule, branch_Out_debug => branch_Out_debug_topModule,
                                                branch1_BLT_BEQ_BNE_debug => branch1_BLT_BEQ_BNE_debug_topModule); 

ALU_unit_map: ALU port map (SrcA=> SrcA_topModule, SrcB => SrcB_topModule, ALUControl=> ALUop_topModule, 
                             ALUResult => ALU_result_topModule, Zero => Zero_topModule);

Data_Memory_map: datamem port map ( MIPS_CLK_Dem => Mr_MIPS_CLOCK_DMEM,   ALU_result => ALU_result_topModule,
        WD => RD2_topModule, WE => MemWrite_topModule, Result => WD3_topModule, MemtoReg => MemtoReg_topModule ,
        RD_out => RD_topModule, readAddress_out => readAddress_out_topModule, Secret_INPUT_DMEM => Secret_INPUT,
        Secret_input_LOCATION_DMEM => Secret_input_LOCATION, DMEM_rst => RST, lock_value => LOCK_VAL_CONN,

           Dmem_out0   => DMEM_ARRAY(0), 
           Dmem_out1   => DMEM_ARRAY(1),
           Dmem_out2   => DMEM_ARRAY(2),
           Dmem_out3   => DMEM_ARRAY(3),
           Dmem_out4   => DMEM_ARRAY(4),
           Dmem_out5   => DMEM_ARRAY(5),
           Dmem_out6   => DMEM_ARRAY(6),
           Dmem_out7   => DMEM_ARRAY(7),
           Dmem_out8   => DMEM_ARRAY(8),
           Dmem_out9   => DMEM_ARRAY(9),
           Dmem_out10  => DMEM_ARRAY(10),
           Dmem_out11  => DMEM_ARRAY(11),
           Dmem_out12  => DMEM_ARRAY(12),
           Dmem_out13  => DMEM_ARRAY(13),
           Dmem_out14  => DMEM_ARRAY(14),
           Dmem_out15  => DMEM_ARRAY(15),
           Dmem_out16  => DMEM_ARRAY(16),
           Dmem_out17  => DMEM_ARRAY(17),
           Dmem_out18  => DMEM_ARRAY(18),
           Dmem_out19  => DMEM_ARRAY(19),
           Dmem_out20  => DMEM_ARRAY(20),
           Dmem_out21  => DMEM_ARRAY(21),
           Dmem_out22  => DMEM_ARRAY(22),
           Dmem_out23  => DMEM_ARRAY(23),
           Dmem_out24  => DMEM_ARRAY(24),
           Dmem_out25  => DMEM_ARRAY(25),
           Dmem_out26  => DMEM_ARRAY(26),
           Dmem_out27  => DMEM_ARRAY(27),
           Dmem_out28  => DMEM_ARRAY(28),
           Dmem_out29  => DMEM_ARRAY(29),
           Dmem_out30  => DMEM_ARRAY(30),
           Dmem_out31  => DMEM_ARRAY(31),
           Dmem_out32  => DMEM_ARRAY(32) 
     );
                                         
with switch_DATA_input(15 downto 0)
select MrInformation<= PC_topModule                                             when x"0000",
                       RD_insmem_topModule                                      when x"0001", 
          "0000000000000000000000000000000" & WE3_RegWrite_topModule            when x"0002",
                       "00000000000000000000000000" & opcode_topModule          when x"0003",
                       "00000000000000000000000000" & funct_topModule           when x"0004",
                                         "000000" & Jump_topModule              when x"0005",
                       "00000000000000000000000000000" & ALUop_topModule        when x"0006",
                                                               RD1_topModule    when x"0007",
                                                               RD2_topModule    when x"0008",                       
                                                               SrcA_topModule   when x"0009",
                                                               SrcB_topModule   when x"000A",
                       "0000000000000000000000000000000" & MemtoReg_topModule   when x"000B",
                       "0000000000000000000000000000000" & MemWrite_topModule   when x"000C",
     "0000000000000000000000000000000" & ALUSrc_topModule                       when x"000D",
            "0000000000000000000000000000000" & RegDst_topModule                when x"000E",
               "0000000000000000000000000000000" & WE3_RegWrite_topModule       when x"000F",
                  "0000000000000000000000000000000" & jump_bit_topModule        when x"0010",
                        ALU_result_topModule                                    when x"0011",
                       "0000000000000000000000000000000" & Zero_topModule       when x"0012",
                                                        WD3_topModule           when x"0013",
                                                        
                 "0000000000000000000000000000000" & Mr_MIPS_CLOCK                when x"0014", -- 
                 "0000000000000000000000000000000" & Mr_ConfigCLK                 when x"0015", -- clock config
                 "0000000000000000000000000000000" & AutoSlow_CLOCK               when x"0016", -- slow clock 
             --  "0000000000000000000000000000000" & AutoFast_CLK                 when x"0017", -- fast clk
                 "0000000000000000000000000000000" & AutoPeak_CLK                 when x"0018", -- peak clk
                "0000000000000000000000000000000" & AutoFast_CLK                 when x"0019", -- fast clk
                 "0000000000000000000000000000000" & MANUAL_CLOCK                 when x"001A", --    
                    "0000000000000000000000000000" & locked_Clk_Mode              when x"001B", --    
                 "0000000000000000000000000000000" & LOCK_VAL_CONN              when x"001C", --    
                           
                           "000000000000000000000000" & state_Val                 when x"001F", -- state val
 
                                                         DMEM_ARRAY(0)          when x"F000",
                                                         DMEM_ARRAY(1)          when x"F001",
                                                         DMEM_ARRAY(2)          when x"F002",
                                                         DMEM_ARRAY(3)          when x"F003",
                                                         DMEM_ARRAY(4)          when x"F004",
                                                         DMEM_ARRAY(5)          when x"F005",
                                                         DMEM_ARRAY(6)          when x"F006",
                                                         DMEM_ARRAY(7)          when x"F007",
                                                         DMEM_ARRAY(8)          when x"F008",
                                                         DMEM_ARRAY(9)          when x"F009",
                                                         DMEM_ARRAY(10)          when x"F00A",
                                                         DMEM_ARRAY(11)          when x"F00B",
                                                         DMEM_ARRAY(12)          when x"F00C",
                                                         DMEM_ARRAY(13)          when x"F00D",
                                                         DMEM_ARRAY(14)          when x"F00E",
                                                         DMEM_ARRAY(15)          when x"F00F",
                                                         DMEM_ARRAY(16)          when x"F010",
                                                         DMEM_ARRAY(17)          when x"F011",
                                                         DMEM_ARRAY(18)          when x"F012",
                                                         DMEM_ARRAY(19)          when x"F013",
                                                         DMEM_ARRAY(20)          when x"F014",
                                                         DMEM_ARRAY(21)          when x"F015",
                                                         DMEM_ARRAY(22)          when x"F016",
                                                         DMEM_ARRAY(23)          when x"F017",
                                                         DMEM_ARRAY(24)          when x"F018",
                                                         DMEM_ARRAY(25)          when x"F019",
                                                         DMEM_ARRAY(26)          when x"F01A",
                                                         DMEM_ARRAY(27)          when x"F01B",
                                                         DMEM_ARRAY(28)          when x"F01C",
                                                         DMEM_ARRAY(29)          when x"F01D",
                                                         DMEM_ARRAY(30)          when x"F01E",
                                                         DMEM_ARRAY(31)          when x"F01F",
 
                                                         RF_ARRAY(0)           when x"FF00",
                                                         RF_ARRAY(1)           when x"FF01",
                                                         RF_ARRAY(2)           when x"FF02",
                                                         RF_ARRAY(3)           when x"FF03",
                                                         RF_ARRAY(4)           when x"FF04",
                                                         RF_ARRAY(5)           when x"FF05",
                                                         RF_ARRAY(6)           when x"FF06",
                                                         RF_ARRAY(7)           when x"FF07",
                                                         RF_ARRAY(8)           when x"FF08",
                                                         RF_ARRAY(9)           when x"FF09",
                                                         RF_ARRAY(10)          when x"FF0A",
                                                         RF_ARRAY(11)          when x"FF0B",
                                                         RF_ARRAY(12)          when x"FF0C",
                                                         RF_ARRAY(13)          when x"FF0D",
                                                         RF_ARRAY(14)          when x"FF0E",
                                                         RF_ARRAY(15)          when x"FF0F",
                                                         RF_ARRAY(16)          when x"FF10",
                                                         RF_ARRAY(17)          when x"FF11",
                                                         RF_ARRAY(18)          when x"FF12",
                                                         RF_ARRAY(19)          when x"FF13",
                                                         RF_ARRAY(20)          when x"FF14",
                                                         RF_ARRAY(21)          when x"FF15",
                                                         RF_ARRAY(22)          when x"FF16",
                                                         RF_ARRAY(23)          when x"FF17",
                                                         RF_ARRAY(24)          when x"FF18",
                                                         RF_ARRAY(25)          when x"FF19",
                                                         RF_ARRAY(26)          when x"FF1A",
                                                         RF_ARRAY(27)          when x"FF1B",
                                                         RF_ARRAY(28)          when x"FF1C",
                                                         RF_ARRAY(29)          when x"FF1D",
                                                         RF_ARRAY(30)          when x"FF1E",
                                                         RF_ARRAY(31)          when x"FF1F",
                                                         
                                                           x"FFFFFFFF"          when others;  
                                                           
                                                                                              
     
--     DEB_LOCK_DATAa <= LOCK_DATA;
--     DEB_LOCK_DATAb <= LOCK_DATA;
--     DEB_LOCK_DATAc <= DEB_LOCK_DATAa and DEB_LOCK_DATAb;
--     DEB_LOCK_DATAd <= DEB_LOCK_DATAc;
--     DEB_LOCK_DATAe <= DEB_LOCK_DATAc;
--     DEB_LOCK_DATAf <= DEB_LOCK_DATAd and DEB_LOCK_DATAe;
--     DEB_LOCK_DATAg <= DEB_LOCK_DATAf;
--     DEB_LOCK_DATAh <= DEB_LOCK_DATAf;
--     DEB_LOCK_DATAi <= DEB_LOCK_DATAg and DEB_LOCK_DATAh;
--     DEB_LOCK_DATAj <= DEB_LOCK_DATAi;
--     DEB_LOCK_DATA <= DEB_LOCK_DATAj;
    
     
     
--     DEB_INPUT_VALID_a <= INPUT_VALID;
--     DEB_INPUT_VALID_b <= INPUT_VALID; 
--     DEB_INPUT_VALID_c <= DEB_INPUT_VALID_a and DEB_INPUT_VALID_b;
--     DEB_INPUT_VALID_d <= DEB_INPUT_VALID_c;
--     DEB_INPUT_VALID_e <= DEB_INPUT_VALID_c;
--     DEB_INPUT_VALID_f <= DEB_INPUT_VALID_d and DEB_INPUT_VALID_e;
--     DEB_INPUT_VALID_g <= DEB_INPUT_VALID_f;
--     DEB_INPUT_VALID_h <= DEB_INPUT_VALID_f;
--     DEB_INPUT_VALID_i <= DEB_INPUT_VALID_g and DEB_INPUT_VALID_h;
--     DEB_INPUT_VALID_j <= DEB_INPUT_VALID_i;
--     DEB_INPUT_VALID_k <= DEB_INPUT_VALID_i;
--     DEB_INPUT_VALID_l <= DEB_INPUT_VALID_j and DEB_INPUT_VALID_l;
--     DEB_INPUT_VALID <= DEB_INPUT_VALID_l;

--Mr_MIPS_CLOCK <= RHITVIKs_Clock;--when state is ready and we need to 
led <= switch_DATA_input;               
Fetched_instruction <= RD_insmem_topModule;                                                                                         
MrTemp <= MrInformation(15 downto 0) when SEL_MSB = '0' else MrInformation(31 downto 16);
  
Secret_INPUT <= switch_DATA_input (7 downto 0);
Secret_input_LOCATION <= switch_DATA_input (15 downto 8);
    
with state select
state_Val <= x"00" when ST_IDLE,
             x"01" when ST_INPUT_Variables,
             x"02" when ST_Processor_Settings,
             x"03" when ST_RUN_Processor,
             x"04" when others; 

  PROCESS(RST, INPUT_VALID)	
     BEGIN
       IF(RST='1') THEN
       state<=ST_IDLE;
       ELSIF(INPUT_VALID'EVENT AND INPUT_VALID='1') THEN
           CASE state IS
              WHEN ST_IDLE  => -- ya fir ST_READY
                 -- state_Val <= x"00";
                  IF(switch_DATA_input = x"FF05") THEN  state <= ST_INPUT_Variables; END IF;                 
              
              WHEN ST_INPUT_Variables =>
                  -- state_Val <= x"01";
                  IF(switch_DATA_input = x"FF06") then state <= ST_Processor_Settings; END IF;
 
              WHEN ST_Processor_Settings=> 
                   --state_Val <= x"02";
                  IF(switch_DATA_input = x"FF07") THEN  state <= ST_RUN_Processor; END IF;
                  
              --WHEN ST_RUN_Processor=>
                  --state_Val <= x"03";
             WHEN others =>
                  gar <= '1'; --state_Val <= x"04";
          END CASE;
          
        END IF;
  END PROCESS;

  PROCESS(RST, LOCK_DATA)
    BEGIN
      IF(RST = '1') THEN
      locked_Clk_Mode <= "0000";
      locked_processor_operation <= "0000";      --DMEM_INPUT_enable <= '0';
       --SET EVERY SETTING TO DEFAULT VAL
      
      ELSIF(LOCK_DATA'EVENT AND LOCK_DATA='1') THEN
            IF (STATE = ST_IDLE) THEN
            rhitvik <= not rhitvik;
            --disable all inputs
            -- DO SOMETHING ... MAYBE WAIT FOR THE STATE TO BECOME SOMETHING
            ELSIF (STATE = ST_Processor_Settings) THEN
                locked_Clk_Mode <= Clk_Mode;
                -- TAKE INPUT FOR PROCESSOR SETTINGS
                locked_processor_operation <= processor_operation;
                
--                if    (Clk_Mode = 0) then Mr_ConfigCLK <= AutoSlow_CLOCK; 
--                elsif (Clk_Mode = 1) then Mr_ConfigCLK <= AutoFast_CLK;
--                elsif (Clk_Mode = 2) then Mr_ConfigCLK <= AutoPeak_CLK;
--                elsif (Clk_Mode = 3) then Mr_ConfigCLK <= MANUAL_CLOCK;
--                end if; 
            
            ELSIF (STATE = ST_INPUT_Variables) THEN rhitvik <= not rhitvik;
            -- TAKE INPUT FOR UKEY AND SKEY
           -- DMEM_INPUT_enable <= '1';
            
            ELSIF (STATE = ST_RUN_Processor) THEN rhitvik <= not rhitvik;
            -- DISABLE INPUTS AND START RUNNING THE PROCESSOR
            --DMEM_INPUT_enable <= '0';
            --START_PROCESSOR <= '1';
            
            --ELSIF (STATE = ST_READY) THEN
            --MAYBE DO SOMETHING
            END IF; 
      END IF;
    END PROCESS;
   
   
--    signal AutoSlow_CLOCK: std_logic:='0';
--    signal AutoFast_CLK: std_logic:='0';
--    signal AutoPeak_CLK: std_logic:='0';

   Mr_MIPS_CLOCK_DMEM <= LOCK_DATA when STATE = ST_INPUT_Variables else Mr_MIPS_CLOCK;
   LOCK_VAL_CONN <= '1' when STATE = ST_INPUT_Variables else '0';--muxes the dmem back-channel
   Mr_MIPS_CLOCK <= Mr_ConfigCLK when STATE = ST_RUN_Processor else '0';
   
   with switch_DATA_input(2 downto 0) select 
   Clk_Mode <= "0001" when "001",
               "0010" when "010",
               "0011" when "011",
               "0100" when "100",
               "0000" when others;
                
   with switch_DATA_input(5 downto 3) select
   Processing_Mode <= 0 when "000",
                      1 when "001",
                      2 when "010",
                      3 when "011",
                      4 when "100",
                      5 when others;
  
  with locked_Clk_Mode select
  Mr_ConfigCLK <= AutoSlow_CLOCK when "0001",
                  AutoFast_CLK   when "0010",
                  AutoPeak_CLK   when "0011", 
                  MANUAL_CLOCK   when "0100",
                           '0'   when others; 
  
  with Processing_Mode select
    processor_operation <=  "0000" when 0,
                            "0001" when 1,
                            "0010" when 2,
                            "0011" when 3,
                            "0100" when 4,
                            "0000" when others;
    
--if    (Processing_Mode = 0) then processor_operation <= 0; 
--elsif (Processing_Mode = 1) then processor_operation <= 1; 
--elsif (Processing_Mode = 2) then processor_operation <= 2; 
--elsif (Processing_Mode = 3) then processor_operation <= 3; 
--elsif (Processing_Mode = 4) then processor_operation <= 4;
--end if; 
  
--  case Clk_Mode(3 downto 0) is
--    when "0001" => Mr_ConfigCLK <= AutoSlow_CLOCK;         
--    when "0010" => Mr_ConfigCLK <= AutoFast_CLK;         
--    when "0011" => Mr_ConfigCLK <= AutoPeak_CLK;         
--    when "0100" => Mr_ConfigCLK <= MANUAL_CLOCK;         
--    when others => Mr_ConfigCLK <= '0';
--    end case;
 
end Behavioral;
