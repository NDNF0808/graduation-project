`include "./bus_arbiter_head.v"
`include "./memory_head.v"
`include "./uart_head.v"
`include "./general_head.v"
`include "./controller_head.v"
module mem_stage_controller( input [`BusAddrWidth] addr,//输入要读或者写的地址
						input                      rw, //输入读或者写信号
						input                      um, //输入模式的状态
						input                      half_word, //输入读或者写半字标志
						input                      byte_word, //读或者写字节标志
						input                      word, //读或者写字的标志
						input [`WordWidth]         data, //输入要写回的数据
						input                      clk, resetn,
						input                      bus_io_grant,//输入的总线授权信号
						input                      uart_master_write_ready1,//uart传来的写准备信号
						input [`BusDataWidth]      uart_master_data1,//uart传来读取的数据
						input                      uart_master_write_stop1,
						input                      bus_error,//uart传来的总线错误信号
						input                      mem_write_finish1,
						//cache所有均与controller交互，controller与流水线交互，所以controller选择数据后输给流水线就不需要mux
						output reg                 mem_mux, //输出mem段二路选择器的控制信号,选择cache传来的数据或者mem_controller传来的数据
						output reg                 mem_bus_error, //输出总线错误信号
						output reg                 mem_cache_error, //输出cache错误信号
						output reg                 mem_addr_error,//输出地址错误信号
						output reg [`WordWidth]    io_data, //读取io的数据
						output reg                 io_bus_req, //输出给总线io请求
						output reg                 rw1,//输出给uart的读或者写信号
						output reg [`BusAddrWidth] master_uart_addr,//传给uart的地址
						output reg                 master_uart_write_ready,//传给uart的写准备信号
						output reg [`BusDataWidth] master_uart_write_data,//传给uart的写的数据
						output reg                 io_bus_free
     /*       output reg [`WordWidth]        controller_cache_data ,
            output  reg                    controller_cache_word,
            output  reg                    controller_cache_half_word,
            output   reg                   controller_cache_byte_word,
            output reg [`BusAddrWidth]  controller_cache_addr */
	);
reg [`MemControlerStateBit] state;//定义状态

