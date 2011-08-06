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

can_ok( 'Sound::NeSynth', 'test_tone' );
can_ok( 'Sound::NeSynth', 'new' );
can_ok( 'Sound::NeSynth', qw(get_samples_per_sec) );

my $synth = Sound::NeSynth->new();
ok( $synth->get_samples_per_sec() == 44100 );

#########################
