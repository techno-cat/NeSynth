use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = new Sound::NeSynth->new();

my $tone_kick = {
	osc => {
		freq => 220,
		waveform => 'sin'
	},
	amp => {
		sec => 2.0,
		waveform => 'env'
	}
};

my $mod_kick = { speed => 1.0, depth => 0.0, waveform => 'env' };
$mod_kick->{depth} = 2.0;
foreach my $speed ( 0.5, 1.0, 2.0, 4.0, 8.0, 16.0 ) {
	$mod_kick->{speed} = $speed;

	$tone_kick->{osc}->{mod} = $mod_kick;
	$synth->one_shot( $tone_kick );
	$synth->write( sprintf("kick_%.1f.wav", $speed) );
}

__END__
