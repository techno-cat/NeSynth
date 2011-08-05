# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sound-WaveFile.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => ;
use Test::More 'no_plan';
BEGIN {
	use_ok( 'Sound::WaveFile' );
	use_ok( 'Sound::WaveFile', qw(save_as_wav) );
};

ok( Sound::WaveFile::_through(0) == 0 );
ok( Sound::WaveFile::_through(pack('C', 128)) eq pack('C', 128) );
ok( Sound::WaveFile::_through(pack('s',   0)) eq pack('s',   0) );
ok( Sound::WaveFile::_nor_to_08( 1.0) eq pack('C', ( 127 + 128)) );
ok( Sound::WaveFile::_nor_to_08( 0.0) eq pack('C', (   0 + 128)) );
ok( Sound::WaveFile::_nor_to_08(-1.0) eq pack('C', (-127 + 128)) );
ok( Sound::WaveFile::_nor_to_16( 1.0) eq pack('s',  32767) );
ok( Sound::WaveFile::_nor_to_16( 0.0) eq pack('s',      0) );
ok( Sound::WaveFile::_nor_to_16(-1.0) eq pack('s', -32767) );

ok( BITS_PER_SAMPLE_08 ==  8 );
ok( BITS_PER_SAMPLE_16 == 16 );

#########################
