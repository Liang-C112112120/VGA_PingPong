library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity VGA is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        red       : out STD_LOGIC_VECTOR (3 downto 0);
        green     : out STD_LOGIC_VECTOR (3 downto 0);
        blue      : out STD_LOGIC_VECTOR (3 downto 0)
    );
end VGA;

architecture Behavioral of VGA is

    constant H_SYNC_CYCLES   : integer := 96;
    constant H_BACK_PORCH    : integer := 48;
    constant H_ACTIVE_VIDEO  : integer := 640;
    constant H_FRONT_PORCH   : integer := 16;
    
    constant V_SYNC_CYCLES   : integer := 2;
    constant V_BACK_PORCH    : integer := 33;
    constant V_ACTIVE_VIDEO  : integer := 480;
    constant V_FRONT_PORCH   : integer := 10;

    constant H_VISIBLE_START : integer := H_SYNC_CYCLES + H_BACK_PORCH; -- 144
    constant V_VISIBLE_START : integer := V_SYNC_CYCLES + V_BACK_PORCH; -- 35

    signal divclk : STD_LOGIC_VECTOR(1 downto 0);
    signal fclk   : STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;
    signal v_count : integer range 0 to 524 := 0;
    signal x, y : integer range -1000 to 1000;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            divclk <= (others => '0');
        elsif rising_edge(clk) then
            divclk <= divclk + 1;
        end if;
    end process;

    fclk <= divclk(1);

    process(fclk, rst)
    begin
        if rst = '1' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(fclk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    hsync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    vsync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    x <= h_count - H_VISIBLE_START;
    y <= v_count - V_VISIBLE_START;

    process(fclk, rst)
    begin
        if rst = '1' then
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '0');

        elsif rising_edge(fclk) then
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";

            if (x >= 0 and x < H_ACTIVE_VIDEO and y >= 0 and y < V_ACTIVE_VIDEO) then

                if (x >= 0 and x < 640 and y >= 0 and y < 480) then --背景
                    red <= "0000";
                    green <= "0000";
                    blue <= "1111";
                end if;
                            
                if (x >= 90 and x < 570 and y >= 300 and y < 350) then --球檯
                    red <= "1010";
                    green <= "0010";
                    blue <= "0010";
                end if;
                
                if ((x - 120)*(x - 120) + (y - 240)*(y - 240) <= 30*30) then --球1
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
                
                if ((x - 180)*(x - 180) + (y - 240)*(y - 240) <= 30*30) then --球2
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;

                if ((x - 240)*(x - 240) + (y - 240)*(y - 240) <= 30*30) then --球3
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
                
                if ((x - 300)*(x - 300) + (y - 240)*(y - 240) <= 30*30) then --球4
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
                
                if ((x - 360)*(x - 360) + (y - 240)*(y - 240) <= 30*30) then --球5
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;              
                
                if ((x - 420)*(x - 420) + (y - 240)*(y - 240) <= 30*30) then --球6
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
                
                if ((x - 480)*(x - 480) + (y - 240)*(y - 240) <= 30*30) then --球7
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;
                
                if ((x - 540)*(x - 540) + (y - 240)*(y - 240) <= 30*30) then --球8
                    red <= "1111";
                    green <= "1111";
                    blue <= "1111";
                end if;

            end if;
        end if;
    end process;
end Behavioral;
