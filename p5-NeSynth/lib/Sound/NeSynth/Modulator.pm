package Sound::NeSynth::Modulator;

use 5.008009;
use strict;
use warnings;
use Math::Trig qw( pi );
use Sound::WaveFile; 
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );
our @EXPORT = qw(
	create_osc
	create_env
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

sub create_osc {
	my $samples_per_sec = shift;
	my $freq = shift;
	my $t = 0;
	return sub {
		my $ret = sin( (2.0 * pi() * $t) / ($samples_per_sec / $freq) );
		$t++;
		return $ret;
	};
}

sub create_env {
	my $samples_per_sec = shift;
	return sub {
		return 1.0;
	};
}

=pod
	my $osc = sub {
		my $x = shift;
		return sin( 2.0 * pi() * $x );
	};
=cut

1;
__END__

=head1 NAME

Sound::NeSynth - Perl extension for Synthsis

=head1 SYNOPSIS

  use Sound::NeSynth;
  
  # 440Hz, 1sec => test.wav
  my $synth = new Sound::NeSynth->new();
  $synth->test_tone( 440, 1 );
  $synth->write( 'test.wav' );

=head1 DESCRIPTION

perl meats groove!

=head1 SEE ALSO

Sound::WaveFile

=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
