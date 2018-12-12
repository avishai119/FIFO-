library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity  fifo is
generic (
size_log2: positive := 3 ;
SIZE_word : positive := 8
);
port (	
empty : out std_logic;
full : out std_logic;
clk : in std_logic;
rst : in std_logic;
re_en : in std_logic;
we_en : in  std_logic;
read_data : out std_logic_vector(SIZE_word-1 downto 0);
write_data : in std_logic_vector(SIZE_word-1 downto 0)
);
end fifo;

architecture arc_fifo of fifo is 

constant size_fifo : positive := 2**size_log2; -- must be 2^valuve

type T_FIFO_1 IS array (size_fifo-1 downto 0) of std_logic_vector(sizE_word-1 downto 0); 


signal fifo_1 : T_fifo_1 := (others => (others => '0'));
signal we_pointer : unsigned(size_log2 downto 0);
signal re_pointer : unsigned(size_log2 downto 0);


begin


process(clk) is-- check for empty or full	
begin
	if rising_edge(clk) then

		if((re_pointer(re_pointer'left) /= we_pointer(we_pointer'left)) and  (re_pointer(re_pointer'left-1 downto 0) = we_pointer(we_pointer'left-1 downto 0))) then
			empty <= '0';
			full <= '1';

		elsif ((re_pointer(re_pointer'left) = we_pointer(we_pointer'left)) and  (re_pointer(re_pointer'left-1 downto 0) = we_pointer(we_pointer'left-1 downto 0))) then

			empty <= '1';
			full <= '0';
		else
			full <= '0';
			empty <= '0';
		end if;	
	
	end if;

end process;

process(clk,rst) is --  read and write + rst
begin

	if rst = '1' then 

		re_pointer <= (others => '0');
		we_pointer <= (others => '0');

	elsif rising_edge(clk) then

		if re_en ='1' then 
     
			read_data <=fifo_1(to_integer(re_pointer(size_log2-1 downto 0)));
			re_pointer <= re_pointer+1;
		  
		elsif we_en ='1' then 
	
			fifo_1(to_integer(we_pointer(size_log2-1 downto 0))) <= write_data;
			we_pointer <= we_pointer+1;
		end if;


	end if;

end process;



end architecture arc_fifo;