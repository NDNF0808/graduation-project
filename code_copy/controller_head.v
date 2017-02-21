`define IF_CONTROLLER_STATE_IDLE 2'b00 				//表示if控制器的空闲状态
`define IF_CONTROLLER_STATE_UNCACHE 2'b01 			//表示if控制器的读非cache管理的地址时的状态
`define IF_CONTROLLER_STATE_UNCACHE_WRITE 2'b10 	//表示if控制器的非cache管理地址从mem读到
                                                    //       cache_error_buffer状态
`define IF_CONTROLLER_STATE_CACHE 2'b11     		//表示if控制器读cache管理地址的状态
`define IfControllerStateBitWidth 1:0
`define InsWidth 31:0  //指令宽度
`define ADDR_ERROR_ENABLE  1'b1  //地址错误有效信号
`define ADDR_ERROR_DISABLE  1'b0 //地址错误无效信号
`define   UM_DISABLE  1'b0          //um无效信号即内核状态
`define   UM_ENABLE  1'b1           //um有效信号即用户状态
`define  ERL_ENABLE 1'b1            //erl信号有效
`define  TEXT_UPPER_LIMIT  32'h0FFF_FFFF //内存地址text字段的上限（包含此地址）
`define UNCACHE_UPPER_LIMIT 32'hBFFF_FFFF  //非cache管理地址的上限(包含)
`define UNCACHE_UNDER_LIMIT 32'hA000_0000   //非cache管理地址的下限（包含）
`define UNMAPPED_UNDER_LIMIT 32'h8000_0000 //ummapped地址的下界
`define UNMAPPED_UPPER_LIMIT 32'h9FFF_FFFF
`define MEM_UPPER_LIMIT 32'hFFFF_FFFF     //mem地址上限
`define USER_UPPER_LIMIT 32'h7FFF_FFFF //用户空间上界(包含此地址)
`define IF_MUX_CACHE 1'b0            //if阶段指令来源为l1 ins cache
`define IF_MUX_UNCACHE 1'b1     //if阶段指令来源为cache error buffer 
`define CACHE_READ_ENABLE 1'b1  //给cache的读信号有效
`define  CACHE_ERROR_BUFFER_VALID_ENABLE 1'b1 //cache_error_buffer的valid位有效
`define CacheErrorBufferDepth 4:0  //cache_error_buffer的长度(暂定需修改)
`define CacheErrorBufferDataWidth 31:0//cache_error_buffer的数据长度
`define  REQ_ENABLE 1'b1  //总线请求有效
`define  REQ_DISABLE 1'b0  //总线请求无效
`define REQ_AS_ENABLE 1'b1           //请求的as信号有效
`define REQ_RW_READ 1'b1      //请求读信号
`define REQ_RW_WRITE 1'b0	//请求写信号
`define SLAVE_READY_ENABLE 1'b1   //从属发送的准备信号通知master可以开始接收了
`define BUS_ERROR_ENABLE 1'b1  //bus error 有效
`define BUS_ERROR_DISABLE 1'b0
`define CACHE_ERROR_ENABLE 1'b1  //cache error 有效
`define CACHE_ERROR_DISABLE 1'b0


//MEM_controller的宏定义
`define MemControlerStateBit 2:0  //定义mem阶段控制器的状态所需要的比特位
`define MEM_CONTROLLER_STATE_IDLE 3'b000 //定义mem控制器的空闲状态
`define MEM_CONTROLLER_STATE_IO_READ_TX 3'b001 //io发送读信息状态
//`define MEM_CONTROLLER_STATE_IO_WRITE_TX0 3'b010 //io发送写信息状态
`define MEM_CONTROLLER_STATE_IO_WRITE_TX 3'b011 //io发送写信息状态
`define MEM_CONTROLLER_STATE_WAITING 3'b100 //等待uart传来的写入完成信号或者读准备信号
`define MEM_CONTROLLER_STATE_IO_READ  3'b101 //io读状态
`define MEM_CONTROLLER_STATE_CACHE 3'b110 //访问的地址是cache的地址

`define ENABLE 1'b1 //定义word halfword byte的信号有效
`define DISABLE 1'b0  //定义word halfword byte的信号无效
//`define MUX_IO 1'b1 //选择mem_stage_controller传来的数据
//`define MUX_CACHE 1'b0 //选择L1传来的数据
`define CACHE_ERROR_ENABLE 1'b1 
`define CACHE_ERROR_DISABLE 1'b0
