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
		mod => { speed => 0.25, depth => 3.0, waveform => 'env' }
	},
	amp => { sec => 0.5, waveform => 'env', curve => 1.2 }
};

my $snare = {
	osc => {
		freq => 400,
		waveform => 'sin',
		mod => { speed => 0.10, depth => 8.0, waveform => 'noise' }
	},
	amp => { sec => 0.3, waveform => 'env', curve => 2.7 }
};

my $hat = {
	osc => {
		freq => 8000,
		waveform => 'sin',
		mod => { speed => 0.06, depth =>  2.0, waveform => 'noise' }
	},
	amp => { sec => 0.4, waveform => 'env', curve => 2.7 }
};


my $synth = new Sound::NeSynth->new();
$synth->render({
	bpm => 138, # beats per minute
	beats => [
		{ seq => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0 ], tone => $kick , vol => 1.0 },
		{ seq => [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ], tone => $snare, vol => 0.5 },
		{ seq => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0 ], tone => $hat  , vol => 0.4 }
	]
});

$synth->write( "techno.wav" );

__END__
