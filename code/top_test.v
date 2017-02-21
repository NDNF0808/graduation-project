`timescale 1ns/1ps
`include "./top.v"
//`include "./uart_control.v"
//`include "D:/IFMRT/graduation-project/code/uart_control.v"
module test;
                       reg [`BusAddrWidth] addr;//输入要读或者写的地址
                        reg rw; //输入读或者写信号
                        reg um;  //输入模式的状态
                        reg half_word; //输入读或者写半字标志
                         reg byte_word; //读或者写字节标志
                        reg word;  //读或者写字的标志
                         reg [`WordWidth] data; //输入要写回的数据
                         reg clk, reset;
                        wire mem_mux,mem_bus_error,mem_cache_error,mem_addr_error;
                      wire [`WordWidth] io_data;
    
    initial
      begin
          clk = 1'b0;//注意时钟，第一个上升沿是在4个单位时，取时钟第二个上升沿才是进入idle状态的时间，此时线传输控制信号rw,ready
          
          reset = 1'b0;
          #2 reset = ~reset;
          repeat(1000000)
            begin
                #50 clk = ~clk;
                
            end 
      end
    initial
      begin
          fork
              #152  rw = `RW_WRITE;
              
        #152 addr = 32'hA000_0000;
        #152  um  = `UM_DISABLE ;
        #152  half_word = `DISABLE ;
        #152  byte_word = `DISABLE ;
        #152  word = `ENABLE ;
       
          join//bus_write_data <= 35'h0000_0011;
          
        //  #6 bus_write_data <= 35'h0000_0011;
          fork
          #200 data = 32'h0000_0011;//第一份数据得在发送了ready信号之后的第二个时钟周期
            #500 rw = 'dx;
          join
          //    #100 master_uart_write_data = 33'h0000_1001;
          //#100  master_uart_write_data = 33'h0000_1111;
         // #100  master_uart_write_data = 33'h0011_0011;
         // #100 rw = `RW_READ;
          
      end // initial begin
   initial
      begin
          fork
          #3344052 rw = `RW_READ;
              #3344052 addr = 32'hA000_0000;
              
          join
          #300 rw = 'dx;//read信号至少得维持三个周期

    
      end
    
    top top( addr,rw, um,half_word, byte_word, word, data, clk, reset,mem_mux,mem_bus_error,mem_cache_error,mem_addr_error, io_data);
 
    initial
      begin
          $dumpfile("top.vcd");
          $dumpvars(0,test);
      end
endmodule // test