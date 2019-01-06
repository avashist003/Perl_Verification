#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $pl_exe = <<"end_exe";

Program usage:

    --param
    --width
    --stages
    --reset
    --outfile
    --help

User must pass Either a parameter file including all the mandatory arguments using "--param" OR "--width", "--stages", "--reset" and "-outfile". Passing BOTH parameter file and command line arguments, or skipping mandatory options is an error.

end_exe

# declare variables using my() to resolve global symbol issue. As we are using strict
#
my $help_v;
my $param_v;
my $width_v;
my $stages_v;
my $reset_v;
my $outfile_v;

# get inputs from command line
# no spaces betwen the names in getoption, "help=s" NOT "help = s" else we will have syntax error
GetOptions("help" => \$help_v,
	   "param=s" =>\$param_v,
	   "width=i" => \$width_v,
	   "stages=i" => \$stages_v,
	   "reset=s" => \$reset_v,
	   "outfile=s" => \$outfile_v,
	  );

#print"$outfile_v";
# subroutine to verify the user entered command line options are valid or not asper the project requirement
usr_cmd();

# subroutine to get arguments from parameter file
param_file();

# convert the reset from hex to decimal if input is from command line
if(!defined $param_v)
{
        if($reset_v =~ m/0x/)
        {
                (my $reset_v_hexa) = $reset_v =~ m/(\w+)/;
                my $reset_v_conv = hex ($reset_v_hexa);
		$reset_v = $reset_v_conv;

		# debug print statements
                #print"reset hex = $reset_v_hexa\n";
                #print"reset dec convert = $reset_v\n";
        }
            elsif($reset_v =~ m/(\d+)/)
                {
                    $reset_v = $1;
                    #print "reset is $reset_v\n";
                }
}

if(!defined $param_v)
{
    if(!defined $width_v)
    {
	die("width not defined\n$pl_exe\n");
    }
    elsif(!defined $stages_v)
    {
	die("stages not defined\n$pl_exe\n");
    }
    elsif(!defined $reset_v)
    {
	die("reset value not defined\n$pl_exe\n");
    }
}


# check if the arguments are within the given bounds
usr_bound();

sub usr_cmd {
    if($help_v)
    {
	#exec 'perldoc av8911.pl';
        die("$pl_exe\n");
    }
# defined function is required to check the variable not it's value, this fixed the '0 error for the parameters

    elsif(defined $param_v &&(defined $width_v || defined $stages_v || defined $reset_v || defined $outfile_v))
    {
	die("\n Either input parameter file or command line input\n $pl_exe");
        #print"error!!!\n";
        #print $pl_exe;
    }

        elsif(!defined $param_v && (!defined $width_v && !defined $stages_v && !defined $reset_v && !defined $outfile_v))
    {
#print"$outfile_v\n";   
        die("\n $pl_exe");
    }


elsif(!defined $param_v)
{
    if(!defined $width_v)
    {
        die("\nwidth not defined\n$pl_exe\n");
    }
    elsif(!defined $stages_v)
    {
        die("\nstages not defined\n$pl_exe\n");
    }
    elsif(!defined $reset_v)
    {
        die("\nreset value not defined\n$pl_exe\n");
    }
    elsif(!defined $outfile_v)
    {
	die("\noutfile not defined\n$pl_exe\n")
    }
}

}


