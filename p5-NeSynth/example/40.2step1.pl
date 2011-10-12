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
		mod => { speed => 0.15, depth => 3.0, waveform => 'env', curve => 1.8 }
	},
	amp => { sec => 0.17, waveform => 'env', curve => 1.6 }
};

my $snare = {
	osc => {
		freq => 400,
		waveform => 'tri',
		mod => { speed => 0.10, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.12, waveform => 'env', curve => 2.2 }
};

my $o_hat = {
	osc => {
		freq => 20000,
		waveform => 'tri',
		mod => { speed => 0.04, depth =>  4.0, waveform => 'noise' }
	},
	amp => { sec => 0.08, waveform => 'env', curve => 2.0 }
};

my $c_hat = {
	osc => {
		freq => 20000,
		waveform => 'tri',
		mod => { speed => 0.04, depth =>  4.0, waveform => 'noise' }
	},
	amp => { sec => 0.06, waveform => 'env', curve => 2.0 }
};

my %patterns = (
	kick   => [ 1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0, 1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0 ],
	snare  => [ 0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0, 0,1,0,0,1,0,0,0,0,0,1,0,1,0,0,1 ],
	o_hat  => [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0 ],
	c_hat  => [ 0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0 ]
);

my $synth = Sound::NeSynth->new();
$synth->render({
	bpm => 135, # beats per minute
	beats => [
		{ seq => $patterns{kick},  tone => $kick,  vol => 1.00 },
		{ seq => $patterns{snare}, tone => $snare, vol => 0.10 },
		{ seq => $patterns{o_hat}, tone => $o_hat, vol => 0.04 },
		{ seq => $patterns{c_hat}, tone => $c_hat, vol => 0.02 }
	],
	swing => 1/3
});

$synth->write( "2step1.wav" );

__END__

