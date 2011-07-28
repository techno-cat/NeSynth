package Sound::WaveFile;

use strict;
use warnings;
use IO::File;
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
	save_as_wav
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

sub save_as_wav {
	my $file_name = shift;
	my $samples_per_sec = shift; # 周波数
	my $bits_per_sample = shift; # 量子化ビット数
	my $samples_ref = shift;

	my $size = scalar(@{$samples_ref}) * ($bits_per_sample / 8);
	my $header =
		  'RIFF' # chunkID
		. pack('L', ($size + 32)) # chunkSize
		. 'WAVE'; # formType
	my $fmt_chunk =
		  'fmt ' # chunkID
		. pack('L', 16) # chunkSize
		. pack('S', 1) # waveFormatType
		. pack('S', 1) # channel
		. pack('L', $samples_per_sec) # samplesPerSec
		. pack('L', 1 * $samples_per_sec) # bytesPerSec = channel * samplesPerSec
		. pack('S', 1) # blockSize
		. pack('S', $bits_per_sample); # bitsPerSample
	my $data_chunk =
		  'data' # chunkID
		. pack('L', $size); # chunkSize

	# 書き込む
	my $fh = IO::File->new( $file_name, 'w' )
		or die "Could not create filehandle $!\n";
	print $fh $header;
	print $fh $fmt_chunk;
	print $fh $data_chunk;

	if ( $bits_per_sample == 8 ) {
		# 量子化ビット数が8bitの場合
		# 最小0, 最大255, オフセット128
		foreach my $sample (@{$samples_ref}) {
			my $val = int($sample * 127.0) + 128;
			print $fh pack( 'C', $val );
		}
	}
	elsif ( $bits_per_sample == 16 ) {
		# 量子化ビット数が16bitの場合
		# 最小-32768, 最大32767, オフセット0
		foreach my $sample (@{$samples_ref}) {
			my $val = int($sample * 32767.0);
			print $fh pack( 's', $val );
		}
	}
	else {
		die 'Unsupported format.';
	}

	$fh->close();
}

1;
__END__

=head1 NAME

Sound::WaveFile - output as wav-format

=head1 SYNOPSIS

  use Sound::WaveFile qw( save_as_wav );

  # 1sec => test.wav
  my @samples = map { 0.0; } 1..44100; # silence samples
  save_as_wav( 'test.wav', 44100, 16, \@samples );

=head1 DESCRIPTION

=head1 SEE ALSO

=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
