#!/usr/bin/perl
#
# $Header$
#
# $Log$
#

my %names = ();
my %cnts = ();
my $len = 0;

while ( <> ) {

	my $line = $_ ;
	$line =~ s/^\s+// ;
	$line =~ s/\s+$// ;

    if ( $line =~ /^Author:\s+(.+)\s+<(.+)>/ ) {

		my $name = $1 ;
		my $email = $2 ;

		if ((length($name) < 1) || (length($email) < 1)) {
			print "ERROR: $line\n" ;
		}
		if ($email =~ /(\S+)\@/) {
			$email = $1 ;
		} else {
			print "ERROR: $email\n" ;
		}

		if (defined($names{"$email"})) {
			$names{"$email"} = $name if (length($names{"$email"}) <= length($name)) ;
		} else {
			$names{"$email"} = $name ;
		}

		if (defined($cnt{"$email"})) {
			$cnt{"$email"} += 1;
		} else {
			$cnt{"$email"} = 1;
		}
		my $str = sprintf("%s <%s>", $names{"$email"}, $email) ;
		$len = length($str) if ($len < length($str)) ;
    }
}

my $total = 0;
foreach $email ( sort keys %names ) {

	my $name = $names{"$email"} ;

	# skip Mark Indovina
   	next if (($name =~ m/Mark/i) && ($name =~ m/Indovina/i)) ;
   	next if ($email =~ m/maieee/i) ;

	# Sandeep Aswath Narayana <sa5641>
   	next if (($name =~ m/Sandeep/i) && ($name =~ m/Narayana/i)) ;
   	next if ($email =~ m/sa5641/i) ;
	
	$total += $cnt{"$email"} ;
}

my $cnt = 1;
my $percent_total = 0;
my $min = 100;
my $max = 0;
my $avg = 0;
foreach $email ( sort keys %names ) {

	my $name = $names{"$email"} ;
	my $str = sprintf("%s <%s>", $names{"$email"}, $email) ;
	my $pct = (($cnt{"$email"}/$total)*100) ;

	if ((($name =~ m/Mark/i) && ($name =~ m/Indovina/i)) ||
		(($name =~ m/Sandeep/i) && ($name =~ m/Narayana/i))) {
		printf "%4d %${len}s := %4d\n", $cnt, $str, $cnt{"$email"} ;
	} else {
		$percent_total = $percent_total + $pct ;
		printf "%4d %${len}s := %4d [%6.2f%%]\n", $cnt, $str,
			$cnt{"$email"}, $pct ;
		$min = $pct if ($pct < $min) ;
		$max = $pct if ($pct > $max) ;
		$avg = (($pct + $avg)/2.0);
	}
	$cnt++ ;
}

printf "%4s %${len}s := %4d [%6.2f%%]\n", " ", "Total", $total, $percent_total ;
printf "\n" ;
printf "%4s %${len}s := %4s [%6.2f%%]\n", " ", "Min", "    ", $min ;
printf "%4s %${len}s := %4s [%6.2f%%]\n", " ", "Max", "    ", $max ;
printf "%4s %${len}s := %4s [%6.2f%%]\n", " ", "Avg", "    ", $avg ;


