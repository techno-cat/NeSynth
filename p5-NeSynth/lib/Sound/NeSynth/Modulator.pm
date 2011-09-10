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
	create_modulator
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';


Readonly my $FREQ_MIN => 0.001;

sub create_modulator {
	my $samples_per_sec = shift;
	my $arg_ref = shift;

	my $waveform = 'flat';
	if ( not exists $arg_ref->{waveform} ) {
		warn '"waveform" is required argument.'
	}
	else {
		$waveform = $arg_ref->{waveform};
	}

	if ( $waveform eq 'flat' or $waveform eq 'env' ) {
		my $env_func = sub { return 1.0; }; # flat
		if ( $waveform eq 'env' ) {
			$env_func = sub { return shift; }; # env
		}

		my $t = 0.0;
		my $interval = $samples_per_sec * $arg_ref->{sec};
		return sub {
			if ( $t < $interval ) {
				my $ret = $env_func->( ($interval - $t) / $interval );
				$t += 1.0;
				return $ret;
			}
			else {
				return 0.0;
			}
		}
	}
	else {
		return create_osc( $samples_per_sec, $arg_ref );
	}
}

sub create_osc {
	my $samples_per_sec = shift;
	my $arg_ref = shift;

	my $freq = $arg_ref->{freq};
	if ( $freq < 0.0 ) {
		die "Can't use negative number as frequency.";
	}

	if ( $freq < $FREQ_MIN ) {
		warn $freq . ' is too small, so changed to 0.';
		return sub { return 0.0; };
	}
	else {
		my $t = 0.0;
		my $samples_per_cycle = $samples_per_sec / $freq;
		return sub {
			while ( $samples_per_cycle <= $t ) {
				$t -= $samples_per_cycle;
			}

			my $ret = sin( 2.0 * pi() * ($t / $samples_per_cycle) );
			$t += 1.0;

			return $ret;
		};
	}
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
