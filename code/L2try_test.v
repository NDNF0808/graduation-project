    `timescale 1ns/1ps
`include "./L2try.v"
//`include "./uart_control.v"
//`include "D:/IFMRT/graduation-project/code/uart_control.v"
module test;
    reg             io_bus_req,L2cache_bus_req,uncache_bus_req,io_bus_free,L2cache_bus_free,uncache_bus_free;
                           wire                 bus_io_grant; //输出总线对io的授权信号
					                 wire                 bus_L2cache_grant;//输出总线对L2cache的授权信号
					                 wire                 bus_uncache_grant;//输出总线对非cache的授权信号
                           reg                  as,rw,master_uart_write_ready;
                           reg [`BusDataWidth]  master_uart_write_data;
                           reg [`BusAddrWidth]  master_uart_addr;//输入要读或者写的地址
                           wire                 bus_error1;//传给主控
                           wire                 uart_master_write_ready1;//传给主控
                           wire [`BusDataWidth] uart_master_data1;//传给主控
                           wire                 uart_master_write_stop1;//传给主控 
		wire                                        mem_write_finish1;
    reg                                         clk,reset;
    
//
    
    initial
      begin
          clk = 1'b0;//注意时钟，第一个上升沿是在4个单位时，取时钟第二个上升沿才是进入idle状态的时间，此时线传输控制信号rw;ready
          io_bus_req <= `REQ_DISABLE;
          uncache_bus_req <= `REQ_DISABLE;
 
          
          reset = 1'b0;
          #2 reset = ~reset;
          repeat(1000000)
            begin
                #50 clk = ~clk;
                
            end 
      end // initial begin
    initial
      begin
          #252 L2cache_bus_req <= `REQ_ENABLE;
          fork
          #200 master_uart_write_ready <= `MASTER_UART_WRITE_READY_ENABLE;
              #200 master_uart_addr <= 32'h7000_0000;
              #200 rw <= `RW_WRITE;
              
          join
          #100 master_uart_write_data <= 32'h0000_0011;
          fork
              #100 rw <= 'dz;
              #100 master_uart_write_data <= 32'h0010_0001;
              
          join
          #100 master_uart_write_data <= 32'h0000_1001;
          #100 master_uart_write_data <= 32'h1100_0011;
          
      end
    
/*   initial
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
          
      end // initial begin */
   initial
      begin
          fork
          #3344452 rw = `RW_READ;
              #3344452  master_uart_addr = 32'h7000_0000;
              
          join
          #300 rw = 'dx;//read信号至少得维持三个周期

    
      end
    
  L2try L2try( io_bus_req,L2cache_bus_req,uncache_bus_req,io_bus_free,L2cache_bus_free,uncache_bus_free, bus_io_grant,  bus_L2cache_grant, bus_uncache_grant, as,rw,master_uart_write_ready, master_uart_write_data, master_uart_addr, bus_error1, uart_master_write_ready, uart_master_data1,uart_master_write_stop,  mem_write_finish1,clk,reset);
    
 
    initial
      begin
          $dumpfile("L2try.vcd");
          $dumpvars(0,test);
      end
endmodule // test