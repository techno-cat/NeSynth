use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $kick = {
	osc => {
		freq => 25,
		waveform => 'sin',
		mod => { speed => 0.25, depth => 3.5, waveform => 'env', curve => 1.8 }
	},
	amp => { sec => 0.25, waveform => 'env', curve => 1.4 }
};

my $snare = {
	osc => {
		freq => 400,
		waveform => 'tri',
		mod => { speed => 0.08, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.16, waveform => 'env', curve => 2.2 }
};

my $o_hat = {
	osc => {
		freq => 16000,
		waveform => 'tri',
		mod => { speed => 0.06, depth =>  6.0, waveform => 'noise' }
	},
	amp => { sec => 0.15, waveform => 'env', curve => 2.7 }
};

my $c_hat = {
	osc => {
		freq => 16000,
		waveform => 'tri',
		mod => { speed => 0.06, depth =>  6.0, waveform => 'noise' }
	},
	amp => { sec => 0.08, waveform => 'env', curve => 2.7 }
};

sub my_bass {
	my ($note, $sec) = @_;
	return {
		osc => { freq => note_to_freq($note), waveform => 'tri' },
		amp => { sec => $sec, attack => 0.01, waveform => 'env', curve => 2.2 }
	};
}

my %patterns = (
	kick  =>   [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0 ],
	snare =>   [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ],
	o_hat =>   [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0 ],
	c_hat =>   [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ],
	bass_D2 => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0 ],
	bass_D1 => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0 ],
	bass_C2 => [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
	bass_C1 => [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0 ]
);

my $synth = Sound::NeSynth->new();
$synth->render({
	bpm => 138, # beats per minute
	beats => [
		{ seq => $patterns{kick},  tone => $kick,  vol => 1.00 },
		{ seq => $patterns{snare}, tone => $snare, vol => 0.12 },
		{ seq => $patterns{o_hat}, tone => $o_hat, vol => 0.06 },
		{ seq => $patterns{c_hat}, tone => $c_hat, vol => 0.015 },
		{ seq => $patterns{bass_D2}, tone => my_bass('D2', 0.18), vol => 0.25 },
		{ seq => $patterns{bass_D1}, tone => my_bass('D1', 0.12), vol => 0.25 },
		{ seq => $patterns{bass_C2}, tone => my_bass('C2', 0.18), vol => 0.25 },
		{ seq => $patterns{bass_C1}, tone => my_bass('C1', 0.12), vol => 0.25 }
	]
});

$synth->write( "techno2.wav" );

__END__
