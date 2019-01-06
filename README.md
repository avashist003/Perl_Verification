# Perl_Verification
Perl program which generates synthesizable Verilog® HDL, and a self-checking testbench, for a multistage pipeline register. The code is documented using perldoc.

# Description
- The perl script av8911.pl takes input argument either from command line or from a user created parameter file.
- Passing both will result in an error and missing any mandatory arguments will also result in an error.

# Arguments
- Param : This takes parameter file name as an argument.
- Width : This specifies the size of the input and output of the pipelined register. User should specify the size within the range of (1-64) bits.
- Stages : This specifies the number of pipeline stages of the pipelined register.User should specify the size within the range of 2-128 stages
- Reset : This specifies the reset value to which the registers are initialized when reset signal is asserted. Either a decimal\(nn) or hexadecimal \(0xnn) value is passed.
- Outfile : This specifies the file name of the generated verilog and testbench file

# Usage of the Perl Script

perl av8911.pl --width 3 --stages 2 --reset 0 --outfile test_1.v

perl av8911.pl --stages 4 --reset 0xfff --outfile test_2.v --width 12

perl av8911.pl --param file.param

perl av8911.pl --help
