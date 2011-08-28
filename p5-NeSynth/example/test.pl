use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = new Sound::NeSynth->new();
$synth->test_tone( 440, 1 );
$synth->write( 'test.wav' );

__END__
