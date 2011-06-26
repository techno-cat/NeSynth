use strict;
use warnings;
use IO::File;

main();
exit(0);

sub main {
	my $file_name = "freq.txt";

	my $fh = IO::File->new( $file_name, 'w' )
		or die "Could not create filehandle $!\n";

	my $cnt = 36 - 24;
	print $fh sprintf("unsigned long noteOffset[%d] = {\n", ($cnt + 2));
	print $fh sprintf("  0x%08X, // %8.4f, %12.2f\n", int(0), 0, 0);
	foreach (24..36) {
		my $freq = 440.0 * (2**($_ / 12.0));
		my $offset = $freq * 256 * 0x00010000 / (16000000 / (64*8));
		my $tmp = sprintf("  0x%08X, // %8.2f, %12.2f\n", int($offset), $freq, $offset);
		print $fh $tmp;
		print $tmp;
	}
	print $fh "};\n";
	$fh->close();
}

__END__