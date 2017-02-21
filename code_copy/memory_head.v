

`define MemDataWidth 7:0  //存储器的寻址方式按字节寻址
`define MemWidth 2^27-1:0 //存储器的地址宽度
`define MEM_WIDTH 2^27-1
`define WordWidth 31:0  //字的宽度
`define  MemStateBit 1:0 //定义mem的状态所需比特位
`define MEM_STATE_IDLE 2'b00 //定义mem的初始状态
`define MEM_STATE_WRITE 2'b01 //定义mem的写状态
`define MEM_STATE_READ0 2'b10 //定义mem的读状态
`define MEM_STATE_READ1 2'b11 //定义mem的读状态




/*mem控制器的宏定义*/
`define MemControlStateBit 2:0 //mem控制器的状态所需比特位
`define MEM_CONTRON_STATE_IDLE 3'b000 //mem控制器的闲置状态
`define MEM_CONTRON_STATE_WRITE_BUFFER 3'b001 //mem控制器的接收数据状态
`define MEM_CONTRON_STATE_BUFFER_MEM0 3'b010 //控制器传输数据给mem
`define MEM_CONTRON_STATE_BUFFER_MEM1 3'b011
`define MEM_CONTROL_STATE_READ_MEM 3'b100 //读状态
`define MEM_CONTROL_STATE_BUFFER_UART0 3'b101 //	buffer中的数据放入移位寄存器
`define MEM_CONTROL_STATE_BUFFER_UART1 3'b110 //移位寄存器中的数串行发送给UART
`define MEM_WRITE_FINISH_ENABLE 1'b1 //mem写入完成信号有效
`define MEM_WRITE_FINISH_DISABLE 1'b0 //mem写入完成信号无效
`define MemBufferWidth 7:0  //定义mem控制器内的buffer的数据宽度
`define MemBufferDepth 15:0 //定义mem控制器内的buffer深度暂时定为4个字（暂定）本次设计中最多写入四个字即为一个块mem buffer选择按字节接收
`define MemBufferDepthMsb 15 //定义mem buffer深度最大值（暂定）
`define MEMCTRL_MEM_WRITE_START_ENABLE 1'b1 //memctrl传输给mem的开始写信号有效
`define MEMCTRL_MEM_WRITE_START_DISABLE 1'b0 //memctrl传输给mem的开始写信号无效
`define MemBufferCountWidth 4:0 //定义mem buffer的计数器位宽每次写入一个字加一
`define MEM_BUFFER_COUNT_INIT 'd0 //mem buffer计数器的初始化值

`define MEM_MEMCTRL_WRITE_READY_ENABLE  1'b1 //mem传给memctrl的写开始信号有效
`define MEM_MEMCTRL_WRITE_READY_DISABLE  1'b0 //mem传给memctrl的写开始信号无效
/*读状态*/
`define RX_START_BIT 1'b0 //memcontrol向uart发送数据的开始信号
`define RX_STOP_BIT 1'b1 
