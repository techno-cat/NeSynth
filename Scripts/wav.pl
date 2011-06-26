use strict;
use warnings;
use IO::File;
use Math::Trig;


main();
exit(0);

sub main {
	my $file_name = "wav.txt";

	my $fh = IO::File->new( $file_name, 'w' )
		or die "Could not create filehandle $!\n";

	my $cnt = 128;
	print $fh sprintf("char wavSine[%d] = {\n", ($cnt));
	for(my $i=0; $i<$cnt; $i++) {
		my $val = sin( (pi * $i) / $cnt ) * 31;
		my $tmp = sprintf("%3d,", int($val) );
		print $fh $tmp;
		print $tmp;
		if ( (($i + 1) % 16) == 0 ) {
			print $fh "\n";
			print "\n";
		}
	}
	print $fh "};\n";
	$fh->close();
}

__END__