use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = new Sound::NeSynth->new();

my $tone_snare = {
	osc => { freq => 400, waveform => 'sin' },
	amp => { sec => 0.3, waveform => 'env', curve => 2.7 }
};

my @mod_ptn = (
	{ speed => 0.10, depth => 8.0, waveform => 'noise' },
	{ speed => 0.05, depth => 8.0, waveform => 'noise' },
	{ speed => 0.04, depth => 8.0, waveform => 'noise' },
);

for (my $i=0; $i<scalar(@mod_ptn); $i++) {
	$tone_snare->{osc}->{mod} = $mod_ptn[$i];
	$synth->one_shot( $tone_snare );
	$synth->write( sprintf("snare_%d.wav", $i) );
}

__END__
