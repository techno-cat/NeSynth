# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sound-WaveFile.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => ;
use Test::More 'no_plan';
BEGIN {
	use_ok( 'Sound::NeSynth::Modulator' );
};

my $osc = create_osc( 4, 1 ); # sin wave
ok( abs($osc->() - ( 0.0)) < 0.01 ); # sin( 2*pi * 0/4 );
ok( abs($osc->() - ( 1.0)) < 0.01 ); # sin( 2*pi * 1/4 );
ok( abs($osc->() - ( 0.0)) < 0.01 ); # sin( 2*pi * 2/4 );
ok( abs($osc->() - (-1.0)) < 0.01 ); # sin( 2*pi * 3/4 );

my $no_osc = create_osc( 4, 0 ); # frequency = 0.0Hz
is( $no_osc->(), 0.0 );

TODO: {
	my $env = create_env( 0 );
	todo_skip( $env->( 0 ), 0.0 );
}
#########################
