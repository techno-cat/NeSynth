# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sound-WaveFile.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => ;
use Test::More 'no_plan';
use Test::Exception;
BEGIN {
	use_ok( 'Sound::NeSynth::Modulator' );
};

# frequency = 1.0Hz
my $osc = create_osc( 4, 1 ); # sin wave
ok( abs($osc->() - ( 0.0)) < 0.01 ); # sin( 2*pi * 0/4 );
ok( abs($osc->() - ( 1.0)) < 0.01 ); # sin( 2*pi * 1/4 );
ok( abs($osc->() - ( 0.0)) < 0.01 ); # sin( 2*pi * 2/4 );
ok( abs($osc->() - (-1.0)) < 0.01 ); # sin( 2*pi * 3/4 );

# frequency = 0.0Hz
my $no_osc = create_osc( 4, 0 );
is( $no_osc->(), 0.0 );

# frequency = -1.0Hz
dies_ok{ create_osc(4, -1) };

my $env_flat = create_env( 0 );
ok( $env_flat->() == 1.0 );
ok( $env_flat->() == 1.0 );
ok( $env_flat->() == 1.0 );
ok( $env_flat->() == 1.0 );

#########################
