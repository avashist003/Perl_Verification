
/*
 *
 *
 */


module digit_reg (
    reset,
    clk,
    in,
    out,
    scan_in0,
    scan_en,
    scan_out0
    ) ;
 
input
    reset,                // system reset
    clk ;                 // write strobe

input [7:0]
    in ;                  // data input

output [7:0]
    out ;                 // data output

input
    scan_in0,             // test scan mode data input
    scan_en;              // test scan mode enable

output
    scan_out0;            // test scan mode data output

reg [7:0]
    out ;

always @(posedge clk or posedge reset)
    if (reset)
        begin
        out <= 8'h0 ;
        end
    else
        begin
        out <= in ;
        end
        
endmodule // digit_reg
