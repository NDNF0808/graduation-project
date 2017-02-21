`include "./bus_arbiter_head.v"
`include "./memory_head.v"
`include "./uart_head.v"
`include "./general_head.v"
module bus_arbiter( input clk,resetn, //输入时钟和复位信号
					input io_bus_req, //输入io对总线的请求
					input L2cache_bus_req,//输入L2cache对总线的请求
					input uncache_bus_req,//输入非cache管理的总线请求
					input io_bus_free,//io传来的释放总线得到信号
					input L2cache_bus_free,//L2cache的释放总线的信号
					input uncache_bus_free,//非cache管理的请求释放总线的信号
					output reg  bus_io_grant, //输出总线对io的授权信号
					output reg bus_L2cache_grant,//输出总线对L2cache的授权信号
					output reg bus_uncache_grant,//输出总线对非cache的授权信号
					output reg [`WordNumberBit] word_number //传输给uart
	);
reg state;
always @(`CLK_EDGE clk or  `RESET_EDGE resetn) //异步复位同步释放
begin 
	if(resetn == `RESET_ENABLE) 
	begin
		 state <= `BUS_ARBITER_STATE_IDLE;
		 bus_io_grant <= `GRANT_DISABLE;
		bus_L2cache_grant <= `GRANT_DISABLE;
		bus_uncache_grant <= `GRANT_DISABLE;
		word_number <= `WORD_NUMBER_INIT;
	end else 
	begin
		case(state)
			`BUS_ARBITER_STATE_IDLE://mem阶段请求优先级高于IF段
			begin//io请求优先级高于L2cache的请求高于uncache请求
				case({io_bus_req,L2cache_bus_req,uncache_bus_req})
				3'b1??:
				begin //请求信号有效之后进行授权并且状态跳转到忙碌状态
					bus_io_grant <= `GRANT_ENABLE;
					bus_uncache_grant <= `GRANT_DISABLE;
					bus_L2cache_grant <= `GRANT_DISABLE;
					state <= `BUS_ARBITER_STATE_BUSY;
					word_number <= `IO_WORD_NUMBER;
				end 
				3'b01?:
				begin
					bus_io_grant <= `GRANT_DISABLE;
					bus_L2cache_grant <= `GRANT_ENABLE;
					bus_uncache_grant <= `GRANT_DISABLE;
					state <= `BUS_ARBITER_STATE_BUSY;
					word_number <= `L2CACHE_WORD_NUMBER;
				end 
				3'b001:
				begin
					bus_io_grant <= `GRANT_DISABLE;
					bus_L2cache_grant <= `GRANT_DISABLE;
					bus_uncache_grant <= `GRANT_ENABLE;
					state <= `BUS_ARBITER_STATE_BUSY;
					word_number <= `UNCACHE_WORD_NUMBER ;
				end 
				default:
				begin
					bus_io_grant <= `GRANT_DISABLE;
					bus_L2cache_grant <= `GRANT_DISABLE;
					bus_uncache_grant <= `GRANT_DISABLE;
				end 
				endcase 
			end 
			`BUS_ARBITER_STATE_BUSY:
			begin //检测释放信号，如果有效则撤销授权信号且状态跳转到空闲状态
               if(io_bus_free == `FREE_ENABLE || L2cache_bus_free == 
               	`FREE_ENABLE || uncache_bus_free == `FREE_ENABLE)
               begin
               		bus_io_grant <= `GRANT_DISABLE;
					bus_L2cache_grant <= `GRANT_DISABLE;
					bus_uncache_grant <= `GRANT_DISABLE;
					state <= `BUS_ARBITER_STATE_IDLE;
               end
			end 
		endcase // state
	end
end 
endmodule 
