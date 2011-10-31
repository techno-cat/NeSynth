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
	use_ok( 'Sound::NeSynth::Filter' );
};

# type not found
dies_ok {
	create_filter( 4, { cutoff => 0.1 } );
};

# cutoff not found
dies_ok {
	create_filter( 4, { type => 'lpf' } );
};

# cutoff
dies_ok {
	create_filter( 4, { type => 'lpf', cutoff => -0.1 } );
};
dies_ok {
	create_filter( 4, { type => 'lpf', cutoff =>  0.5 } );
};

# Q
dies_ok {
	create_filter( 4, { type => 'lpf', cutoff => 0.2, Q => 0.0 } );
};
dies_ok {
	create_filter( 4, { type => 'lpf', cutoff => 0.2, Q => 20.1 } );
};

#########################
