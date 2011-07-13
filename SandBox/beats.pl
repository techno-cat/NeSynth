use strict;
use warnings;
use IO::File;
use Math::Trig qw( pi );

my $samples_per_sec = 44100; # サンプリング周波数
my $bits_per_sample = 8; # 量子化ビット数

my $bpm = 138; # beats per minute
my $beats = {
	kick  => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0 ],
	snare => [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ],
	hat   => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0 ]
};

# 1秒間に16分音符がなる回数
my $bps = ($bpm / 60.0) * 4;

sub create_oneshot {
	my $freq = shift; # 音の周波数
	my $time = shift; # 音の長さ(sec)
	my $osc = shift; # 波形生成関数

	my $sf = $samples_per_sec;
	my $size = int($sf * $time);
	my @wav = ();

	my $t = 0.0;
	my $interval = $sf / $freq;
	my $vol = 1.0;
	while ( 0.0 < $vol ) {
		if ( $interval <= $t ) {
			$t -= $interval;
		}

		push @wav, $osc->($t / $interval) * $vol; 

		# プチ！って鳴らないようにフェードアウト処理
		if ( $size < scalar(@wav) ) {
			$vol = $vol * 0.995;
			if ( $vol < 0.0001 ) {
				$vol = 0.0;
			}
		}

		$t += 1.0;
	}

	return \@wav;
}

sub to_wav {
	my $seq_ref = shift;
	my $oneshot_ref = shift;

	my $sf = $samples_per_sec;
	my $size = scalar(@{$seq_ref}) * int($sf / $bps);
	my @wav = map { 0.0; } 1..$size;

	for (my $i=0; $i<scalar(@{$seq_ref}); $i++) {
		if ( $seq_ref->[$i] ) {
			my $offset = $i * int($sf / $bps);
			map { $wav[$offset++] = $_; } @{$oneshot_ref};
		}
	}

	return \@wav;
}

sub save_as_wav {
	my $file_name = shift;
	my $samples_ref = shift;

	my $size = scalar(@{$samples_ref});
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

	# 量子化ビット数が8bitの場合
	# 最小0, 最大255, オフセット128
	foreach my $sample (@{$samples_ref}) {
		my $val = int($sample * 127.0) + 128;
		print $fh pack( 'C', $val );
	}
}

{
	# のこぎり波
	my $osc_saw = sub {
		my $x = shift; # 0.0 <= x < 1.0
		return (2.0 * $x) - 1.0;
	};

	# sin波
	my $osc_sin = sub {
		my $x = shift; # 0.0 <= x < 1.0
		return sin( 2.0 * pi() * $x );
	};

	# 矩形波
	my $osc_pwm = sub {
		my $x = shift; # 0.0 <= x < 1.0
		return ( $x < 0.5 ) ? -1.0 : 1.0;
	};

	# ノイズ
	my $osc_noise = sub {
		my $x = shift; # 0.0 <= x < 1.0
		return rand( 2.0 ) - 1.0;
	};

	my $wav_kick = create_oneshot( 50, 0.1, $osc_saw );
	my $wav_snare = create_oneshot( 1000, 0.05, $osc_noise );
	my $wav_hat = create_oneshot( 5000, 0.05, $osc_noise );

	my $ch_kick = to_wav( $beats->{kick}, $wav_kick );
	my $ch_snare = to_wav( $beats->{snare}, $wav_snare );
	my $ch_hat = to_wav( $beats->{hat}, $wav_hat );

	# 波形合成
	my $size = scalar(@{$ch_kick});
	my @samples = ();
	for (my $i=0; $i<$size; $i++) {
		my $val = $ch_kick->[$i] + $ch_snare->[$i] + $ch_hat->[$i];

		# -1.0 〜 +1.0 になるようにクリップ
		$val = ( 1.0 < $val ) ? 1.0 : (( $val < -1.0 ) ? -1.0 : $val );

		push @samples, $val;
	}

	# 出力
	save_as_wav( 'ch_kick.wav', $ch_kick );
	save_as_wav( 'ch_snare.wav', $ch_snare );
	save_as_wav( 'ch_hat.wav', $ch_hat );
	save_as_wav( 'beats.wav', \@samples );
}

__END__

