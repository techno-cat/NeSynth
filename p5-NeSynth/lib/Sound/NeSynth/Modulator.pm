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

# ノイズ
Readonly my @noise => map { rand( 2.0 ) - 1.0; } 1..1024;

sub _create_mod_func {
	my $waveform = shift;

	if ( $waveform eq 'sin' ) {
		return sub { return sin( 2.0 * pi() * $_[0] ); };
	}
	elsif ( $waveform eq 'noise' ) {
		return sub {
			return ( $_[0] < 1.0 ? $noise[ $_[0] * scalar(@noise) ] : 0.0 );
		};
	}
	elsif ( $waveform eq 'pulse' ) {
		return sub { return ( $_[0] < 0.5 ) ? -1.0 : 1.0; };
	}
	elsif ( $waveform eq 'saw' ) {
		return sub { return ( 2.0 * $_[0] ) - 1.0; };
	}
	elsif ( $waveform eq 'tri' ) {
		return sub {
			if ( $_[0] < 0.5 ) {
				# -1.0 -> +1.0
				return -1.0 + ( 4.0 * $_[0] );
			}
			else {
				# +1.0 -> -1.0
				return 1.0 - ( 4.0 * ($_[0] - 0.5) );
			}
		};
	}
	elsif ( $waveform eq 'env' ) {
		return sub { return ( 1.0 - $_[0] ); };
	}
	else { # ( $wavform eq 'flat' ) {
		return sub { return 1.0; };
	}
}

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
		my $curve = ( exists $arg_ref->{curve} ) ? $arg_ref->{curve} : 1.0;
		my $mod_func = _create_mod_func( $waveform );
		my $t = 0.0;
		my $interval = $samples_per_sec * $arg_ref->{sec};
		printf( "%s, t = %s, interval = %s\n", $waveform, $t, $interval );
		return sub {
			if ( $t < $interval ) {
				my $ret = $mod_func->( $t / $interval );
				$t += 1.0;
				return $ret ** $curve;
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
		my $mod_func = sub { return 1.0; };
		my $mod_depth = 0.0;
		if ( exists $arg_ref->{mod} ) {
			my $sec = $arg_ref->{mod}->{speed};
			my $mod_arg = {
				freq => ( 1.0 / $sec ),
				sec => $sec,
				waveform => $arg_ref->{mod}->{waveform}
			};

			if ( exists $arg_ref->{mod}->{curve} ) {
				$mod_arg->{curve} = $arg_ref->{mod}->{curve};
			}

			$mod_func = create_modulator( $samples_per_sec, $mod_arg );
			$mod_depth = $arg_ref->{mod}->{depth};
			printf( "sec = %f, depth = %f\n", $sec, $mod_depth );
		}

		my $osc_func = _create_mod_func( $arg_ref->{waveform} );
		my $t = 0.0;
		my $samples_per_cycle = $samples_per_sec / $freq;
		return sub {
			my $ret = $osc_func->( $t / $samples_per_cycle );

			my $dt = ( 1.0 + ($mod_func->() * $mod_depth) );
			if ( 0.0 < $dt ) {
				$t += $dt;
				while ( $samples_per_cycle <= $t ) {
					$t -= $samples_per_cycle;
				}
			}

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
