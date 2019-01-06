module test();

// declare 
reg clk_tb;
reg rst_tb;
reg [3:0] d_in_tb;

reg scan_in0;
reg scan_en;
reg test_mode;

wire [3:0] d_out_tb;

wire scan_out0;

integer i;
integer j;

reg [3:0] array_input [300:0];

// instantiate DUT
chkrpl top (
		.clk(clk_tb),
		.reset(rst_tb),
		.d_in(d_in_tb),
		.d_out(d_out_tb),
		.test_mode(test_mode),
		.scan_in0(scan_in0),
		.scan_en(scan_en),
		.scan_out0(scan_out0)
		);	
initial
begin
    $timeformat(-9, 2, "ns", 16);
`ifdef SDFSCAN

    $sdf_annotate("sdf/chkrpl_tsmc18_scan.sdf", test.top);
`endif
end

initial 
begin
    clk_tb = 1'b0;
    rst_tb = 1'b1;
    scan_in0 = 1'b0;
    scan_en = 1'b0;
    test_mode = 1'b0;
// increased the delay to check reset for netlist simulation
    #3 if(d_out_tb == 10)
    begin
	$display("Reset Success out = %h, reset = 10", d_out_tb);
    end
    else if (d_out_tb != 10)
    begin
	$display("Reset condition failed, out = %h reset = 10", d_out_tb);
    end
    #2 rst_tb = 1'b0;

    repeat (310)
	@(posedge clk_tb);
    $finish;
end

// 50 MHz clock
always
begin
 #10 clk_tb = ~clk_tb;
end

initial begin
    @(negedge clk_tb)
    fork
	task_input;
	task_check;
    join
end

// task for applying input at every negative clock edge
task task_input;
begin
    i = 0;
// number of inputs generated is 100 times the number of stages
    repeat(300) begin
	d_in_tb = $random;
	array_input[i] = d_in_tb;
	i=i+1;
	@(negedge clk_tb);
    end
end
endtask

// task for checking output
task task_check;
begin
    j=0;
// wait for positive edge clock cycles equal to number of stages before checking the output
// for first input combination. Rest output are generated every clock cyle in a pipelined fashion
    repeat(3) begin
	@(posedge clk_tb);
    end
// output is verified for all input combinations.
    repeat(300) begin
	#5;
	if(array_input[j] != d_out_tb) begin
	    $display("failed pipeline for in = %h out = %h", array_input[j], d_out_tb);
	end
	else if (array_input[j] == d_out_tb) begin
	    $display("Successful pipeline for In = %h Out = %h", array_input[j], d_out_tb);
	end
	j = j+1;
	@(posedge clk_tb);
    end
end
endtask


endmodule

