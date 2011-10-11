use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my %matrix = (
	C3 => [ 1, 0, 0, 0, 0, 0, 0, 0 ],
	D3 => [ 0, 1, 0, 0, 0, 0, 0, 0 ],
	E3 => [ 0, 0, 1, 0, 0, 0, 0, 0 ],
	F3 => [ 0, 0, 0, 1, 0, 0, 0, 0 ],
	G3 => [ 0, 0, 0, 0, 1, 0, 0, 0 ],
	A3 => [ 0, 0, 0, 0, 0, 1, 0, 0 ],
	B3 => [ 0, 0, 0, 0, 0, 0, 1, 0 ],
	C4 => [ 0, 0, 0, 0, 0, 0, 0, 1 ],
);

write_sample( 'sin',   1.0 );
write_sample( 'tri',   1.0 );
write_sample( 'pulse', 0.2 );
write_sample( 'saw',   0.4 );

sub write_sample {
	my ($waveform, $vol) = @_;

	my @beats = ();
	foreach my $note ( keys %matrix ) {
		my $bass = {
			osc => { freq => note_to_freq($note), waveform => $waveform },
			amp => { sec => 0.25, attack => 0.002, waveform => 'env', curve => 1.0 }
		};
		push @beats, { seq => $matrix{$note}, tone => $bass, vol => $vol };
	}

	my $synth = Sound::NeSynth->new();
	$synth->render({
		bpm => 60, # beats per minute
		beats => \@beats
	});

	$synth->write( $waveform . '.wav' );
}

__END__

