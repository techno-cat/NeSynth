use strict;
use warnings;
use IO::File;

main();
exit(0);

sub main {
	my $file_name = "bpm.txt";

	my $fh = IO::File->new( $file_name, 'w' )
		or die "Could not create filehandle $!\n";

	my $cnt = 8;
	print $fh sprintf("unsigned short bpmOffset[%d] = {\n", $cnt);
	foreach (1..$cnt) {
		my $bpm = 2 ** ($_ - 1);
		my $bps = $bpm / 60.0;
		my $offset = $bps * 0x01000000 / (16000000 / (64*8));
		my $tmp = sprintf("  0x%04X, // %5.1f << 2, %6.1f * 4.0\n", int($offset) << 2, $bpm, $offset);
		print $fh $tmp;
		print $tmp;
	}
	print $fh "};\n";
	$fh->close();
}

__END__