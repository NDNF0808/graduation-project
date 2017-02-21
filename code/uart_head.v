/*uart_control的宏定义*/
/*波特率采用38400baud 也就是38400bit/s 时钟频率采用10MHZ 即时钟时间为100ns 则分频比率约为260*/
`define BusDataWidth 32:0  //数据总线宽度
`define BusAddrWidth 31:0  //地址总线宽度
`define MASTER_UART_WRITE_READY_ENABLE 1'b1  //主控传输给uart的开始写信号有效
`define MASTER_UART_WRITE_READY_DISABLE 1'b0  //主控传输给uart的开始写信号有效

`define UartStateBit 1:0  //uart的状态比特位
`define UART_STATE_IDLE  2'b00//uart的闲置状态
`define UART_STATE_WRITE_FIFO  2'b01 //uart的写FIFO状态
`define UART_STATE_FIFO_TRANSMITTER0  2'b10//uart的将fifo数据传输到发送移位寄存器的状态
`define UART_STATE_FIFO_TRANSMITTER1  2'b11//将发送移位寄存器的数据串行传输到mem control
//`define UART_STATE_READ 3'b100 //uart的读mem control传来的数据状态
//`define UART_STATE_FIFO_RECEIVER0 3'b101 //uart接收memcontrol传来的串行数据
//`define UART_STATE_FIFO_RECEIVER1 3'b110 //uart接收memcontrol传来的串行数据
`define FifoDataWidth  7:0 //FIFO每个地址数据宽度
`define FifoDepth 15:0   //要写回的只有io和L2所以定为L2写回的最大数就是4个字，按字节存储 就是16
`define UART_DIV_RATE  260  //分频比率等于时钟频率除以波特率即传输一个比特所需要的时间（需更改）
`define DivCntWidth   8:0 //分频计数器的计数范围所需比特范围（需更改）
`define DIV_CNT_WIDTH 9 //分频计数器的比特数（需更改）
`define BitCntWidth 2:0 //比特计数器计数从0到7
`define UART_BIT_CNT_START 3'b0  //比特计数器开始计数
`define UART_BIT_CNT_STOP 3'd7 //比特计数器结束计数，一次数据传输完成
`define ShiftRegWidth 7:0 //定义移位寄存器的
`define SHIFT_REG_INIT 8'b0//移位寄存器的初始值
`define CountBit 4:0  //fifo的索引比特位（因为有16所以用5Bit）（需更改）
`define BUS_ERROR_DISABLE 1'b0 //bus error无效
`define BUS_ERROR_ENABLE 1'b1 //bus error有效
`define TX_START_BIT 1'b0 //定义起始位 
`define TX_STOP_BIT 1'b1 //定义结束位
`define UART_MEMCTRL_WRITE_READY_ENABLE 1'b0 //uart传输给mem control的开始写信号有效
`define UART_MEMCTRL_WRITE_READY_DISABLE 1'b1//uart传输给mem control的开始写信号无效
`define RW_READ 1'b1  //读信号有效
`define RW_WRITE 1'b0 //写信号有效
`define UART_MEM_READ_ENABLE 1'b1 //uart传给memctrl的准备写信号有效
`define UART_MEM_READ_DISABLE 1'b0 //uart传给memctrl的准备写信号无效
`define FifoWriteBit 31:0 //接收总线数据基偶校验完成后写入FIFO
`define LEAVE_BIT 2'b00 //fifo的索引比特位减去word number的比特位


`define UART_MASTER_WRITE_READY_ENABLE 1'b1 //uart传给主控的接收开始信号有效
`define UART_MASTER_WRITE_READY_DISABLE 1'b0 //uart传给主控的接收开始信号无效
`define UART_MASTER_WRITE_STOP_ENABLE 1'b1 //uart传给主控的写结束信号有效
`define UART_MASTER_WRITE_STOP_DISABLE 1'b0 //uart传给主控的写结束信号无效

//uart_rx的宏定义
`define UART_TX_IDLE 2'b00 //闲置状态
`define UART_STATE_READ 2'b01 //uart的读mem control传来的数据状态
`define UART_STATE_FIFO_RECEIVER0 2'b10 //uart接收memcontrol传来的串行数据
`define UART_STATE_FIFO_RECEIVER1 3'b11 //uart接收memcontrol传来的串行数据
`define FifoTxDepth 15:0 //取L2和cache error处理程序的最大值(需更改)







