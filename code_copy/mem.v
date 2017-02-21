`include "./memory_head.v"
`include "./uart_head.v"
`include "./general_head.v"
`include "./bus_arbiter_head.v"
/*mem是一个地址保存一个字节*/
module mem(	input [`BusAddrWidth] uart_mem_addr,  //输入要读或者写的地址此处的地址是块的首地址或者IO地址由uart传来
            input [`WordNumberBit]  word_number1,//输入uart传来的字个数信号
			      input                   memctrl_mem_write_start, clk, resetn, //检测到memctrl_mem_write_start之后进入接收数据写mem状态
			      input [`WordWidth]      memctrl_mem_write_data, //输入要写的字
            input                   uart_mem_read, //输入读信号
			      output reg [`WordWidth] mem_memctrl_read_data , //输出要读取的字
            output reg              mem_memctrl_write_ready,//mem传给memctrl的写准备信号
            output reg mem_write_finish //传给uart之后传给主控的写入完成信号
	          );
/*定义32个有2^27个地址的存储器，进行拼接*/
reg [`MemDataWidth] mem0 [`MemWidth];
reg [`MemDataWidth] mem1 [`MemWidth];
reg [`MemDataWidth] mem2 [`MemWidth];
reg [`MemDataWidth] mem3 [`MemWidth];
reg [`MemDataWidth] mem4 [`MemWidth];
reg [`MemDataWidth] mem5 [`MemWidth];
reg [`MemDataWidth] mem6 [`MemWidth];
reg [`MemDataWidth] mem7 [`MemWidth];
reg [`MemDataWidth] mem8 [`MemWidth];
reg [`MemDataWidth] mem9 [`MemWidth];
reg [`MemDataWidth] mem10 [`MemWidth];
reg [`MemDataWidth] mem11 [`MemWidth];
reg [`MemDataWidth] mem12 [`MemWidth];
reg [`MemDataWidth] mem13 [`MemWidth];
reg [`MemDataWidth] mem14 [`MemWidth];
reg [`MemDataWidth] mem15 [`MemWidth];
reg [`MemDataWidth] mem16 [`MemWidth];
reg [`MemDataWidth] mem17 [`MemWidth];
reg [`MemDataWidth] mem18 [`MemWidth];
reg [`MemDataWidth] mem19 [`MemWidth];
reg [`MemDataWidth] mem20 [`MemWidth];
reg [`MemDataWidth] mem21 [`MemWidth];
reg [`MemDataWidth] mem22 [`MemWidth];
reg [`MemDataWidth] mem23 [`MemWidth];
reg [`MemDataWidth] mem24 [`MemWidth];
reg [`MemDataWidth] mem25 [`MemWidth];
reg [`MemDataWidth] mem26 [`MemWidth];
reg [`MemDataWidth] mem27 [`MemWidth];
reg [`MemDataWidth] mem28 [`MemWidth];
reg [`MemDataWidth] mem29 [`MemWidth];
reg [`MemDataWidth] mem30 [`MemWidth];
reg [`MemDataWidth] mem31 [`MemWidth];
    
		reg [`MemStateBit] state;//定义mem的状态
    reg [`WordNumberBit]             word_count;
		reg [`BusAddrWidth] addr; //保存传来的地址
		//进行相应的读操作，所有的读出来由控制器进行选择
      always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
        begin
            if(resetn == `RESET_ENABLE) //复位信号有效时初始化状态
              begin
              	state <= `MEM_STATE_IDLE;
              end else //根据状态进行相应的操作
                begin
                	case(state)
                		`MEM_STATE_IDLE://空闲状态接收到buffer_mem_start之后，跳转到写mem状态
                		begin
                        mem_write_finish <= `MEM_WRITE_FINISH_DISABLE;
                			 addr <= uart_mem_addr - 'd4;
                       word_count <= 'd0;
                       mem_memctrl_write_ready <= `MEM_MEMCTRL_WRITE_READY_DISABLE; 
                			if(memctrl_mem_write_start == `MEMCTRL_MEM_WRITE_START_ENABLE)
                			begin
                				state <= `MEM_STATE_WRITE;
                		  end
                        else if(uart_mem_read == `UART_MEM_READ_ENABLE)
                        begin
                          state <= `MEM_STATE_READ0;
                            addr <= uart_mem_addr;

                          mem_memctrl_write_ready <= `MEM_MEMCTRL_WRITE_READY_ENABLE;
                        end 
                	    end
                		`MEM_STATE_WRITE: //写mem状态
                		begin
                			if(word_count > word_number1)//收到结束信号之后停止接收
                			  begin
                            state <= `MEM_STATE_IDLE; 
                            mem_write_finish <= `MEM_WRITE_FINISH_ENABLE;
                        end else  //一次接收一个字，由于是拼接的mem先得根据前5位进行索引mem，后27位作为地址写入数据
                          begin
                            case(addr[31:27])
                              'd0:
                                begin
                                    {mem0[addr[26:0] + 27'd3],mem0[addr[26:0] + 27'd2],
	                                   mem0[addr[26:0] + 27'd1],mem0[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                    
                                end
                              'd1:
                                begin
                                    {mem1[addr[26:0] + 27'd3],mem1[addr[26:0] + 27'd2],
	                                   mem1[addr[26:0] + 27'd1],mem1[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd2:
                                begin
                                    {mem2[addr[26:0] + 27'd3],mem2[addr[26:0] + 27'd2],
	                                   mem2[addr[26:0] + 27'd1],mem2[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                    end 
                                
                              'd3:
                                begin
                                    {mem3[addr[26:0] + 27'd3],mem3[addr[26:0] + 27'd2],
	                                   mem3[addr[26:0] + 27'd1],mem3[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd4:
                                begin
                                    {mem4[addr[26:0] + 27'd3],mem4[addr[26:0] + 27'd2],
	                                   mem4[addr[26:0] + 27'd1],mem4[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd5:
                                begin
                                    {mem5[addr[26:0] + 27'd3],mem5[addr[26:0] + 27'd2],
	                                   mem5[addr[26:0] + 27'd1],mem5[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd6:
                                begin
                                    {mem6[addr[26:0] + 27'd3],mem6[addr[26:0] + 27'd2],
	                                   mem6[addr[26:0] + 27'd1],mem6[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd7:
                                begin
                                    {mem7[addr[26:0] + 27'd3],mem7[addr[26:0] + 27'd2],
	                                   mem7[addr[26:0] + 27'd1],mem7[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd8:
                                begin
                                    {mem8[addr[26:0] + 27'd3],mem8[addr[26:0] + 27'd2],
	                                   mem8[addr[26:0] + 27'd1],mem8[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd9:
                                begin
                                    {mem9[addr[26:0] + 27'd3],mem9[addr[26:0] + 27'd2],
	                                   mem9[addr[26:0] + 27'd1],mem9[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd10:
                                begin
                                    {mem10[addr[26:0] + 27'd3],mem10[addr[26:0] + 27'd2],
	                                   mem10[addr[26:0] + 27'd1],mem10[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd11:
                                begin
                                    {mem11[addr[26:0] + 27'd3],mem11[addr[26:0] + 27'd2],
	                                   mem11[addr[26:0] + 27'd1],mem11[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd12:
                                begin
                                    {mem12[addr[26:0] + 27'd3],mem12[addr[26:0] + 27'd2],
	                                   mem12[addr[26:0] + 27'd1],mem12[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd13:
                                begin
                                    {mem13[addr[26:0] + 27'd3],mem13[addr[26:0] + 27'd2],
	                                   mem13[addr[26:0] + 27'd1],mem13[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd14:
                                begin
                                    {mem14[addr[26:0] + 27'd3],mem14[addr[26:0] + 27'd2],
	                                   mem14[addr[26:0] + 27'd1],mem14[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd15:
                                begin
                                    {mem15[addr[26:0] + 27'd3],mem15[addr[26:0] + 27'd2],
	                                   mem15[addr[26:0] + 27'd1],mem15[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd16:
                                begin
                                    {mem16[addr[26:0] + 27'd3],mem16[addr[26:0] + 27'd2],
	                                   mem16[addr[26:0] + 27'd1],mem16[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd17:
                                begin
                                    {mem17[addr[26:0] + 27'd3],mem17[addr[26:0] + 27'd2],
	                                   mem17[addr[26:0] + 27'd1],mem17[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd18:
                                begin
                                    {mem18[addr[26:0] + 27'd3],mem18[addr[26:0] + 27'd2],
	                                   mem18[addr[26:0] + 27'd1],mem18[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd19:
                                begin
                                    {mem19[addr[26:0] + 27'd3],mem19[addr[26:0] + 27'd2],
	                                   mem19[addr[26:0] + 27'd1],mem19[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd20:
                                begin
                                    {mem20[addr[26:0] + 27'd3],mem20[addr[26:0] + 27'd2],
	                                   mem20[addr[26:0] + 27'd1],mem20[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd21:
                                begin
                                    {mem21[addr[26:0] + 27'd3],mem21[addr[26:0] + 27'd2],
	                                   mem21[addr[26:0] + 27'd1],mem21[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd22:
                                begin
                                    {mem22[addr[26:0] + 27'd3],mem22[addr[26:0] + 27'd2],
	                                   mem22[addr[26:0] + 27'd1],mem22[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd23:
                                begin
                                    {mem23[addr[26:0] + 27'd3],mem23[addr[26:0] + 27'd2],
	                                   mem23[addr[26:0] + 27'd1],mem23[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd24:
                                begin
                                    {mem24[addr[26:0] + 27'd3],mem24[addr[26:0] + 27'd2],
	                                   mem24[addr[26:0] + 27'd1],mem24[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd25:
                                begin
                                    {mem25[addr[26:0] + 27'd3],mem25[addr[26:0] + 27'd2],
	                                   mem25[addr[26:0] + 27'd1],mem25[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd26:
                                begin
                                    {mem26[addr[26:0] + 27'd3],mem26[addr[26:0] + 27'd2],
	                                   mem26[addr[26:0] + 27'd1],mem26[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd27:
                                begin
                                    {mem27[addr[26:0] + 27'd3],mem27[addr[26:0] + 27'd2],
	                                   mem27[addr[26:0] + 27'd1],mem27[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd28:
                                begin
                                    {mem28[addr[26:0] + 27'd3],mem28[addr[26:0] + 27'd2],
	                                   mem28[addr[26:0] + 27'd1],mem28[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd29:
                                begin
                                    {mem29[addr[26:0] + 27'd3],mem29[addr[26:0] + 27'd2],
	                                   mem29[addr[26:0] + 27'd1],mem29[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd30:
                                begin
                                    {mem30[addr[26:0] + 27'd3],mem30[addr[26:0] + 27'd2],
	                                   mem30[addr[26:0] + 27'd1],mem30[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd31:
                                begin
                                    {mem31[addr[26:0] + 27'd3],mem31[addr[26:0] + 27'd2],
	                                   mem31[addr[26:0] + 27'd1],mem31[addr[26:0]]}<= memctrl_mem_write_data;
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                            endcase // case (addr[31:27])
                        end
                    end // case: `MEM_STATE_WRITE
                    `MEM_STATE_READ0:
                      begin
                          state <= `MEM_STATE_READ1;
                          word_count <= 'd0;
                          
                      end
                    
                  `MEM_STATE_READ1:
                    begin
                        if(word_count < word_number1)
                          begin
                              case(addr[31:27])
                              'd0:
                                begin
                                    mem_memctrl_read_data <= {mem0[addr[26:0] + 27'd3],mem0[addr[26:0] + 27'd2],
	                                   mem0[addr[26:0] + 27'd1],mem0[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                    
                                end
                              'd1:
                                begin
                                    mem_memctrl_read_data  <= {mem1[addr[26:0] + 27'd3],mem1[addr[26:0] + 27'd2],
	                                   mem1[addr[26:0] + 27'd1],mem1[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd2:
                                begin
                                    mem_memctrl_read_data  <= {mem2[addr[26:0] + 27'd3],mem2[addr[26:0] + 27'd2],
	                                   mem2[addr[26:0] + 27'd1],mem2[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                    end 
                                
                              'd3:
                                begin
                                    mem_memctrl_read_data  <= {mem3[addr[26:0] + 27'd3],mem3[addr[26:0] + 27'd2],
	                                   mem3[addr[26:0] + 27'd1],mem3[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd4:
                                begin
                                    mem_memctrl_read_data  <= {mem4[addr[26:0] + 27'd3],mem4[addr[26:0] + 27'd2],
	                                   mem4[addr[26:0] + 27'd1],mem4[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd5:
                                begin
                                    mem_memctrl_read_data  <= {mem5[addr[26:0] + 27'd3],mem5[addr[26:0] + 27'd2],
	                                   mem5[addr[26:0] + 27'd1],mem5[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd6:
                                begin
                                    mem_memctrl_read_data  <=  {mem6[addr[26:0] + 27'd3],mem6[addr[26:0] + 27'd2],
	                                   mem6[addr[26:0] + 27'd1],mem6[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd7:
                                begin
                                    mem_memctrl_read_data  <= {mem7[addr[26:0] + 27'd3],mem7[addr[26:0] + 27'd2],
	                                   mem7[addr[26:0] + 27'd1],mem7[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd8:
                                begin
                                    mem_memctrl_read_data  <= {mem8[addr[26:0] + 27'd3],mem8[addr[26:0] + 27'd2],
	                                   mem8[addr[26:0] + 27'd1],mem8[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd9:
                                begin
                                    mem_memctrl_read_data  <= {mem9[addr[26:0] + 27'd3],mem9[addr[26:0] + 27'd2],
	                                   mem9[addr[26:0] + 27'd1],mem9[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd10:
                                begin
                                    mem_memctrl_read_data  <={mem10[addr[26:0] + 27'd3],mem10[addr[26:0] + 27'd2],
	                                   mem10[addr[26:0] + 27'd1],mem10[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd11:
                                begin
                                    mem_memctrl_read_data  <={mem11[addr[26:0] + 27'd3],mem11[addr[26:0] + 27'd2],
	                                   mem11[addr[26:0] + 27'd1],mem11[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd12:
                                begin
                                    mem_memctrl_read_data <= {mem12[addr[26:0] + 27'd3],mem12[addr[26:0] + 27'd2],
	                                   mem12[addr[26:0] + 27'd1],mem12[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd13:
                                begin
                                    mem_memctrl_read_data  <={mem13[addr[26:0] + 27'd3],mem13[addr[26:0] + 27'd2],
	                                   mem13[addr[26:0] + 27'd1],mem13[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd14:
                                begin
                                    mem_memctrl_read_data  <={mem14[addr[26:0] + 27'd3],mem14[addr[26:0] + 27'd2],
	                                   mem14[addr[26:0] + 27'd1],mem14[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd15:
                                begin
                                    mem_memctrl_read_data  <={mem15[addr[26:0] + 27'd3],mem15[addr[26:0] + 27'd2],
	                                   mem15[addr[26:0] + 27'd1],mem15[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd16:
                                begin
                                    mem_memctrl_read_data  <={mem16[addr[26:0] + 27'd3],mem16[addr[26:0] + 27'd2],
	                                   mem16[addr[26:0] + 27'd1],mem16[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd17:
                                begin
                                    mem_memctrl_read_data  <={mem17[addr[26:0] + 27'd3],mem17[addr[26:0] + 27'd2],
	                                   mem17[addr[26:0] + 27'd1],mem17[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd18:
                                begin
                                    mem_memctrl_read_data  <={mem18[addr[26:0] + 27'd3],mem18[addr[26:0] + 27'd2],
	                                   mem18[addr[26:0] + 27'd1],mem18[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd19:
                                begin
                                    mem_memctrl_read_data  <={mem19[addr[26:0] + 27'd3],mem19[addr[26:0] + 27'd2],
	                                   mem19[addr[26:0] + 27'd1],mem19[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd20:
                                begin
                                    mem_memctrl_read_data  <={mem20[addr[26:0] + 27'd3],mem20[addr[26:0] + 27'd2],
	                                   mem20[addr[26:0] + 27'd1],mem20[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd21:
                                begin
                                    mem_memctrl_read_data  <={mem21[addr[26:0] + 27'd3],mem21[addr[26:0] + 27'd2],
	                                   mem21[addr[26:0] + 27'd1],mem21[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd22:
                                begin
                                    mem_memctrl_read_data  <={mem22[addr[26:0] + 27'd3],mem22[addr[26:0] + 27'd2],
	                                   mem22[addr[26:0] + 27'd1],mem22[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd23:
                                begin
                                    mem_memctrl_read_data  <={mem23[addr[26:0] + 27'd3],mem23[addr[26:0] + 27'd2],
	                                   mem23[addr[26:0] + 27'd1],mem23[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd24:
                                begin
                                    mem_memctrl_read_data  <={mem24[addr[26:0] + 27'd3],mem24[addr[26:0] + 27'd2],
	                                   mem24[addr[26:0] + 27'd1],mem24[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd25:
                                begin
                                    mem_memctrl_read_data  <={mem25[addr[26:0] + 27'd3],mem25[addr[26:0] + 27'd2],
	                                   mem25[addr[26:0] + 27'd1],mem25[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd26:
                                begin
                                    mem_memctrl_read_data  <= {mem26[addr[26:0] + 27'd3],mem26[addr[26:0] + 27'd2],
	                                   mem26[addr[26:0] + 27'd1],mem26[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd27:
                                begin
                                    mem_memctrl_read_data  <={mem27[addr[26:0] + 27'd3],mem27[addr[26:0] + 27'd2],
	                                   mem27[addr[26:0] + 27'd1],mem27[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd28:
                                begin
                                    mem_memctrl_read_data  <={mem28[addr[26:0] + 27'd3],mem28[addr[26:0] + 27'd2],
	                                   mem28[addr[26:0] + 27'd1],mem28[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd29:
                                begin
                                    mem_memctrl_read_data  <={mem29[addr[26:0] + 27'd3],mem29[addr[26:0] + 27'd2],
	                                   mem29[addr[26:0] + 27'd1],mem29[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd30:
                                begin
                                    mem_memctrl_read_data  <={mem30[addr[26:0] + 27'd3],mem30[addr[26:0] + 27'd2],
	                                   mem30[addr[26:0] + 27'd1],mem30[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                              'd31:
                                begin
                                    mem_memctrl_read_data  <={mem31[addr[26:0] + 27'd3],mem31[addr[26:0] + 27'd2],
	                                   mem31[addr[26:0] + 27'd1],mem31[addr[26:0]]};
	                                  addr <= addr + 'd4;
                                    word_count <= word_count + 'd1;
                                end
                            endcase // case (addr[31:27])
                              
                          end
                        else
                          begin
                              state <= `MEM_STATE_IDLE;
                              
                          end 
                  end
                  endcase // case (state)
                end // else: !if(resetn == `RESET_ENABLE)
        end // always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
    

endmodule
