# VGA + PingPong
乒乓球遊戲 + VGA
  
延續上次的乒乓球遊戲，遊戲狀態除了顯示在FPGA板上的LED之外，也透過VGA介面同步顯示於螢幕上。  
  
解析度採用640x480@60Hz，其像素頻率為25.175MHz，程式中有關VGA的程式所使用的時脈必須做除頻，FPGA板本身的時脈為100MHz，透過除頻程式除4即可得到接近理想值的25MHz。  
  
在乒乓球遊戲的程式中加入兩個process：  
  
VGA_Count：VGA時脈掃描計數器，VGA先掃描水平像素再掃描垂直像素。  
水平時脈總共有800個clock (Visible area: 640 + Front porch: 16 + Sync pulse: 96 + Back porch: 48)，垂直時脈總共有525個clock (Visible area: 480 + Front porch: 10 + Sync pulse: 2 + Back porch: 33)。  
實際能顯示畫面的部分是從Sync pulse + Back porch = VISIBLE_START開始，程式中為了讓設定圖形位置能直覺一些，將掃描counter的值減去其對應的VISIBLE_START來把基準點調整到0。  
  
VGA_Display：設定顯示的畫面元素，我在上面畫了背景、球檯，並且透過for迴圈來做到球體出現與LED同步，再透過4bit的RGB值來設定元素顏色。  
我們平常都習慣使用8bit的RGB值，所以我使用工具網站來做轉換，才將球檯的棕色正確顯示出來。  

VGA畫面設計：
![IMG_1999](https://github.com/user-attachments/assets/12f0bf5b-5cbc-412a-8d6c-f3c0dae8933b)  

Demo影片：https://drive.google.com/file/d/1-e8io-AeQbsUZK66NtU9cvIqXFYBEO-g/view?usp=drive_link
