use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = new Sound::NeSynth->new();
$synth->test_tone({ freq => 440, sec => 1 });
$synth->write( 'test.wav' );


foreach my $note ( qw/C D E F G A B C/ ) {
	print $note . " => " . Sound::NeSynth::_note_to_freq( $note );
	print "(Hz)\n";

	my $s = new Sound::NeSynth->new();
	$s->test_tone({ note => $note, sec => 1 });
	$s->write( $note . '.wav' );
}

__END__
