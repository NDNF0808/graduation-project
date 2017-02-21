module uart_control(input as, rw, master_uart_write_ready, clk,resetn,//接收主控发来的选通信号，
	                   //读写信号，准备写信号，时钟，复位信号
					           input [`BusDataWidth]   master_uart_write_data,//接收主控发来的数据
					           input [`BusAddrWidth]   master_uart_addr, //接收主控发来的地址
					           input                   mem_write_finish,//mem传来的写入完成信号
					           input [`WordNumberBit]  word_number,//总线仲裁器传来的需要传输的字的个数
                     input                   bus_error,//uart_tx传来
                     input                   uart_master_write_ready,//uart_rx传来
                     input [`WordWidth]   uart_master_data,//uart_rx传来
                     input                   uart_master_write_stop,//uart_rx传来
                     output                  rw1, //传给uart_tx
                     output                  master_uart_write_ready1,//传给uart_tx
                     output [`BusDataWidth]  master_uart_write_data1,//传给uart_tx
					           output [`WordNumberBit] word_number1,//传给uart_tx,uart_rx,mem_control,mem 
					           output                  bus_error1,//传给主控
                     output                  uart_master_write_ready1,//传给主控
                     output [`BusDataWidth]  uart_master_data1,//传给主控
                     output                  uart_master_write_stop1,//传给主控 
                     output [`BusAddrWidth]  uart_mem_addr, //将主控发来的地址再传给memory
					           output                  mem_write_finish1,//传给主控的写入完成信号 
					           output                  uart_mem_read //传给mem 的读信号

				           );
    assign rw1 = rw;
    assign master_uart_write_ready1 = master_uart_write_ready;
    assign master_uart_write_data1 = master_uart_write_data;
    assign word_number1 = word_number;
    assign uart_mem_addr = master_uart_addr;//将地址直接传输
 assign mem_write_finish1 = mem_write_finish;
 assign  uart_mem_read = (rw == `RW_READ)? `UART_MEM_READ_ENABLE:`UART_MEM_READ_DISABLE;
    assign uart_master_data1 = (^uart_master_data == 0)? {1'b0,uart_master_data}:{1'b1,uart_master_data};
    assign uart_master_write_ready1 = uart_master_write_ready;
    assign uart_master_write_stop1 = uart_master_write_stop;
    assign bus_error1 = bus_error;
endmodule // uart_control

    
 
    