use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $kick = {
	osc => {
		freq => 30,
		waveform => 'sin',
		mod => { speed => 0.25, depth => 3.0, waveform => 'env', curve => 1.6 }
	},
	amp => { sec => 0.5, waveform => 'env', curve => 1.2 }
};

my $snare = {
	osc => {
		freq => 400,
		waveform => 'sin',
		mod => { speed => 0.10, depth => 8.0, waveform => 'noise' }
	},
	amp => { sec => 0.2, waveform => 'env', curve => 2.7 }
};

my $o_hat = {
	osc => {
		freq => 8000,
		waveform => 'sin',
		mod => { speed => 0.06, depth =>  2.0, waveform => 'noise' }
	},
	amp => { sec => 0.2, waveform => 'env', curve => 2.7 }
};

my $c_hat = {
	osc => {
		freq => 8000,
		waveform => 'sin',
		mod => { speed => 0.06, depth =>  2.0, waveform => 'noise' }
	},
	amp => { sec => 0.15, waveform => 'env', curve => 2.7 }
};


my $synth = new Sound::NeSynth->new();
$synth->render({
	bpm => 138, # beats per minute
	beats => [
		{ seq => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0 ], tone => $kick , vol => 1.00 },
		{ seq => [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ], tone => $snare, vol => 0.05 },
		{ seq => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0 ], tone => $o_hat, vol => 0.020 },
		{ seq => [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ], tone => $c_hat, vol => 0.012 }
	]
});

$synth->write( "techno.wav" );

__END__