always @(posedge clk or  `RESET_EDGE resetn) //异步复位同步释放
begin 
	if(resetn == `RESET_ENABLE) 
	begin
		  state <= `MEM_CONTROLLER_STATE_IDLE;
      io_bus_req <= `REQ_DISABLE;

	end else 
	begin
		case(state)
			`MEM_CONTROLLER_STATE_IDLE://空闲状态
			//空闲状态检测是否有地址错误。地址不对齐和越界
			begin//主控收到地址错误信号之后应该停止向控制器传送这些信息，就算控制器将这些信号置位无效，主控传来的信号还是会覆盖当前信号
				//地址不对齐
          mem_mux <= 'dz;
          mem_bus_error <= `BUS_ERROR_DISABLE;
          mem_cache_error <= `CACHE_ERROR_DISABLE;
          mem_addr_error <= `ADDR_ERROR_DISABLE;
          io_bus_req <= `REQ_DISABLE;
          rw1 <= 'dz;
          master_uart_addr <= 'dz;
          master_uart_write_ready <= `MASTER_UART_WRITE_READY_DISABLE;
          
	    io_bus_free <= `FREE_DISABLE;
				if(word  == `ENABLE && (addr[0]|addr[1] == 1'b1))
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				else if(half_word == `ENABLE && addr[0] == 1'b1)
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				//地址越界
				else if(rw == `RW_WRITE && um == `UM_ENABLE &&
				 (addr <= `TEXT_UPPER_LIMIT || addr > `USER_UPPER_LIMIT))
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				else if (rw == `RW_WRITE && um == `UM_DISABLE &&
				(addr <= `TEXT_UPPER_LIMIT | ( addr > `MEM_UPPER_LIMIT)|
				 (addr >= `UNMAPPED_UNDER_LIMIT && addr <= `UNMAPPED_UPPER_LIMIT) ) )
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				else if (rw == `RW_READ && um == `UM_ENABLE &&
					(addr > `USER_UPPER_LIMIT))
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				else if (rw == `RW_READ && um == `UM_DISABLE &&
					(addr > `MEM_UPPER_LIMIT))
					mem_addr_error <= `ADDR_ERROR_ENABLE;
				else 
				begin//没有地址错误之后检测地址是IO还是L1的地址
					mem_addr_error <= `ADDR_ERROR_DISABLE;
					if (addr <= `UNCACHE_UPPER_LIMIT && addr >= `UNCACHE_UNDER_LIMIT)
					begin //如果地址为IO地址则状态跳转到IO状态
              if(rw == `RW_READ || rw == `RW_WRITE)
                begin
						        io_bus_req <= `REQ_ENABLE;
                end 
						if(bus_io_grant == `GRANT_ENABLE)
						begin
							if(rw == `RW_READ)
							begin
								state <= `MEM_CONTROLLER_STATE_IO_READ_TX;

							end
							if(rw == `RW_WRITE)
							begin
								state <= `MEM_CONTROLLER_STATE_IO_WRITE_TX;
								 master_uart_write_ready <= `MASTER_UART_WRITE_READY_ENABLE;
								master_uart_addr <= addr;
								rw1 <= `RW_WRITE;
							end
						end

					end else //地址为cache地址，给L1 cache发送信息，跳转到cache状态
					  begin
              /*  rw1 <= rw;
                controller_cache_data <= data;
                controller_cache_word <= word;
                controller_cache_half_word <= half_word;
                controller_cache_byte_word <= byte_word;
                controller_cache_addr <= addr;
                state <= `MEM_CONTROLLER_STATE_CACHE;*/
                
						//mem_mux <= `MUX_CACHE;
						
				//		cache_rw <= rw;
					end
				end 

			end
	/*		`MEM_CONTROLLER_STATE_IO_WRITE_TX0:
			begin
				io_bus_req <= `REQ_DISABLE;
				state <= `MEM_CONTROLLER_STATE_IO_WRITE_TX1;
			end*/
			`MEM_CONTROLLER_STATE_IO_READ_TX:
			begin
				io_bus_req <= `REQ_DISABLE;
				rw1 <= `RW_READ;
				master_uart_addr <= addr;
				state <= `MEM_CONTROLLER_STATE_WAITING;
			end
			`MEM_CONTROLLER_STATE_IO_WRITE_TX:
			begin
				  io_bus_req <= `REQ_DISABLE;
				  state <= `MEM_CONTROLLER_STATE_WAITING;
          master_uart_write_ready <= `MASTER_UART_WRITE_READY_DISABLE;

				//生成基偶校验位并传输
				if (^data == 0)
				master_uart_write_data <= {1'b0,data};
				else
				master_uart_write_data <= {1'b1,data};
			end 
			`MEM_CONTROLLER_STATE_WAITING:
			  begin
            rw1 <= 'dz;
            
				if(bus_error == `BUS_ERROR_ENABLE)
				begin
					mem_bus_error <= `BUS_ERROR_ENABLE;
					state <= `MEM_CONTROLLER_STATE_IDLE;
				end 
				else
				begin
					mem_bus_error <= `BUS_ERROR_DISABLE;
					if(mem_write_finish1 == `MEM_WRITE_FINISH_ENABLE)
					begin
						state <= `MEM_CONTROLLER_STATE_IDLE;
						io_bus_free <= `FREE_ENABLE;
					end 
				end 
				if(uart_master_write_ready1 == `UART_MASTER_WRITE_READY_ENABLE)
					state <= `MEM_CONTROLLER_STATE_IO_READ;

			end 
			`MEM_CONTROLLER_STATE_IO_READ:
			begin
				if(^uart_master_data1 == 0)
				begin
			//		pipeline_ready <= `ENABLE;
					io_data <= uart_master_data1[31:0];
            
						//mem_mux <= `MUX_IO;
					mem_bus_error <= `BUS_ERROR_DISABLE;
					state <= `MEM_CONTROLLER_STATE_IDLE;
            io_bus_free <= `FREE_ENABLE;
            
				end 
				else 
				begin
					io_data <= 'dz;
					mem_bus_error <= `BUS_ERROR_ENABLE;
					state <= `MEM_CONTROLLER_STATE_IDLE;
				end 
			end 
			
			`MEM_CONTROLLER_STATE_CACHE:
			begin
			end 
		endcase // state
	end
end




endmodule // mem_controller