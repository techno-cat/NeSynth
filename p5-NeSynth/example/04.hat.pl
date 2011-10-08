use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = Sound::NeSynth->new();

my $tone_hat = {
	osc => {
		freq => 8000,
		waveform => 'sin',
		mod => { speed => 0.06, depth =>  2.0, waveform => 'noise' }
	},
	amp => { sec => 0.4, waveform => 'env', curve => 2.7 }
};

my @freq_ptn = ( 8000, 4000, 2000 );

for (my $i=0; $i<scalar(@freq_ptn); $i++) {
	$tone_hat->{osc}->{freq} = $freq_ptn[$i];
	$synth->oneshot( $tone_hat );
	$synth->write( sprintf("hat_%d.wav", $i) );
}

__END__
