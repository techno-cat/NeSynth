# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sound-WaveFile.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 3;
BEGIN {
	use_ok( 'Sound::WaveFile' );
};

can_ok( 'Sound::WaveFile', 'save_as_wav' );
can_ok( 'Sound::WaveFile', qw(_through _nor_to_08 _nor_to_16) );

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

