library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity VGA_PingPong is
    Port (
        i_clk       : in STD_LOGIC;
        i_rst       : in STD_LOGIC;
        i_swL       : in STD_LOGIC;
        i_swR       : in STD_LOGIC;
        o_hsync     : out STD_LOGIC;
        o_vsync     : out STD_LOGIC;
        o_red       : out STD_LOGIC_VECTOR (3 downto 0);
        o_green     : out STD_LOGIC_VECTOR (3 downto 0);
        o_blue      : out STD_LOGIC_VECTOR (3 downto 0);
        o_led       : out STD_LOGIC_VECTOR (7 downto 0)
    );
end VGA_PingPong;

architecture Behavioral of VGA_PingPong is

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

    signal divi_cnt          : STD_LOGIC_VECTOR(24 downto 0);
    signal vga_clk           : STD_LOGIC;
    signal pp_clk            : STD_LOGIC;
    signal h_count           : integer range 0 to 799 := 0;
    signal v_count           : integer range 0 to 524 := 0;
    signal x, y              : integer range -1000 to 1000;
    signal ball_x            : integer := 120; --會變
    signal ball_y            : integer := 240;
    
    type STATE_TYPE is (MovingR, MovingL, Lwin, Rwin);
    signal state             : STATE_TYPE;
    signal prev_state        : STATE_TYPE;
    signal led_r             : STD_LOGIC_VECTOR (7 downto 0);
    signal scoreL            : STD_LOGIC_VECTOR (3 downto 0);
    signal scoreR            : STD_LOGIC_VECTOR (3 downto 0);

begin
    CLK_DIV:process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            divi_cnt <= (others => '0');
        elsif rising_edge(i_clk) then
            divi_cnt <= divi_cnt + 1;
        end if;
    end process;
    
    vga_clk <= divi_cnt(1);
    pp_clk  <= divi_cnt(23);
    o_led   <= led_r;
    
    PP_FSM:process(i_clk, i_rst, i_swL, i_swR, led_r)
    begin
        if i_rst='1' then
            state <= MovingR;
        elsif i_clk'event and i_clk='1' then
             case state is
                when MovingR => --S0 右移中
                    if (led_r < "00000001") or (led_r > "00000001" and i_swR = '1') then
                        state <= Lwin;
                    elsif led_r(0)='1' and i_swR ='1' then --右打到 then
                        state <= MovingL;
                    end if;
                when MovingL => --S1 左移中
                    if (led_r = "00000000") or (led_r < "10000000" and i_swL = '1') then
                        state <= Rwin;
                    elsif led_r(7)='1' and i_swL ='1' then --左打到 then
                       state <= MovingR;
                    end if;
                when Lwin =>    --S3 
                    if i_swL ='1' then --左發球
                       state <= MovingR;
                 end if;
                when Rwin =>    --S2
                    if i_swR ='1' then --右發球
                       state <= MovingL;
                    end if;
                when others => 
                    null;
            end case;
        end if;
    end process;

	PP_LED:process(pp_clk, i_rst, state, prev_state)
	begin
		if i_rst='1' then
			led_r <= "10000000";
		elsif pp_clk'event and pp_clk='1' then
			prev_state <= state;
			case state is
				when MovingR => --S0 右移中
					if (prev_state = Lwin) then
						led_r <= "10000000";
					elsif (prev_state = MovingL or prev_state = MovingR) then
						led_r(7         ) <= '0';
						led_r(6 downto 0) <= led_r(7 downto 1); --led_r >> 1
					end if;          
				when MovingL => --S1 左移中
					if (prev_state = Rwin) then
						led_r <= "00000001";
					elsif (prev_state = MovingR or prev_state = MovingL) then            
						led_r(7 downto 1) <= led_r(6 downto 0); --led_r << 1            
						led_r(         0) <= '0';
					end if;
				when Lwin =>    --S3 
					if (prev_state = MovingR) then
						led_r <= "11110000";
					end if;
				when Rwin =>    --S2
					if (prev_state = MovingL) then
						led_r <= "00001111";
					end if;
				when others => 
					null;
			end case;    
		end if;
	end process;
	
	PP_score_L:process(pp_clk, i_rst, state)
	begin
		if i_rst='1' then
			scoreL <= "0000";
		elsif pp_clk'event and pp_clk='1' then
			case state is
				when MovingR => --S0 右移中
					null;
				when MovingL => --S1 左移中
					null;
				when Lwin =>    --S3 
					if (prev_state = MovingR) then
				        scoreL <= scoreL + '1';
					end if;
				when Rwin =>    --S2
					null;
				when others => 
					null;
			end case;    
		end if;
	end process;
	
	PP_score_R:process(pp_clk, i_rst, state)
	begin
		if i_rst='1' then
			scoreR <= "0000";
		elsif pp_clk'event and pp_clk='1' then
			case state is
				when MovingR => --S0 右移中
					null;
				when MovingL => --S1 左移中
					null;
				when Lwin =>    --S3 
					null; 
				when Rwin =>    --S2
					if (prev_state = MovingL) then
						scoreR <= scoreR + '1';
					end if;
				when others => 
					null;
			end case;    
		end if;
	end process;

    VGA_Count:process(vga_clk, i_rst)
    begin
        if i_rst = '1' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(vga_clk) then
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

    o_hsync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    o_vsync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    x <= h_count - H_VISIBLE_START;
    y <= v_count - V_VISIBLE_START;

    VGA_Display:process(vga_clk, i_rst)
    begin
        if i_rst = '1' then
            o_red   <= (others => '0');
            o_green <= (others => '0');
            o_blue  <= (others => '0');

        elsif rising_edge(vga_clk) then
            o_red   <= "0000";
            o_green <= "0000";
            o_blue  <= "0000";

            if (x >= 0 and x < H_ACTIVE_VIDEO and y >= 0 and y < V_ACTIVE_VIDEO) then

                if (x >= 0 and x < 640 and y >= 0 and y < 480) then --背景
                    o_red <= "0000";
                    o_green <= "0000";
                    o_blue <= "1111";
                end if;
                            
                if (x >= 90 and x < 570 and y >= 300 and y < 350) then --球檯
                    o_red <= "1010";
                    o_green <= "0010";
                    o_blue <= "0010";
                end if;

                for i in 0 to 7 loop
                    if ((x - (120 + i*60))*(x - (120 + i*60)) + (y - 240)*(y - 240) <= 30*30) then --球
                        if (led_r(7 - i) = '1') then
                            o_red <= "1111";  --顯示紅色
                            o_green <= "0000";
                            o_blue <= "0000";
                        else
                            o_red <= "1111"; --顯示白色
                            o_green <= "1111";
                            o_blue <= "1111";
                        end if;
                    end if;
                end loop; 
                                             
            end if;
        end if;
    end process;
end Behavioral;
