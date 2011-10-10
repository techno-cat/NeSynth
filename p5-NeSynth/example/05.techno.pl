use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $kick = {
	osc => {
		freq => 20,
		waveform => 'sin',
		mod => { speed => 0.35, depth => 3.5, waveform => 'env', curve => 1.6 }
	},
	amp => { sec => 0.25, waveform => 'env', curve => 1.4 }
};

my $snare = {
	osc => {
		freq => 400,
		waveform => 'tri',
		mod => { speed => 0.10, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.18, waveform => 'env', curve => 2.2 }
};

my $o_hat = {
	osc => {
		freq => 16000,
		waveform => 'tri',
		mod => { speed => 0.06, depth =>  6.0, waveform => 'noise' }
	},
	amp => { sec => 0.2, waveform => 'env', curve => 2.7 }
};

my $c_hat = {
	osc => {
		freq => 16000,
		waveform => 'tri',
		mod => { speed => 0.06, depth =>  6.0, waveform => 'noise' }
	},
	amp => { sec => 0.15, waveform => 'env', curve => 2.7 }
};

my %patterns = (
	kick  => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0 ],
	snare => [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ],
	o_hat => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0 ],
	c_hat => [ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ]
);

my $synth = Sound::NeSynth->new();
$synth->render({
	bpm => 138, # beats per minute
	beats => [
		{ seq => $patterns{kick},  tone => $kick,  vol => 1.00 },
		{ seq => $patterns{snare}, tone => $snare, vol => 0.12 },
		{ seq => $patterns{o_hat}, tone => $o_hat, vol => 0.06 },
		{ seq => $patterns{c_hat}, tone => $c_hat, vol => 0.015 }
	]
});

$synth->write( "techno.wav" );

__END__
