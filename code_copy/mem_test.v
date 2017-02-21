`timescale 1ns/1ps
`include "./mem.v"
module test;
    reg  [`BusAddrWidth] uart_mem_addr;  //输入要读或者写的地址此处的地址是块的首地址或者IO地址由uart传来
    reg [`WordNumberBit] word_number1;//输入uart传来的字个数信号

		reg                  memctrl_mem_write_start, clk, reset; //检测到memctrl_mem_write_start之后进入接收数据写mem状态
		reg [`WordWidth]     memctrl_mem_write_data; //输入要写的字
    reg                  uart_mem_read; //输入读信号
		wire [`WordWidth]    mem_memctrl_read_data ; //输出要读取的字
    wire                 mem_memctrl_write_ready; //mem传给memctrl的写准备信号
    initial
      begin
          clk = 1'b0;//注意时钟，第一个上升沿是在4个单位时，取时钟第二个上升沿才是进入idle状态的时间，此时线传输控制信号rw,ready
          reset = 1'b0;
          #2 reset = ~reset;
          repeat(20)
            begin
                #50 clk = ~clk;
                
            end 
      end
 initial
   begin
       uart_mem_addr = 'd4;
     /*  #152 memctrl_mem_write_start <= `MEMCTRL_MEM_WRITE_START_ENABLE;
       # 200 memctrl_mem_write_data <= 'd0;
       # 100 memctrl_mem_write_data <= 'd1;
       #100 memctrl_mem_write_data <= 'd2;
       #100 memctrl_mem_write_data <= 'd3;
   end // initial begin*/
       uart_mem_read = `UART_MEM_READ_ENABLE;
       word_number1 = 'd4;
       
   end // initial begin
    
       
  //  mem mem(bus_write_addr1,word_number2,memctrl_mem_write_start,clk, reset,memctrl_mem_write_data,memctrl_mem_read);
       mem mem(uart_mem_addr,word_number1,memctrl_mem_write_start,clk,reset,memctrl_mem_write_data,uart_mem_read,mem_memctrl_read_data,mem_memctrl_write_ready);
       
    initial
      begin
          $dumpfile("mem.vcd");
          $dumpvars(0,test);
          
      end
endmodule
 
      
    
    