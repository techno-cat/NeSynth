package Sound::NeSynth::Filter;

use 5.008009;
use strict;
use warnings;
use Readonly;
use Math::Trig qw( tan pi );
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );
our @EXPORT = qw(
	create_filter
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

# Qの最小と最大値（このフィルターの仕様）
Readonly my $Q_MIN =>  0.1;
Readonly my $Q_MAX => 20.0;
Readonly my $CUTOFF_MIN => 0.0;
Readonly my $CUTOFF_MAX => 0.499; # cutoffが0.5だと計算途中でエラーになるのでこの値でガード

sub create_filter {
	my $samples_per_sec = shift;
	my $arg_ref = shift;

	if ( not exists $arg_ref->{type} ) {
		die '"type" not found. type: lpf, hpf, bpf, bef'
	}

	my $type = $arg_ref->{type};
	my $cutoff = 0.0;
	if ( exists $arg_ref->{cutoff} ) {
		$cutoff = $arg_ref->{cutoff};
	}
	else {
		die '"cutoff" not found. cutoff: ' . sprintf( "%f <= cutoff <= %f", $CUTOFF_MIN, $CUTOFF_MAX );
	}

	if ( $cutoff < $CUTOFF_MIN ) {
		die '"cutoff" must be or more ' . $CUTOFF_MIN;
	}
	
	if ( $CUTOFF_MAX < $cutoff ) {
		die '"cutoff" must be or less ' . $CUTOFF_MAX;
	}

	my $q = 1.0 / sqrt(2);
	if ( exists $arg_ref->{Q} ) {
		$q = $arg_ref->{Q};

		if ( $q < $Q_MIN ) {
			die '"Q" must be or more ' . $Q_MIN;
		}
	
		if ( $Q_MAX < $q ) {
			die '"Q" must be or less ' . $Q_MAX;
		}
	}

	printf( "filter: type: %s, cutoff = %.2f, Q = %.2f\n", $type, $cutoff, $q );

	return _create_filter_func( $type, $cutoff, $q );
}

sub _create_filter_func {
	my ( $type, $cutoff, $q ) = @_;

	if ( $type eq 'lpf' ) {
		# todo: LPFの係数算出
	}
	else {
		die 'sorry, coming soon ...';
	}

	# for LPF
	my $fc = tan(pi() * $cutoff) / (2.0 * pi());
	my $tmp = 1.0 + ((2.0 * pi() * $fc) / $q) + (4.0 * pi() * pi() * $fc * $fc); # 各係数の分母
	my $b0 = (4.0 * pi() * pi() * $fc * $fc) / $tmp;
	my $b1 = (8.0 * pi() * pi() * $fc * $fc) / $tmp;
	my $b2 = (4.0 * pi() * pi() * $fc * $fc) / $tmp;
	my $a1 = ((8.0 * pi() * pi() * $fc * $fc) - 2.0) / $tmp;
	my $a2 = (1.0 - ((2.0 * pi() * $fc) / $q) + (4.0 * pi() * pi() * $fc * $fc)) / $tmp;

	printf( "%.4f, %.4f, %.4f, %.4f, %.4f\n", $b0, $b1, $b2, $a1, $a2 );

	my @buf_a = ( 0.0, 0.0 );
	my @buf_b = ( 0.0, 0.0, 0.0 );
	return sub {
		unshift @buf_b, $_[0];
		pop @buf_b;
		my $ret = ($buf_b[2] * $b2) + ($buf_b[1] * $b1) + ($buf_b[0] * $b0)
		        - ($buf_a[1] * $a2) - ($buf_a[0] * $a1);
		unshift @buf_a, $ret;
		pop @buf_a;
		return $ret;
	};
}

1;
__END__

=head1 NAME

Sound::NeSynth:Modulator - Modulator module for NeSynth

=head1 SYNOPSIS

  my $samples_per_sec = 30;
  my $type = 'lpf';
  my $cutoff = 0.2; # must 0.0 <= cutoff <= 0.499
  my $q = 0.7; # must 0.01 <= q <= 20.0
  my $filter = create_filter( $samples_per_sec, { type => $type, cutoff => $cutoff, Q => $q } );
  
  # get response of 0.0 -> 1.0
  my @result = map {
    printf( "%f\n", $filter->(1.0) );
  } 1..10;

=head1 DESCRIPTION

  This filter module is for Sound::NeSynth.
  it's using IIR filter.

=head1 SEE ALSO

  Sound::NeSynth

=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