sub param_file {
    if(defined $param_v)
    {
# '<' open file for reading, $fh is the filehandle, $param_v has the file name
    open(my $fh, "<", $param_v)
	or die("cannot open file file: $!\n");
# <> operator is used almost exclusively in while loop. It iterates over the rows in all files
#  operator =~ search if string on RHS is present in string on LHS
    while(my $row = <$fh>)
    {
	if($row =~ m/\s*help/)
	{
		#exec 'perldoc av8911.pl';
		die("$pl_exe\n");
	}
	elsif($row =~ m/\s*width\s*=\s*(\d+)/)
	{
		$width_v = $1;
		#print"width = $width_v\n";
	}
	elsif($row =~ m/\s*stages\s*=\s*(\d+)/)
	{
		$stages_v = $1;
		#print"stages = $stages_v\n";
	}
	elsif($row =~ m/\s*reset\s*=\s*0x/)
	{
		(my $reset_v_hexa) = $row =~ m/\s*reset\s*=\s*(\w+)/;
		$reset_v = hex ($reset_v_hexa);

		#print"reset hex = $reset_v_hexa\n";
		#print"reset dec convert = $reset_v\n";
	}
	    elsif($row =~ m/\s*reset\s*=\s*(\d+)/)
		{
		    $reset_v = $1;
		   # print "reset is $reset_v\n";
		}
	elsif($row =~ m/\s*outfile\s*=\s*(\w+\.\w+)/)
	{
		$outfile_v = $1;
		#print"file name = $outfile_v\n";
	}
	
    }
# error if mandatory parameters are not present
    if(!defined $width_v)
    {
	die("No width mentioned\n$pl_exe");
    }
    elsif(!defined $stages_v)
   {
	die("No number of stages mentioned\n$pl_exe");
   }
   elsif(!defined $reset_v)
   {
	die("No reset value mentioned\n$pl_exe");
   }
   elsif(!defined $outfile_v)
   {
	die("No output file name mentioned\n$pl_exe");
   }

close $fh;
}
}


sub usr_bound {
   # if(!$outfile_v)
    #{
#	die("No output file\n");
 #   }
    if($outfile_v !~ m/\w+[\.]v$/)
    {
	die("wrong file extension\n $pl_exe");
    }
    elsif(($width_v < 1)|| ($width_v > 64))
    {
	die("\n width cannot be less than 1-bit and greater than 64-bits \n $pl_exe");
        #print "check bounds\n";
        #print $pl_exe;
    }
    elsif(($stages_v < 2) || ($stages_v > 128))
    {
	die("\n stages cannot be less than 2 and greater than 128\n $pl_exe");
    }
    elsif($reset_v >= 2**$width_v)
    {
	die("\nreset value exceeded the bit limit\n $pl_exe");
    }
}


#######################################################################################
# starting the verilog module
#
#mdl_verilog_head();
#mdl_verilog_body();

#mdl_test(); use this for testbench code

(my $module_name) = $outfile_v =~ /(\w+)/; # get file name without .v
#print"$module_name\n";

my $tb_outfile = $module_name."_test.v"; # testbench file
#my $tb_module_name = $module_name."_test";  # testbench module name

my $width_v_r = $width_v -1;
my $stages_v_r = $stages_v -1;

mdl_verilog_head();
mdl_verilog_body();

mdl_testbench_head();
mdl_testbench_init();
#mdl_testbench_apply();

