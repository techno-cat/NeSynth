use strict;
use warnings;
use IO::File;

main();
exit(0);

sub main {
	my $file_name = "sin.wav";
	my $size = 44100;

	my $header = 'RIFF' . pack('L', ($size + 32)) . 'WAVE';
	my $fmt =
			  'fmt '
			. pack('L', 16)
			. pack('S', 1)
			. pack('S', 1)
			. pack('L', 44100)
			. pack('L', 1 * 44100)
			. pack('S', 1)
			. pack('S', 8);
	my $data_header = 'data' . pack('L', $size);

	# 書き込む
	{
		my $fh = IO::File->new( $file_name, 'w' )
			or die "Could not create filehandle $!\n";
		print $fh $header;
		print $fh $fmt;
		print $fh $data_header;

		for (my $i=0; $i<$size; $i++) {
			if ( ($i % 220) < 110 ) {
				print $fh pack('C', 1 );
			}
			else {
				print $fh pack('C', 255 );
			}
		}

		$fh->close();
	}
}

__END__