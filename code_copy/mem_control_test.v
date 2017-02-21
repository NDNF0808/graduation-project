`timescale 1ns/1ps
`include "./mem_head.v"
`include "./mem_control.v"
module test;
			reg  tx,  clk, reset;//输入时钟与复位信号
           reg  uart_memctrl_read_ready; //buffer传输给mem的开始信号
           reg [`WordNumberBit]  word_number1;
           wire          memctrl_mem_write_start; //memcontrol传输给mem写的开始信号
          wire  [`WordWidth] memctrl_mem_write_data;//buffer传输给mem的写的数据
          wire               memctrl_mem_read;  
initial
begin
          clk = 1'b0;//注意时钟，第一个上升沿是在4个单位时，取时钟第二个上升沿才是进入idle状态的时间，此时线传输控制信号rw,ready
          word_number1 = 'd4;
          reset = 1'b0;
          #2 reset = ~reset;
          repeat(1000000)
            begin
                #50 clk = ~clk;
                
            end 
end
initial
  begin
      #852 tx = 1'b0;
    #26100 tx = 1'b1;
    repeat (7)
      begin
      #26100 tx = ~tx;
      end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
        # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
        # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      # 26200 tx = 1'b1;
      repeat(7)
        begin
            # 26100 tx = ~ tx;
        end
      
      
end
mem_control mem_control(tx,clk,reset,uart_memctrl_read_ready,word_number1,memctrl_mem_write_start,memctrl_mem_write_data,memctrl_mem_read);
initial
begin
	$dumpfile ("mem_control.vcd");
	$dumpvars(0,test);
end
endmodule // test
