use strict;
use warnings;

BEGIN {
	unshift @INC, '../lib';
}

use Sound::NeSynth;

my $synth = new Sound::NeSynth->new();
foreach my $note ( qw/C3 D3 E3 F3 G3 A3 B3 C4/ ) {
	print $note . " => " . Sound::NeSynth::_note_to_freq( $note );
	print "(Hz)\n";

	$synth->test_tone({ note => $note, sec => 1 });
	$synth->write( $note . '.wav' );
}

__END__
