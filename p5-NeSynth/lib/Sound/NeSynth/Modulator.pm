package Sound::NeSynth::Modulator;

use 5.008009;
use strict;
use warnings;
use Readonly;
use Math::Trig qw( pi );
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );
our @EXPORT = qw(
	create_osc
	create_env
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';


Readonly my $FREQ_MIN => 0.001;

sub create_osc {
	my $samples_per_sec = shift;
	my $freq = shift;

	if ( $freq < 0.0 ) {
		die "Can't use negative number as frequency.";
	}
	elsif ( $freq < $FREQ_MIN ) {
		return sub {
			return 0.0;
		};
	}
	else {
		my $t = 0;
		return sub {
			my $ret = sin( (2.0 * pi() * $t) / ($samples_per_sec / $freq) );
			$t++;
			return $ret;
		};
	}
}

sub create_env {
	my $samples_per_sec = shift;
	return sub {
		return 1.0;
	};
}

1;
__END__

=head1 NAME

Sound::NeSynth:Modulator - Modulator module for NeSynth

=head1 SYNOPSIS

  use Sound::NeSynth::Modulator;
  
  my $samples_per_sec = 4;
  my $freq = 1;
  my $osc = create_osc( $samples_per_sec, $freq );

  $osc->(); #  0.0
  $osc->(); #  1.0
  $osc->(); #  0.0
  $osc->(); # -1.0
  $osc->(); #  0.0
  $osc->(); #  1.0
  # -- repeat --

=head1 DESCRIPTION

=head2 create_osc

  samples per sec = 4
  frequency 1(Hz)

      <-- 1sec --><-- 1sec -
+1.0  |  o           o
      |
 0.0  o-----o-----o-----> t
      |
+1.0  |        o
  
=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
