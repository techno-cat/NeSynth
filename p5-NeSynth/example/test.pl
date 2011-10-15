use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = Sound::NeSynth->new();
$synth->test_tone({ freq => 440, sec => 1 });
$synth->write( 'test.wav' );

__END__