sub mdl_verilog_head {
    open(my $fh, ">>", $outfile_v)
    or die("$pl_exe\n");

   print $fh <<EOF;
module $module_name (
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

input [$width_v_r:0] d_in;

output [$width_v_r:0] d_out;

input scan_in0;
input scan_en;
input test_mode;

output scan_out0;

EOF

    my $stg;
    for($stg = 0; $stg < $stages_v; $stg++)
    {
	print $fh "reg [$width_v_r:0] rStage$stg; \n";
    }
print $fh <<EOF;
\nassign d_out = rStage$stages_v_r;
EOF

close($fh);
} #///////////end of mdl_verilog_head


sub mdl_verilog_body {
    open(my $fh,">>", $outfile_v)
    or die("$pl_exe\n");

    print $fh <<EOF; 
\nalways@(posedge clk, posedge reset)
begin
    if(reset)
    begin
EOF

	my $stg = 0;
	for($stg = 0; $stg < $stages_v; $stg++)
	{
		print $fh "\trStage$stg <= $reset_v;\n";
	}
	
    print $fh <<EOF;
    end
    else
    begin
EOF

	$stg = 0;
	print $fh "\trStage$stg <= d_in;\n";

	my $jstg = 0;
	for($stg = 1; $stg < $stages_v; $stg++)
	{
		print $fh "\trStage$stg <= rStage$jstg;\n";
		$jstg++;
	}
    print $fh <<EOF; 
    end
end
endmodule
EOF

close $fh;

} #///// end of mdl_verilog_body


sub mdl_testbench_head {
    open(my $fh, ">>", $tb_outfile)
    or die("$pl_exe\n");
    my $test_input ="$stages_v"*100;

    print $fh <<EOF;
module test();

// declare 
reg clk_tb;
reg rst_tb;
reg [$width_v_r:0] d_in_tb;

reg scan_in0;
reg scan_en;
reg test_mode;

wire [$width_v_r:0] d_out_tb;

wire scan_out0;

integer i;
integer j;

reg [$width_v_r:0] array_input [$test_input:0];

// instantiate DUT
$module_name top (
		.clk(clk_tb),
		.reset(rst_tb),
		.d_in(d_in_tb),
		.d_out(d_out_tb),
		.test_mode(test_mode),
		.scan_in0(scan_in0),
		.scan_en(scan_en),
		.scan_out0(scan_out0)
		);	
EOF

close $fh;
}

sub mdl_testbench_init {
    open(my $fh, ">>", $tb_outfile)
    or die("$pl_exe\n");

    my $test_input ="$stages_v"*100;
    my $sim_run = "$test_input" + 10;
    print $fh <<EOF;
initial
begin
    \$timeformat(-9, 2, "ns", 16);
`ifdef SDFSCAN

    \$sdf_annotate("sdf/$module_name\_tsmc18_scan.sdf", test.top);
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
    #3 if(d_out_tb == $reset_v)
    begin
	\$display("Reset Success out = %h, reset = $reset_v", d_out_tb);
    end
    else if (d_out_tb != $reset_v)
    begin
	\$display("Reset condition failed, out = %h reset = $reset_v", d_out_tb);
    end
    #2 rst_tb = 1'b0;

    repeat ($sim_run)
	@(posedge clk_tb);
    \$finish;
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
    repeat($test_input) begin
	d_in_tb = \$random;
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
    repeat($stages_v) begin
	@(posedge clk_tb);
    end
// output is verified for all input combinations.
    repeat($test_input) begin
	#5;
	if(array_input[j] != d_out_tb) begin
	    \$display("failed pipeline for in = %h out = %h", array_input[j], d_out_tb);
	end
	else if (array_input[j] == d_out_tb) begin
	    \$display("Successful pipeline for In = %h Out = %h", array_input[j], d_out_tb);
	end
	j = j+1;
	@(posedge clk_tb);
    end
end
endtask


endmodule

EOF
close($fh);

}

# creating manual for the project

=pod

=head1 AUTHOR

Abhishek Vashist,
Course: Complex Digital Systems Verification (EEEE-722),
RIT

=head1 PROJECT

av8911.pl - A perl script that generates a synthesizable verilog code of a pipelined shift register along with the self-testing testbench.

=head1 SYNOPSIS

B<perl av8911.pl> [B<-width>] [B<-stages>] [B<-reset>] [B<-outfile>] [B<-help>] [B<-param>]

=head1 DESCRIPTION

The perl script av8911.pl takes input argument either from command line or from a parameter file. The user should pass either the arguments from command line or via a parameter file. Passing both will casuse an error and missing on any mandatory options will also cause an error.

The width should be in the range of 1-64 bits wide, the number of pipelined stages should be between 2-128 and reset value should be within the bit limit of the width.

=head1 ARGUMENTS

=head2 B<--param>

This takes parameter file name as an argument.

=head2 B<--width>

This specifies the size of the input and output of the pipelined register. User should specify the size within the range of (1-64) bits.

=head2 B<--stages>

This specifies the number of pipeline stages of the pipelined register. User should specify the size within the range of 2-128 stages

=head2 B<--reset>

This specifies the reset value to which the registers are initialized when reset signal is asserted. Either a decimal\(nn) or hexadecimal \(0xnn) value is passed.

=head2 B<--outfile>

This specifies the file name of the generated verilog and testbench files.

=head1 USAGE

The perl scrip can be executed in the following ways:

=head3 

B<perl av8911.pl --width 3 --stages 2 --reset 0 --outfile test_1.v>

=head3 

B<perl av8911.pl --stages 4 --reset 0xfff --outfile test_2.v --width 12>

=head3 

B<perl av8911.pl --param file.param>

=head3 

B<perl av8911.pl --help>

=head1 Paramter file example

Arguments in the parameter file can be added in the following way:

=head2 example_1

=head3 width = 4;

=head3 stages = 4;

=head3 reset = 0x0;

=head3 outfile = test_1.v;

=head2 example_2

=head3 width = 8;

=head3 stages = 128;

=head3 reset = 255;

=head3 outtfile = test_2.v;

=head3 help;

=cut
