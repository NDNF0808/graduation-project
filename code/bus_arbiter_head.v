`define BUS_ARBITER_STATE_IDLE 1'b0 //总线仲裁器的初始状态
`define BUS_ARBITER_STATE_BUSY 1'b1 //总线仲裁器的忙碌状态
`define GRANT_ENABLE 1'b1 //授权信号有效
`define GRANT_DISABLE 1'b0 //授权信号无效
`define FREE_ENABLE 1'b1 //释放总线信号有效
`define FREE_DISABLE 1'b0 //释放总线信号无效
`define WordNumberBit 2:0 //记录需要传输的字的个数（需更改）
`define WORD_NUMBER_INIT 3'b0 //传输的字的个数的初始化
`define IO_WORD_NUMBER 3'd1  //IO请求时传输的字的个数为1
`define L2CACHE_WORD_NUMBER 3'd4 //L2cache请求时传输的字的个数为4
`define UNCACHE_WORD_NUMBER 3'd5 //cache error 处理程序的指令个数（需更改）
