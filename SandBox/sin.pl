use strict;
use warnings;
use IO::File;
use Math::Trig qw( pi );

main();
exit(0);

sub main {
	my $file_name = "sin.wav";
	my $sf = 44100; # サンプリング周波数
	my $bitsPerSample = 8; # 量子化ビット数

	my $time = 1.0; # 音の長さ(sec)
	my $size = int($sf * $time);

	my $header =
		  'RIFF' # chunkID
		. pack('L', ($size + 32)) # chunkSize
		. 'WAVE'; # formType
	my $fmt_chunk =
		  'fmt ' # chunkID
		. pack('L', 16) # chunkSize
		. pack('S', 1) # waveFormatType
		. pack('S', 1) # channel
		. pack('L', 44100) # samplesPerSec
		. pack('L', 1 * 44100) # bytesPerSec = channel * samplesPerSec
		. pack('S', 1) # blockSize
		. pack('S', $bitsPerSample); # bitsPerSample
	my $data_chunk =
		  'data' # chunkID
		. pack('L', $size); # chunkSize

	# 書き込む
	{
		my $fh = IO::File->new( $file_name, 'w' )
			or die "Could not create filehandle $!\n";
		print $fh $header;
		print $fh $fmt_chunk;
		print $fh $data_chunk;

		# data_chunkのdeta部
		my $freq = 440.0; # ラの音
		my $interval = $sf / $freq;

		my $osc = sub { 0; };
		if ( $bitsPerSample == 8 ) {
			# 量子化ビット数が8bitの場合
			# 最小0, 最大255, オフセット128
			$osc = sub {
				my $t = shift;
				my $rad = (2.0 * pi()) * ($t / $interval);
				my $val = int(sin($rad) * 127.0) + 128;
				return pack( 'C', $val );
			};
		}
		else {
			# 量子化ビット数が16bitの場合
			# 最小-32768, 最大32767, オフセット0
		}

		my $t = 0.0;
		for (my $i=0; $i<$size; $i++) {
			if ( $interval <= $t ) {
				$t -= $interval;
			}

			print $fh $osc->( $t );

			$t += 1.0;
		}

		$fh->close();
	}
}

__END__
