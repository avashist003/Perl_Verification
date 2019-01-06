module chkrpl (
	clk,
	reset,
	d_in,
	d_out,
	test_mode,
	scan_in0,
	scan_en,
	scan_out0
	);

input clk;
input reset;

input [3:0] d_in;

output [3:0] d_out;

input scan_in0;
input scan_en;
input test_mode;

output scan_out0;

reg [3:0] rStage0; 
reg [3:0] rStage1; 
reg [3:0] rStage2; 

assign d_out = rStage2;

always@(posedge clk, posedge reset)
begin
    if(reset)
    begin
	rStage0 <= 10;
	rStage1 <= 10;
	rStage2 <= 10;
    end
    else
    begin
	rStage0 <= d_in;
	rStage1 <= rStage0;
	rStage2 <= rStage1;
    end
end
endmodule
