 module IF_controller( input clk,resetn,//输入时钟和复位信号
 						input [`BusAddrWidth] pc, //输入流水线传来的指令
                       input um, erl, //输入流水线传来的信号 
                      output if_bus_error1,//输出if阶段的总线错误给流水线
                      output if_addr_error1,//输出if阶段的地址错误给流水线
                      output if_cache_error1,//输出if阶段的cache错误给流水线
                      output if_mux,cache_read, //mux输出给流水线，cache_read信号给L1指令cache
                      output uncache_bus_req,//if控制器输出的总线请求给总线仲裁器
                      input bus_uncache_grant,//总线仲裁器输出的授权信号
                      output [`InsWidth] ins, //将cache error buffer中的指令传给流水线
                      output  req_addr,
                      output req_as, req_rw
 		);
 /*将cache error buffer放入if 控制器中实现*/
 reg [`CacheErrorBufferDataWidth] cache_error_buffer [`CacheErrorBufferDepth];
 reg cache_error_buffer_valid;//cache_error_buffer的有效位
 reg [`IfControllerStateBitWidth] state;  		//定义状态
always @(posedge clk or  `RESET_EDGE resetn) //异步复位同步释放
begin 
	if(resetn == `RESET_ENABLE) 
	begin
		 state <= `IF_CONTROLLER_STATE_IDLE;
	end else 
	begin
		case(state)
			`IF_CONTROLLER_STATE_IDLE://空闲状态
			begin
				if (pc[0]|pc[1] == 1'b1 ) //检测地址错误的条件指令地址是否对齐
				begin
					if_addr_error1 <= `ADDR_ERROR_ENABLE;
				end //检测地址错误的条件 越界
				else if (um == `UM_ENABLE && pc > `TEXT_UPPER_LIMIT)
				begin
					if_addr_error1 <= `ADDR_ERROR_ENABLE;
				end
				else if (um == `UM_DISABLE && pc > `MEM_UPPER_LIMIT)
				begin
					if_addr_error1 <= `ADDR_ERROR_ENABLE;
		  		end
				else if (um == `UM_DISABLE && erl == `ERL_ENABLE &&
					(pc > `UNCACHE_UPPER_LIMIT|pc < `UNCACHE_UNDER_LIMIT))
				begin
					if_addr_error1 <= `ADDR_ERROR_ENABLE;
				end
				else  //没有地址错误之后的操作
				begin
					if_addr_error1 <= `ADDR_ERROR_DISABLE;
					if (pc <= `UNCACHE_UPPER_LIMIT && pc >= `UNCACHE_UNDER_LIMIT)
					begin //如果地址为非cache管理的地址则状态跳转到读uncache地址的状态
						mux <= `MUX_UNCACHE;
						state <= `IF_CONTROLLER_STATE_UNCACHE;
					end else //地址为cache地址，给L1 cache发送信息，跳转到cache状态
					begin
						mux <= `MUX_CACHE;
						state <= `IF_CONTROLLER_STATE_CACHE;
						cache_read <= `CACHE_READ_ENABLE;
					end
				end
			end
			`IF_CONTROLLER_STATE_UNCACHE:  //读非cache管理的地址
			begin
				if ( cache_error_buffer_valid == `CACHE_ERROR_BUFFER_VALID_ENABLE)
				begin //cache error buffer中的指令有效
					ins <= cache_error_buffer[pc-`CACHE_ERROR_ADDR_UNDER_LIMIT];
					/*cache error处理程序的第一条指令放在cache_error_buffer的地址0处*/
					state <= `IF_CONTROLLER_STATE_IDLE;
				end else 
				begin //cache error buffer中的数据无效，请求总线传输数据
					if_controller_req <= `IF_CONTROLLER_REQ_ENABLE;
					//接收到授权信号之后通过总线将请求数据的地址传给UART
					if (if_controller_grant == `IF_CONTROLLER_GRANT_ENABLE)
					begin
						req_addr = pc;  //地址
						req_as = `REQ_AS_ENABLE;	//as选通信号
						req_rw = `REQ_RW_READ; //读信号
						if_controller_req <= `IF_CONTROLLER_REQ_DISABLE;//接收到授权信号之后撤销请求信号
						state <= `IF_CONTROLLER_STATE_UNCACHE_WRITE;//状态跳转至写cache error buffer状态
					end       
				end 
			end
		    `IF_CONTROLLER_STATE_CACHE: //进入去
		    begin
		    	if (if_bus_error0 == `BUS_ERROR_ENABLE)
		    	begin
		    		if_bus_error1 <= `BUS_ERROR_ENABLE;
		    	end else
		    	begin
		    		if_bus_error1 <= `BUS_ERROR_UNABLE;
		    	end
		    	if (if_cache_error0 == `CACHE_ERROR_ENABLE)
		    	begin
		    		if_cache_error1 <= `CACHE_ERROR_ENABLE;
		    	end else
		    	begin
		    		if_cache_error1 <= `CACHE_ERROR_UNABLE;
		    	end
		    end
		    `IF_CONTROLLER_STATE_UNCACHE_WRITE:
		    begin
		    end




	
end 
end 