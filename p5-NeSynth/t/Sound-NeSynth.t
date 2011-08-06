# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sound-NeSynth.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => ;
use Test::More 'no_plan';
BEGIN {
	use_ok( 'Sound::NeSynth' );
};

can_ok( 'Sound::NeSynth', 'new' );
can_ok( 'Sound::NeSynth', qw(get_samples_per_sec get_samples_count) );
can_ok( 'Sound::NeSynth', qw(test_tone write) );

ok( Sound::NeSynth->new()->get_samples_per_sec() == 44100 );
ok( Sound::NeSynth->new( 22050 )->get_samples_per_sec() == 22050 );

my $synth = Sound::NeSynth->new();
ok( $synth->get_samples_count() == 0 );
$synth->test_tone( 440, 1 );
ok( $synth->get_samples_count() == 44100 );


#########################
