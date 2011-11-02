package Sound::NeSynth;

use 5.008009;
use strict;
use warnings;
use Readonly;
use Sound::WaveFile;
use Sound::NeSynth::Modulator;
use Sound::NeSynth::Filter;
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );
our @EXPORT = qw(
	note_to_freq
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

Readonly my $DEFAULT_SAMPLES_PER_SEC => 44100;

#     C#    D#          F#    G#    A#
#  C     D     E     F     G     A     B
# -9    -7    -5    -4    -2     0    +2
Readonly my %NOTE_TO_OFFSET => (
	C => -9,
	D => -7,
	E => -5,
	F => -4,
	G => -2,
	A =>  0,
	B =>  2
);

# オクターブ = +3, ラの音の周波数
Readonly my $FREQ_OF_A3 => 440.0;

# アルファベットと+/-で表現した音程から周波数に変換する
sub note_to_freq {
	my $note = shift;

	# MIDIだとオクターブは-2から+8まであるが、
	# 0から+8までサポートする

	if ( $note =~ /^[A-G][+|-]?[0-8]?/ ) {
		my @tmp = split //, $note;
		my $idx = $NOTE_TO_OFFSET{ shift @tmp };
	
		# A3の場合、$idx=0で440Hzが算出される
		foreach my $ch (@tmp) {
			if ( $ch eq '+' ) {
				$idx++;
			}
			elsif ( $ch eq '-' ) {
				$idx--;
			}
			else { 
				$idx += ( (int($ch) - 3) * 12 );
			}
		}

		return $FREQ_OF_A3 * ( 2 ** ($idx / 12.0) );
	}
	else {
		warn '"' . $note . '" is not note.';
		return 0;
	}
}

sub _create_oneshot {
	my $samples_per_sec = shift;
	my $arg_ref = shift;

	if ( not exists $arg_ref->{osc} ) {
		die '"osc" not found in arguments.'
	}

	if ( not exists $arg_ref->{amp} ) {
		die '"amp" not found in arguments.'
	}

	my $osc = create_modulator( $samples_per_sec, $arg_ref->{osc} );
	my $env = create_modulator( $samples_per_sec, $arg_ref->{amp} );

	my $filter = sub { return shift; };
	if ( exists $arg_ref->{filter} ) {
		$filter = create_filter( $samples_per_sec, $arg_ref->{filter} );

		# todo: IIRフィルタなので、遅延器の初期化を行う
		# ループ数は経験則なので適当
		#	foreach ( 0..30 ) { $filter->( $osc->() ); }
	}

	my $amp = $arg_ref->{amp};
	my $attack = ( exists $amp->{attack} ) ? $amp->{attack} : 0;
	my $gate_time = int( $samples_per_sec * $amp->{sec} );

	my @samples = map {
		$filter->( $osc->() ) * $env->();
	} 0..($gate_time - 1);

	# 立ち上がりでプチッって言わないようにするための回避策
	# なので、アタック感重視の係数をしている
	if ( 0.0 < $attack ) {
		my $attack_time = int( $samples_per_sec * $attack );
		if ( $attack_time < $gate_time ) { $attack_time = $gate_time; }
		for (my $i=0; $i<$attack_time; $i++) {
			my $volume = ( ($i / $attack_time) ** 2.0 );
			$samples[$i] *= $volume;
		}
	}

	return \@samples;
}

sub new {
	my $pkg = shift;

	# サンプリング周波数の設定
	my $samples_per_sec = $DEFAULT_SAMPLES_PER_SEC;
	if ( 0 < scalar(@_) ) {
		$samples_per_sec = shift;
	}

	bless {
		samples_per_sec => $samples_per_sec,
		samples_ref => []
	};
}

sub get_samples_per_sec {
	my $self = shift;
	return $self->{samples_per_sec};
}

sub get_samples_count {
	my $self = shift;
	return scalar( @{$self->{samples_ref}} );
}

sub write {
	my $self = shift;
	my $filename = shift;

	save_as_wav(
		$filename,
		$self->{samples_per_sec},
		BITS_PER_SAMPLE_16,
		$self->{samples_ref} );
}

sub oneshot {
	my $self = shift;
	my $arg_ref = shift;

	$self->{samples_ref} = _create_oneshot( $self->{samples_per_sec}, $arg_ref );
}

sub render {
	my $self = shift;
	my $arg_ref = shift;

	my $bps = ( $arg_ref->{bpm} / 60.0 ) * 4; # 1秒間に16分音符がなる回数
	my $beats = $arg_ref->{beats};
	my $swing = ( exists $arg_ref->{swing} ) ? $arg_ref->{swing} : 0.0;

	my @channels = ();
	foreach my $beat ( @{$beats} ) {
		my $seq = $beat->{seq};
		my $tone = $beat->{tone};

		# oneshotの生成
		my $oneshot_ref = _create_oneshot( $self->{samples_per_sec}, $tone );

		# 発音タイミングの計算
		my $seq_cnt = scalar( @{$seq} );
		my $interval = $self->{samples_per_sec} / $bps;
		my @plot_tmpl = ();
		for (my $i=0; $i<$seq_cnt; $i++) {
			push @plot_tmpl, int($i * $interval);

			# 発音タイミングをずらしてswingを実現
			if ( $i & 0x01 ) {
				$plot_tmpl[$i] += int( $interval * $swing );
			}
		}

		# 必要な配列サイズを計算して初期化
		my $wav_size = $plot_tmpl[$seq_cnt - 1] + scalar(@{$oneshot_ref});
		my @channel = map { 0.0; } 1..$wav_size;

		for (my $i=0; $i<$seq_cnt; $i++) {
			if ( $seq->[$i] ) {
				my $offset = $plot_tmpl[$i];
				map { $channel[$offset++] += $_; } @{$oneshot_ref};
			}
		}

		print "created channel => " . scalar(@channel) . "\n";

		push @channels, \@channel;
	}

	# ミックス
	my @samples = ();
	for (my $i=0; $i<scalar(@channels); $i++) {
		my $ch = $channels[$i];
		if ( scalar(@samples) < scalar(@{$ch}) ) {
			my $cnt = scalar(@{$ch}) - scalar(@samples);
			push @samples, ( map { 0.0; } (1..$cnt) );
		}

		for (my $j=0; $j<scalar(@{$ch}); $j++) {
			$samples[$j] += ( $ch->[$j] * $beats->[$i]->{vol} );
		}
	}

	# クリップ
	@samples = map {
		( 1.0 < $_ ) ? 1.0 : ( ($_ < -1.0) ? -1.0 : $_ );
	} @samples;

	$self->{samples_ref} = \@samples;
}

sub test_tone {
	my $self = shift;
	my $arg_ref = shift;

	my $freq = ( exists $arg_ref->{freq} ) ? $arg_ref->{freq} : 440;
	my $sec  = ( exists $arg_ref->{sec}  ) ? $arg_ref->{sec}  :   1;

	# overwrite
	if ( exists $arg_ref->{note} ) {
		$freq = note_to_freq( $arg_ref->{note} );
	}

	$self->oneshot({
		osc => { freq => $freq, waveform => 'sin' },
		amp => { sec => $sec, waveform => 'flat' }
	});
}

1;
__END__

=head1 NAME

Sound::NeSynth - Perl extension for Synthsis

=head1 SYNOPSIS

  use Sound::NeSynth;
  my $synth = Sound::NeSynth->new();

  #
  # 440Hz, 1sec => test.wav
  #
  $synth->test_tone({ freq => 440, sec => 1 });
  $synth->write( 'test.wav' );

  #
  # note -> frequency
  #
  my $freq = 440.0;

  # note = A3
  $freq = note_to_freq( 'A3' ); # 440.0

  # note = C3#
  $freq = note_to_freq( 'C3+' );

  # note = C3b
  $freq = note_to_freq( 'C3-' );

  #
  # get samples per second
  #
  my $samples_per_sec = $synth->get_samples_per_sec(); # 44100

  #
  # get samples count
  #
  my $cnt = $synth->get_samples_count(); # = length(sec) * $samples_per_sec

  #
  # tone
  #
  my $tone = {
    osc => {
      freq => 220,         # frequency
      waveform => 'sin',   # waveform ( sin, tri, pulse, saw, noise )
      mod => {
        speed => 0.25,     # modulation frequency = frequency * speed
        depth => 3.5,      # modulation depth
        waveform => 'env', # modulation waveform ( sin, tri, pulse, saw, noise, env ) 
        curve => 1.8       # envelope curve (option)
      }
    },
    amp => {
      sec => 1.0,          # gate time
      waveform => 'env',   # only support 'env'
      curve => 1.4,        # envelope curve (option)
      attack => 0.01       # attack time (option)
    }
  };

  #
  # one shot
  #
  $synth->oneshot( $tone );
  $synth->write( 'this_tone.wav' );

  #
  # beats
  # please see ./example
  #
  $synth->render({
    bpm => 120, # beats per minute
    beats => [
      { seq=> [ 1,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0 ], tone => $tone, vol => 1.0 }
    ],
    swing => 0.0 # recommend: 0.0 - 0.33
  });
  $synth->write( 'beats.wav' );

=head1 DESCRIPTION

perl meats groove!

=head1 SEE ALSO

Sound::WaveFile

=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
