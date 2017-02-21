`timescale 1ns/1ps
`include "./uart.v"
//`include "./uart_control.v"
//`include "D:/IFMRT/graduation-project/code/uart_control.v"
module test;
 reg as, rw, master_uart_write_ready, clk,reset;//接收主控发来的选通信号，
                     //读写信号，准备写信号，时钟，复位信号
                     reg  [`BusDataWidth]  master_uart_write_data;//接收主控发来的数据
                     reg [`BusAddrWidth]  master_uart_addr; //接收主控发来的地址
                     reg  [`WordNumberBit] word_number;//总线仲裁器传来的需要传输的字的个数
                     wire  [`BusAddrWidth] uart_mem_addr; //将主控发来的地址再传给memory
                     wire             tx,bus_error;//如果基偶校验失败将bus_error传给主控
    wire [`WordNumberBit]             word_number1;
      //tx是传给mem控制器串行数据
                  wire uart_memctrl_read_ready ;//传给mem control的读准备信号
    initial
      begin
          clk <= 1'b0;//注意时钟，第一个上升沿是在4个单位时，取时钟第二个上升沿才是进入idle状态的时间，此时线传输控制信号rw,ready
          reset <= 1'b0;
          #2 reset = ~reset;
          repeat(1000000)
            begin
                #50 clk <= ~clk;
                
            end 
      end
    initial
      begin
          fork
          #152 word_number <= 'd4;
        #152  rw <= `RW_WRITE;
        #152   master_uart_write_ready <= `MASTER_UART_WRITE_READY_ENABLE;
          join//bus_write_data <= 35'h0000_0011;
         master_uart_addr <= 32'h0000_0001;
        //  #6 bus_write_data <= 35'h0000_0011;
          #200 master_uart_write_data <= 33'h0000_0011;//第一份数据得在发送了ready信号之后的第二个时钟周期
          

          fork
          #100 master_uart_write_data <= 33'h0000_1001;
              #100 master_uart_write_ready <= `MASTER_UART_WRITE_READY_DISABLE;
              join
          #100 master_uart_write_data <= 33'h0000_1111;
          
          #100  master_uart_write_data <= 33'h0000_0011;
         
 end 
    uart uart(as, rw, master_uart_write_ready, clk,reset,master_uart_write_data,master_uart_addr,
word_number,uart_mem_addr, tx,bus_error, uart_memctrl_read_ready,word_number1);
 
    initial
      begin
          $dumpfile("uart.vcd");
          $dumpvars(0,test);
      end
endmodule // test