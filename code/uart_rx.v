`include "./bus_arbiter_head.v"
`include "./controller_head.v"
`include "./memory_head.v"
`include "./uart_head.v"
`include "./general_head.v"
module uart_rx(
               input [`WordNumberBit] word_number1,//uart控制器传来的需要传输的字的个数
               input                  rx, //mem control传来的串行数据
               input                  clk, resetn,
               output reg                uart_master_write_ready,
               output reg [`WordWidth] uart_master_data,
               output reg uart_master_write_stop
);
    reg [`DivCntWidth] div_cnt; //定义分频计数器
  reg [`UartStateBit]   state;//定义uart控制器的状态
    reg [`FifoDataWidth]         fifo  [`FifoTxDepth];//定义FIFO缓冲器按字节存储
   
 initial
      begin
          $readmemb("fifo.txt",fifo,0,15); 
      end
   // reg [`ShiftRegWidth]       sh_reg ;//定义移位寄存器    
    reg [`CountBit]            fifo_count;//定义计数器和FIFO的写入索引
    wire  [`CountBit]                fifo_count_limit;//定义计数器和FIFO的写入索引
     integer  signed  bit_cnt;
assign fifo_count_limit = {`LEAVE_BIT,word_number1} << 'd2;
    /*根据仲裁器传来的字的个数求出fifo中需要写入的字节数，即字的个数乘以4*/

    always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
      begin
	        if (resetn == `RESET_ENABLE ) //异步复位时初始化状态
	          begin
		           state <= `UART_TX_IDLE;
		            div_cnt <= `UART_DIV_RATE/'d2;
                bit_cnt <= `UART_BIT_CNT_START;
                fifo_count <= 'd0;
	          end
	        else begin
		          case (state)
			          `UART_TX_IDLE : //控制器处于闲置状态时将计数器和索引初始化，如果收到从属发送来的准备写信号ready并且
                  begin
                      uart_master_write_ready <= `UART_MASTER_WRITE_READY_DISABLE;
                      uart_master_write_stop <= `UART_MASTER_WRITE_STOP_DISABLE;
                      
		              div_cnt <= `UART_DIV_RATE/'d2;
                      bit_cnt <= `UART_BIT_CNT_START;
                      fifo_count <= 'd0;
                      if (rx == `RX_START_BIT)
	                      begin
			                      state <= `UART_STATE_READ;
	                      end
                  end 
                `UART_STATE_READ:
		              begin
  				            if (fifo_count >= fifo_count_limit )
  				              begin
  					                state <= `UART_STATE_FIFO_RECEIVER1 ;
                            fifo_count <= 'd0;
                            uart_master_write_ready <= `UART_MASTER_WRITE_READY_ENABLE;
                            
  				              end else
  				                begin
  					                  if(div_cnt == {`DIV_CNT_WIDTH{1'b0}})//如果分频计数器计数完成（倒数）
			                  begin
                            case (bit_cnt)
						                  'd7:
						                    begin//按比特接收，采用移位实现加载一个字节，从最低位开始接收每接收一个比特向右移一个比特
                                    fifo[fifo_count] <= {rx, fifo[fifo_count][7:1]};
						           	           fifo_count <= fifo_count + 'd1;
                                    bit_cnt <= (-1);
             
						                    end 
                              default:
						                    begin
						           	            fifo[fifo_count] <= {rx, fifo[fifo_count][7:1]};
						           	            bit_cnt <= bit_cnt + 'd1;
                                    div_cnt <= `UART_DIV_RATE/'d2;
						                    end 
                            endcase 
                        end else
			                    begin
				                      div_cnt <= #1 div_cnt - 1'b1;
                          end 
                  end
          end // case: `MEM_CONTRON_STATE_WRITE_BUFFER
      /*  `UART_STATE_FIFO_RECEIVER0: //mem这个周期接收的数据是下一个周期显示的数据所以发送方中间空一个周期
          begin
              state <= `UART_STATE_FIFO_RECEIVER1;

          end */ 
      `UART_STATE_FIFO_RECEIVER1:
      begin//每个周期发送一个32比特的数据
        if (fifo_count < fifo_count_limit)
        begin
          uart_master_data <= {fifo[fifo_count + 'd3],fifo[fifo_count + 'd2],fifo[fifo_count + 'd1], fifo[fifo_count]};
            fifo_count <= fifo_count + 'd4;
        end else //发送完成之后状态跳转至闲置状态
          begin
              state <= `UART_STATE_IDLE;
              fifo_count <= 'd0;
              uart_master_write_stop <= `UART_MASTER_WRITE_STOP_ENABLE;
          end
          
      end // case: `UART_STATE_FIFO_RECEIVER1
              endcase // case (state)
          end // else: !if(resetn == `RESET_ENABLE )
      end // always @ (`CLK_EDGE clk or `RESET_EDGE resetn)
    
endmodule // uart_rx

