`include "./uart_tx.v"
`include "./uart_rx.v"
`include "./uart_control.v"
`include "./resetn.v"
`include "./memory_control.v"
`include "./mem.v"
`include "./bus_arbiter.v"
`include "./MEM_stage_controller.v"
module top (
                        input [`BusAddrWidth] addr,//输入要读或者写的地址
                        input rw, //输入读或者写信号
                        input um,  //输入模式的状态
                        input half_word, //输入读或者写半字标志
                        input byte_word, //读或者写字节标志
                        input word,  //读或者写字的标志
                        input [`WordWidth] data, //输入要写回的数据
                        input clk, reset,
                        output mem_mux,mem_bus_error,mem_cache_error,mem_addr_error,
                        output  [`WordWidth] io_data
           );             
      wire mem_write_finish1;

    wire [`BusAddrWidth] master_uart_addr;
    
    wire           rw1; //传给uart_tx
    wire           rw2;
    
    wire           master_uart_write_ready;//传给uart_tx
    wire           master_uart_write_ready1;//传给uart_tx
    wire [`BusDataWidth] master_uart_write_data1;//传给uart_tx
    wire [`BusDataWidth] master_uart_write_data;//传给uart_tx
		wire [`WordNumberBit] word_number1;//传给uart_tx,uart_rx,mem_control,mem 
    wire [`BusDataWidth]  uart_master_data1;
    
		wire                  bus_error;//传给主控
    wire                  uart_master_write_stop1;
    
    wire                  uart_master_write_ready;//传给主控
     wire                  uart_master_write_ready1;
    wire                   bus_error1;
    
    wire [`WordWidth]  uart_master_data;//传给主控
    wire                  uart_master_write_stop;//传给主控 
    wire [`BusAddrWidth]  uart_mem_addr; //将主控发来的地址再传给memory
		wire                  mem_write_finish;//传给主控的写入完成信号 
		wire                  uart_mem_read ;//传给mem 的读信号
    
    wire                            reset0;
    wire                           tx;
    wire                           memctrl_mem_write_start;
    wire [`WordWidth]              memctrl_mem_write_data;
    wire                           memctrl_mem_read;
    wire                           uart_memctrl_read_ready;
    wire                           rx;
    wire                           mem_memctrl_write_ready;                                                               
    wire [`WordWidth]              mem_memctrl_read_data;

    wire io_bus_req, L2cache_bus_req,uncache_bus_req,io_bus_free, L2cache_bus_free,uncache_bus_free;
    wire  bus_io_grant,bus_L2cache_grant,bus_uncache_grant;
    wire [`WordNumberBit] word_number;
    resetn resetn (.clk(clk),
                   .reset(reset),
                   .resetn(reset0)
);
   mem_stage_controller mem_stage_controller(
                     .addr(addr),
                     .rw(rw),
                     .um(um),  
                    .half_word(half_word),
                    .byte_word(byte_word), 
                    .word(word), 
                    .data(data), 
                    .clk(clk),
                    .resetn(reset0),
                    .bus_io_grant(bus_io_grant),
                    .uart_master_write_ready1(uart_master_write_ready1),
                    .uart_master_data1(uart_master_data1),
                    .uart_master_write_stop1(uart_master_write_stop1),
                    .bus_error(bus_error1),
                    .mem_write_finish1(mem_write_finish1),
                    .mem_mux(mem_mux), 
                     .mem_bus_error(mem_bus_error),
                     .mem_cache_error(mem_cache_error),
                     .mem_addr_error(mem_addr_error),
                      .io_data(io_data),
                      // .cache_rw(cache_rw), 
                        .io_bus_req(io_bus_req), 
                        .rw1(rw1),
                    .master_uart_addr(master_uart_addr),
                    .master_uart_write_ready(master_uart_write_ready),
                    .master_uart_write_data(master_uart_write_data),
                    .io_bus_free(io_bus_free)

        );
    bus_arbiter bus_arbiter(
                    .clk(clk),
                    .resetn(reset0),
                    .io_bus_req(io_bus_req),
                    .L2cache_bus_req(L2cache_bus_req),
                    .uncache_bus_req(uncache_bus_req),
                    .io_bus_free(io_bus_free),
                    .L2cache_bus_free( L2cache_bus_free),
                    .uncache_bus_free(uncache_bus_free),
                    .bus_io_grant( bus_io_grant),
                    .bus_L2cache_grant(bus_L2cache_grant),
                    .bus_uncache_grant(bus_uncache_grant),
                    .word_number(word_number)
                  
                
        );
    uart_control uart_control(
                 .as(as),
                 .rw(rw1),
                 .master_uart_write_ready(master_uart_write_ready),
                 .clk(clk),
                 .resetn(reset0),
                 .master_uart_write_data(master_uart_write_data),
                 .master_uart_addr(master_uart_addr),
                              .mem_write_finish(mem_write_finish),
                 .word_number(word_number),
                 .bus_error(bus_error),
                 .uart_master_write_ready(uart_master_write_ready),
                 .uart_master_data(uart_master_data),
                 .uart_master_write_stop(uart_master_write_stop),
                 .rw1(rw2),
                 .master_uart_write_ready1(master_uart_write_ready1),
                 .master_uart_write_data1(master_uart_write_data1),
                 .word_number1(word_number1),
                 .bus_error1(bus_error1),
                 .uart_master_write_ready1(uart_master_write_ready1),
                 .uart_master_data1(uart_master_data1),
                 .uart_master_write_stop1(uart_master_write_stop1),
                 .uart_mem_addr(uart_mem_addr),
                 .mem_write_finish1(mem_write_finish1),
                 .uart_mem_read(uart_mem_read)
);
    
    uart_tx uart_tx(
                    .rw1(rw2),
                    .master_uart_write_ready1(master_uart_write_ready1),
                    .clk(clk),
                    .resetn(reset0),
                    .master_uart_write_data1(master_uart_write_data1),
                    .word_number1(word_number1),
                    .tx(tx),
                    .bus_error(bus_error));
    
    memory_control memory_control(.tx(tx),
                            .clk(clk),
                            .resetn(reset0),
                            .mem_memctrl_write_ready(mem_memctrl_write_ready),
                            .mem_memctrl_read_data(mem_memctrl_read_data),
                            .word_number1(word_number1),
                            .memctrl_mem_write_start(memctrl_mem_write_start),
                            .memctrl_mem_write_data(memctrl_mem_write_data),
                            .rx(rx));
    uart_rx uart_rx(
                    .word_number1(word_number1),
                    .rx(rx),
                    .clk(clk),
                    .resetn(reset0),
                    .uart_master_write_ready(uart_master_write_ready),
                    .uart_master_data(uart_master_data),
                    .uart_master_write_stop(uart_master_write_stop)
                    );
    
    mem mem (
             .uart_mem_addr(uart_mem_addr),
             .word_number1(word_number1),
             .memctrl_mem_write_start(memctrl_mem_write_start),
             .clk(clk),
             .resetn(reset0),
             .memctrl_mem_write_data(memctrl_mem_write_data),
             .uart_mem_read(uart_mem_read),
             .mem_memctrl_read_data(mem_memctrl_read_data),
             .mem_memctrl_write_ready(mem_memctrl_write_ready),
             .mem_write_finish(mem_write_finish));
    
 endmodule
   
    