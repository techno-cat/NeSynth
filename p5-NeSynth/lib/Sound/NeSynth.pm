package Sound::NeSynth;

use 5.008009;
use strict;
use warnings;
use Readonly;
use Sound::WaveFile;
use Sound::NeSynth::Modulator;
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

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
sub _note_to_freq {
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
		return 0;
	}
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

sub test_tone {
	my $self = shift;
	my $arg_ref = shift;

	my $freq = ( exists $arg_ref->{freq} ) ? $arg_ref->{freq} : 440;
	my $sec  = ( exists $arg_ref->{sec}  ) ? $arg_ref->{sec}  :   1;

	# overwrite
	if ( exists $arg_ref->{note} ) {
		$freq = _note_to_freq( $arg_ref->{note} );
	}

	my $osc = create_osc( $self->{samples_per_sec}, $freq ); 
	my $cnt = $self->{samples_per_sec} * $sec;
	my @samples = map{ $osc->(); } 1..$cnt;

	$self->{samples_ref} = \@samples;
}

1;
__END__

=head1 NAME

Sound::NeSynth - Perl extension for Synthsis

=head1 SYNOPSIS

  use Sound::NeSynth;
  
  # 440Hz, 1sec => test.wav
  my $synth = new Sound::NeSynth->new();
  $synth->test_tone({ freq => 440, sec => 1 });
  $synth->write( 'test.wav' );

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
