`include"./bus_arbiter_head.v"
`include "./memory_head.v"
`include "./general_head.v"
`include "./uart_head.v"
module memory_control( input tx, //输入UART传来的串行数据
					input                   clk, resetn,//输入时钟与复位信号
          input [`WordNumberBit]  word_number1,//输入uart传来的字个数信号
          input  mem_memctrl_write_ready,//mem传来的写准备信号
          input [`WordWidth] mem_memctrl_read_data,
          output reg              memctrl_mem_write_start, //memcontrol传输给mem写的开始信号
          output reg [`WordWidth] memctrl_mem_write_data ,//buffer传输给mem的写的数据
          output reg rx //向uart发送串行数据
	);
    reg [`DivCntWidth]           div_cnt; //定义分频计数器
  reg [`ShiftRegWidth]       sh_reg ;//定义移位寄存器   
	reg [`MemControlStateBit] state;
    reg [`MemBufferWidth]         mem_buffer  [`MemBufferDepth ];//mem buffer也是按字节存储，这样接收的时候可以和uart同时钟
 //   reg signed  [`MemBufferCountWidth ]   mem_buffer_count;
//wire [`MemBufferCountWidth] mem_buffer_limit; //定义mem buffer计数器
   // assign mem_buffer_limit = {`LEAVE_BIT,word_number1} << 'd2;
    reg signed [31:0]             mem_buffer_count;
wire signed [31:0] mem_buffer_limit;
    assign mem_buffer_limit = {27'b0,word_number1} << 'd2;
    
    initial
    begin
    	$readmemh("mem_buffer.txt", mem_buffer,0,`MemBufferDepthMsb);
    end
    integer  signed  bit_cnt;
  always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
  begin
  	if (resetn == `RESET_ENABLE ) //异步复位时初始化状态
  	begin
  		state <= `MEM_CONTRON_STATE_IDLE;
  		mem_buffer_count <= 'd0;
      memctrl_mem_write_start <= `MEMCTRL_MEM_WRITE_START_DISABLE ;
  		div_cnt <= `UART_DIV_RATE;
  		bit_cnt <= 'd0;
       rx <= `RX_STOP_BIT; 
  	end else
  	begin
  		case (state)
  			`MEM_CONTRON_STATE_IDLE: //只需要控制idle状态像下一个状态转换的条件即可，也就是说，传来tx_start的模块在空闲状态时一定得让tx_start无效。
  			  begin
             mem_buffer_count <= 'd0;
              memctrl_mem_write_start <= `MEMCTRL_MEM_WRITE_START_DISABLE;
              div_cnt <= `UART_DIV_RATE;
              bit_cnt <= 'd0; 
               rx <= `RX_STOP_BIT; 
  				    if (tx == `TX_START_BIT)
  				     begin 
  					       state <= `MEM_CONTRON_STATE_WRITE_BUFFER;
               end 
               else if (mem_memctrl_write_ready == `MEM_MEMCTRL_WRITE_READY_ENABLE)
               begin
                state <= `MEM_CONTROL_STATE_READ_MEM;
                   mem_buffer_count <= mem_buffer_count - 'd4;
                   
                 div_cnt <= `UART_DIV_RATE/2;
               end 
          end 
  			`MEM_CONTRON_STATE_WRITE_BUFFER:
  			  begin
  				    if (mem_buffer_count >= mem_buffer_limit )
  				      begin
  					        state <= `MEM_CONTRON_STATE_BUFFER_MEM0;
                    mem_buffer_count <= `MEM_BUFFER_COUNT_INIT;
                    memctrl_mem_write_start <= `MEMCTRL_MEM_WRITE_START_ENABLE;
  				      end else
  				        begin
  					          if(div_cnt == {`DIV_CNT_WIDTH{1'b0}})//如果分频计数器计数完成（倒数）
			                  begin
                            case (bit_cnt)
						                  'd7:
						                    begin//按比特接收，采用移位实现加载一个字节，从最低位开始接收每接收一个比特向右移一个比特
                                    mem_buffer[mem_buffer_count] <= {tx,mem_buffer[mem_buffer_count][7:1]};
						           	            mem_buffer_count <= mem_buffer_count + 'd1;
                                    bit_cnt <= (-1);
             
						                    end 
                              default:
						                    begin
						           	            mem_buffer[mem_buffer_count] <= {tx,mem_buffer[mem_buffer_count][7:1]};
						           	            bit_cnt <= bit_cnt + 'd1;
                                    div_cnt <= `UART_DIV_RATE;
						                    end 
                            endcase 
                        end else
			                    begin
				                      div_cnt <= #1 div_cnt - 1'b1;
                          end 
                  end
          end // case: `MEM_CONTRON_STATE_WRITE_BUFFER
        `MEM_CONTRON_STATE_BUFFER_MEM0: //mem这个周期接收的数据是下一个周期显示的数据所以发送方中间空一个周期
          begin
              state <= `MEM_CONTRON_STATE_BUFFER_MEM1;
              
              memctrl_mem_write_start <= `MEMCTRL_MEM_WRITE_START_DISABLE;//禁止mem状态再跳转到接收状态
          end  
      `MEM_CONTRON_STATE_BUFFER_MEM1:
      begin//每个周期发送一个32比特的数据
        if (mem_buffer_count < mem_buffer_limit)
        begin
            memctrl_mem_write_data <= {mem_buffer[mem_buffer_count + 'd3],mem_buffer[mem_buffer_count + 'd2],mem_buffer[mem_buffer_count + 'd1], mem_buffer[mem_buffer_count]};
            mem_buffer_count <= mem_buffer_count + 'd4;
        end else //发送完成之后状态跳转至闲置状态
          begin
              state <= `MEM_CONTRON_STATE_IDLE;
              mem_buffer_count <= 'd0;
          end
          
      end
      `MEM_CONTROL_STATE_READ_MEM:
        begin
          if (mem_buffer_count < mem_buffer_limit)
          begin
            {mem_buffer[mem_buffer_count + 'd3],mem_buffer[mem_buffer_count + 'd2]
            ,mem_buffer[mem_buffer_count + 'd1], mem_buffer[mem_buffer_count]} <=
            mem_memctrl_read_data; 
             mem_buffer_count <= mem_buffer_count + 'd4;
          end
          else
          begin
            state <= `MEM_CONTROL_STATE_BUFFER_UART0;
            mem_buffer_count <= 'd0;
          end 
        
      end 
 `MEM_CONTROL_STATE_BUFFER_UART0 :
   begin
       if(mem_buffer_count == 'd0)
         begin
             rx <= `RX_START_BIT;
         end 
                      
                      if(mem_buffer_count < mem_buffer_limit )//buffer中还有数据
                        begin
                           sh_reg <= mem_buffer[mem_buffer_count];
                                  state <= `MEM_CONTROL_STATE_BUFFER_UART1;
                                  
                                   mem_buffer_count<= mem_buffer_count + 'd1;
                        end
                      else //发送完成后状态回到闲置状态
                        begin
                            state <= `MEM_CONTRON_STATE_IDLE;
                        
                        end 
                  end
                `MEM_CONTROL_STATE_BUFFER_UART1:  
                  begin
                      if(div_cnt == {`DIV_CNT_WIDTH{1'b0}})//如果分频计数器计数完成（倒数）
                        begin
                            case (bit_cnt)
                              `UART_BIT_CNT_STOP:
                                begin
                                    state <= `MEM_CONTROL_STATE_BUFFER_UART0;
                                    bit_cnt <= 1'b0;
                                    
                                end 
                              default:
                                begin
                                    bit_cnt <= bit_cnt + 'd1;
                                    sh_reg <= sh_reg >> 1'b1;
                                    rx <= sh_reg[0];
                                end
                            endcase // bit_cnt
                            div_cnt <= `UART_DIV_RATE /2;
                        end else
                          begin
                              div_cnt <= #1 div_cnt - 1'b1;
                              
                          end
                  end 


      endcase
    end
  end
endmodule // mem_control

