use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = Sound::NeSynth->new();

my $tone_kick = {
	osc => { freq => 30, waveform => 'sin' },
	amp => { sec => 0.5, waveform => 'env', curve => 1.2 }
};

my @mod_ptn = (
	{ speed => 0.25, depth => 2.0, waveform => 'env' },
	{ speed => 0.25, depth => 3.0, waveform => 'env' },
	{ speed => 0.25, depth => 4.0, waveform => 'env' }
);

for (my $i=0; $i<scalar(@mod_ptn); $i++) {
	$tone_kick->{osc}->{mod} = $mod_ptn[$i];
	$synth->oneshot( $tone_kick );
	$synth->write( sprintf("kick_%d.wav", $i) );
}

__END__
