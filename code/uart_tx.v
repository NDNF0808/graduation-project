`include "./memory_head.v"
`include "./general_head.v"
`include "./bus_arbiter_head.v"
`include "./uart_head.v"
//`include "D:/IFMRT/graduation-project/code/uart_head.v"
//`include "D:/IFMRT/graduation-project/code/general_head.v"
module uart_tx(input  rw1, master_uart_write_ready1, clk,resetn,//接收uart控制器发来的选通信号，
	                   //读写信号，准备写信号，时钟，复位信号
					           input [`BusDataWidth]         master_uart_write_data1,//接收uart控制器发来的数据
					           input [`WordNumberBit]        word_number1,//uart控制器传来的需要传输的字的个数
					           output reg                    tx,bus_error//如果基偶校验失败将bus_error传给主控
					          					           );
    reg [`UartStateBit]   state;//定义uart控制器的状态
    reg [`FifoDataWidth]         fifo  [`FifoDepth];//定义FIFO缓冲器按字节存储
    initial
      begin
          $readmemb("fifo.txt",fifo,0,15); 
      end
    
    reg [`DivCntWidth]           div_cnt; //定义分频计数器
    reg [`ShiftRegWidth]       sh_reg ;//定义移位寄存器    
    reg [`CountBit]            fifo_count;//定义计数器和FIFO的写入索引
    wire  [`CountBit]                fifo_count_limit;//定义计数器和FIFO的写入索引
     integer  signed  bit_cnt;
assign fifo_count_limit = {`LEAVE_BIT,word_number1} << 'd2;
    /*根据仲裁器传来的字的个数求出fifo中需要写入的字节数，即字的个数乘以4*/

    always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
      begin
	        if (resetn == `RESET_ENABLE ) //异步复位时初始化状态
	          begin
		           state <= `UART_STATE_IDLE;
		            bus_error <= `BUS_ERROR_DISABLE;
		            div_cnt <= `UART_DIV_RATE;
                bit_cnt <= `UART_BIT_CNT_START;
                sh_reg <= `SHIFT_REG_INIT;
                tx <= `TX_STOP_BIT;

           //    uart_memctrl_write_ready <= `UART_MEMCTRL_WRITE_READY_DISABLE;
                fifo_count <= 'd0;
	          end
	        else begin
		          case (state)
			          `UART_STATE_IDLE : //控制器处于闲置状态时将计数器和索引初始化，如果收到从属发送来的准备写信号ready并且
									//检测到数据中的最低位是开始位就开始接收即进入接收状态
                  begin
                      bus_error <= `BUS_ERROR_DISABLE;
		              div_cnt <= `UART_DIV_RATE;
                      bit_cnt <= `UART_BIT_CNT_START;
                      sh_reg <= `SHIFT_REG_INIT;
                      tx <= `TX_STOP_BIT;
    //   uart_memctrl_write_ready <= `UART_MEMCTRL_WRITE_READY_DISABLE;
                      
                      fifo_count <= 'd0;
                      
    

				              if(rw1 == `RW_WRITE &&  master_uart_write_ready1 == `MASTER_UART_WRITE_READY_ENABLE)
                        //先发送master_slave_ready下个周期开始发送数据
				                begin
					                  state = `UART_STATE_WRITE_FIFO;
				                end 
				         end
			          `UART_STATE_WRITE_FIFO://每个时钟到来时接收一个数据并写入FIFO缓冲器
			            begin  //确保每次时钟上升沿到来时新的数据已经到达
				              if(^master_uart_write_data1 == 1'b0)//偶校验正确
				                begin
					                  if(fifo_count < fifo_count_limit)
                                      begin
                                      	{fifo[fifo_count+'d3],
                                      	fifo[fifo_count+'d2],
                                      	fifo[fifo_count+'d1],
                                      	fifo[fifo_count]} 
                                      	<= master_uart_write_data1[`FifoWriteBit];
						                state <= `UART_STATE_WRITE_FIFO ;
						                fifo_count  <= fifo_count + 'd4;
                                     end else
                                     begin
                                        state = `UART_STATE_FIFO_TRANSMITTER0;
						                             fifo_count = 'd0;
				            	     end 
                                end 
 //收到结束位后跳转至给发送模块传数据状态，由于发送模块也是计数，所以初始化count和i
					            else//基偶校验有错误则回到闲置状态，并且发送给主控bue error错误
				                begin
					                  bus_error <= `BUS_ERROR_ENABLE;
		    		                state <= `UART_STATE_IDLE;
				                end 
			            end


		            `UART_STATE_FIFO_TRANSMITTER0://将传输阶段分成两个状态，
		              //第一个状态将FIFO的数据8bit传至移位寄存器，第二个状态将移位寄存器的数串行传输
                  //所以一个数据需要传输4次
			            begin
                 //    uart_memctrl_write_ready <= `UART_MEMCTRL_WRITE_READY_ENABLE;
                      if(fifo_count == 'd0)
                        begin
                      tx <= `TX_START_BIT;
                        end
				              if(fifo_count < fifo_count_limit )//fifo中还有数据
				                begin
					                 sh_reg <= fifo[fifo_count];
						                      state <= `UART_STATE_FIFO_TRANSMITTER1;
						                      
						                        fifo_count <= fifo_count + 'd1;
                        end
                      else //发送完成后状态回到闲置状态
				                begin
					                  state <= `UART_STATE_IDLE;
					              
				                end 
			            end
		            `UART_STATE_FIFO_TRANSMITTER1:	
		              begin
			                if(div_cnt == {`DIV_CNT_WIDTH{1'b0}})//如果分频计数器计数完成（倒数）
			                  begin
				                    case (bit_cnt)
					                    `UART_BIT_CNT_STOP:
					                      begin
                                    state <= `UART_STATE_FIFO_TRANSMITTER0;
                                    bit_cnt <= 1'b0;
                                    
                                end 
					                    default:
					                      begin
						                        bit_cnt <= bit_cnt + 'd1;
                                    sh_reg <= sh_reg >> 1'b1;
                                    tx <= sh_reg[0];
                                end
				                    endcase // bit_cnt
				                    div_cnt <= `UART_DIV_RATE;
                        end else
			                    begin
				                      div_cnt <= #1 div_cnt - 1'b1;
                              
			                    end
		              end 
		             		  endcase
	        end // else: !if(resetn == `RESET_ENABLE )
      end 
endmodule // uart_control
