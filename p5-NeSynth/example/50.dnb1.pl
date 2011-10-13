use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $kick = {
	osc => {
		freq => 32,
		waveform => 'sin',
		mod => { speed => 0.25, depth => 3.0, waveform => 'env', curve => 1.4 }
	},
	amp => { sec => 0.30, waveform => 'env', curve => 1.2 }
};

my $snr1 = {
	osc => {
		freq => 400,
		waveform => 'tri',
		mod => { speed => 0.12, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.14, waveform => 'env', curve => 2.2 }
};

my $snr2 = {
	osc => {
		freq => 400,
		waveform => 'tri',
		mod => { speed => 0.12, depth => 9.0, waveform => 'noise' }
	},
	amp => { sec => 0.13, waveform => 'env', curve => 2.2 }
};

my $c_hat = {
	osc => {
		freq => 24000,
		waveform => 'tri',
		mod => { speed => 0.03, depth =>  4.0, waveform => 'noise' }
	},
	amp => { sec => 0.06, waveform => 'env', curve => 2.0 }
};

my %patterns = (
	kick   => [ 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0, 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0, 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0, 1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
	snr1   => [ 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
	snr2   => [ 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0],
	c_hat1 => [ 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0, 0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0],
	c_hat2 => [ 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0, 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]
);

my $synth = Sound::NeSynth->new();
$synth->render({
	bpm => 165, # beats per minute
	beats => [
		{ seq => $patterns{kick},   tone => $kick,  vol => 1.00 },
		{ seq => $patterns{snr1},   tone => $snr1,  vol => 0.10 },
		{ seq => $patterns{snr2},   tone => $snr2,  vol => 0.10 },
		{ seq => $patterns{c_hat1}, tone => $c_hat, vol => 0.01 },
		{ seq => $patterns{c_hat2}, tone => $c_hat, vol => 0.005 }
	],
	swing => 0.3/3
});

$synth->write( "dnb1.wav" );

__END__

