package Sound::WaveFile;

use strict;
use warnings;
use IO::File;

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
