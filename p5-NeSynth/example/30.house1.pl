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
		mod => { speed => 0.30, depth => 3.5, waveform => 'env', curve => 1.8 }
	},
	amp => { sec => 0.22, waveform => 'env', curve => 1.6 }
};

my $snare = {
	osc => {
		freq => 500,
		waveform => 'tri',
		mod => { speed => 0.10, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.15, waveform => 'env', curve => 2.2 }
};

my $o_hat = {
	osc => {
		freq => 24000,
		waveform => 'tri',
		mod => { speed => 0.04, depth =>  4.0, waveform => 'noise' }
	},
	amp => { sec => 0.19, waveform => 'env', curve => 2.0 }
};

my $c_hat = {
	osc => {
		freq => 24000,
		waveform => 'tri',
		mod => { speed => 0.04, depth =>  4.0, waveform => 'noise' }
	},
	amp => { sec => 0.12, waveform => 'env', curve => 2.0 }
};

my %patterns = (
	kick   => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0 ],
	snare  => [ 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0 ],
	perc   => [ 0,1,0,0,1,0,0,1,0,1,1,0,1,0,0,1, 0,1,0,0,1,0,0,1,0,1,1,0,1,0,0,0 ],
	o_hat  => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0 ],
	c_hat  => [ 1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,1, 1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,0 ]
);

my $synth = Sound::NeSynth->new();
$synth->render({
	bpm => 132, # beats per minute
	beats => [
		{ seq => $patterns{kick},  tone => $kick,  vol => 1.00 },
		{ seq => $patterns{snare}, tone => $snare, vol => 0.10 },
		{ seq => $patterns{perc},  tone => $snare, vol => 0.02 },
		{ seq => $patterns{o_hat}, tone => $o_hat, vol => 0.04 },
		{ seq => $patterns{c_hat}, tone => $c_hat, vol => 0.010 }
	],
	swing => 1/3
});

$synth->write( "house1.wav" );

__END__

