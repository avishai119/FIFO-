library WORK;
library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;

entity fifo_tb is 
end entity fifo_tb;

architecture arc_fifo_tb of fifo_tb is 

constant clk_period : time :=  10.00 ns; -- for clk

-- for open the file

constant	file_loc   	: string := "C:\fifo\";  
constant	file_name1 	: string := "file1.txt";
constant	file_name2	: string := "file2.txt";

constant	space_2         : string :="    "; -- write space in the file

constant 	last_time_input : time := 5000 ns ;	--last the input time in the file input (file number one).

constant 	godel           : positive := 7 ; -- need to be like (size word -1 = godel) 


signal empty_s : std_logic;
signal full_s : std_logic;
signal clk_s : std_logic := '0';
signal rst_s : std_logic := '1';
signal re_en_s : std_logic;
signal we_en_s : std_logic;
signal read_data_s : std_logic_vector(godel downto 0);
signal write_data_s : std_logic_vector(godel downto 0);
-- signal counter_data : integer := '0';


component fifo is
    generic (
	size_log2 : positive := 3;
	SIZE_word : positive := 8
	);
	port (	
	empty      : out std_logic;
	full       : out std_logic;
	clk        : in std_logic;
	rst        : in std_logic;
	re_en      : in std_logic;
	we_en	   : in  std_logic;
	read_data  : out std_logic_vector(SIZE_word-1 downto 0);
	write_data : in std_logic_vector(SIZE_word-1 downto 0)
	);
	end component fifo;
begin

	
  -- FIFO_INST : FIFO

  uut_fifo  :   fifo  generic map (
          size_log2 => 3,
	  SIZE_word => 8 )
    port map (
        	   empty => empty_s,
       		   full  => full_s,
	  	   clk   => clk_s,
	  	   rst   => rst_s,
	           re_en => re_en_s,
    		   we_en => we_en_s,
	       read_data => read_data_s,
	      write_data => write_data_s
     );
	 
	-- CLK process
   process is
   begin
		clk_s  <= '0';
		wait for clk_period/2;
		clk_s  <= '1';
		wait for clk_period/2;
   end process;	 
   
   --pull down the rst
   rst_s <= '0' after 2 ns;
	 
	 
-- use file	 
  process is
  file file1 :text;
  variable fopen_f1 : file_open_status;
  variable read_enable :std_logic;
  variable write_enable : std_logic;
  variable data_in : std_logic_vector(godel downto 0);
  variable file1_line : line;
  variable time1 : time;
  variable re_enable_1 : std_logic;
  variable we_enable_1 : std_logic;
  variable read_status : boolean;
  variable write_data_1 : std_logic_vector(godel downto 0);
  begin
  file_open (fopen_f1,file1,file_loc & file_name1, read_mode); -- check file_1 is  open
	assert(fopen_f1 = open_ok) 
		report "file1- input not open" 
	severity failure;
 
	while not endfile(file1) loop -- until the file end.
		readline(file1,file1_line); 
		read(file1_line,time1);  		-- read time
		read(file1_line,re_enable_1); 	-- read read enable
		read(file1_line,we_enable_1);	-- read write enable	
		read(file1_line,write_data_1);	-- read data
		if(NOW < time1) then		
			wait for (time1 - now);	-- wait for time
		end if; 
		re_en_s <= re_enable_1;		 	-- put into signals
		we_en_s <= we_enable_1;
		write_data_s <= write_data_1;
	end loop;
	file_close(file1);				-- close file
	
  end process;
  
process is		-- write to file2 from file1
  file file2 :text;
  variable fopen_f2 : file_open_status; 
  variable data_out : std_logic_vector(godel downto 0);
  variable write_line : line;
  variable full_2 : std_logic;
  variable empty_2 : std_logic;
  begin
  file_open(fopen_f2,file2,file_loc & file_name2,write_mode); -- check file_2 is  open
	assert(fopen_f2 = open_ok) 
		report "file2 - output not open" 
	severity failure;
	while (NOW < last_time_input  ) loop
		wait until falling_edge(clk_s); -- wait for falling_edge after the rising_edge , and take the value and write to file_output (file2).
			data_out := read_data_s; -- put signals into variables
			full_2 := full_s;
			empty_2 := empty_s;
			write(write_line, full_2); -- write full
			write(write_line,space_2); 
			write(write_line,empty_2); -- write empty
         	write(write_line,space_2);
			write(write_line,data_out); -- write data 
			writeline(file2,write_line);
	end loop;
	
	file_close(file2);
 
   end process;

 
  end architecture arc_fifo_tb;