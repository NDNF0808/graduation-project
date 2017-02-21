`include "./general_head.v"
module resetn(	input clk, reset,
				        output reg resetn);
    reg                    a1;//采用异步复位同步释放的reset信号
    always @ (posedge clk, `RESET_EDGE reset)//生成异步复位同步释放的resetn信号
      begin
	        if(reset == `RESET_ENABLE)
	          begin
		            a1 <= 1'b0;
		            resetn <= 1'b0;
	          end else
	            begin 
		              a1 <= 1'b1;
		              resetn <= a1;
	            end 
      end
endmodule // resetn
