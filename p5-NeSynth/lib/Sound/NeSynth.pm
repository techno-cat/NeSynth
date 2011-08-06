package Sound::NeSynth;

use 5.008009;
use strict;
use warnings;
use Math::Trig qw( pi );
use Sound::WaveFile; 
use Sound::WaveFile qw( save_as_wav );
use base qw( Exporter );

use constant DEFAULT_SAMPLES_PER_SEC => 44100;

our %EXPORT_TAGS = ( 'all' => [ qw(
	test_tone
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

sub new {
	my $pkg = shift;

	# サンプリング周波数の設定
	my $samples_per_sec = DEFAULT_SAMPLES_PER_SEC;
	if ( 0 < scalar(@_) ) {
		$samples_per_sec = shift;
	}

	bless {
		samples_per_sec => $samples_per_sec,
		samples_ref => []
	};
}

sub get_samples_per_sec {
	my $self = shift;
	return $self->{samples_per_sec};
}

sub get_samples_count {
	my $self = shift;
	return scalar( @{$self->{samples_ref}} );
}

sub write {
	my $self = shift;
	my $filename = shift;

	save_as_wav(
		$filename,
		$self->{samples_per_sec},
		BITS_PER_SAMPLE_16,
		$self->{samples_ref} );
}

sub test_tone {
	my $filename = shift;
	my $freq = shift;
	my $sec = shift;

	my $samples_per_sec = DEFAULT_SAMPLES_PER_SEC;

	my $osc = sub {
		my $x = shift;
		return sin( 2.0 * pi() * $x );
	};

	my @samples = ();
	my $cnt = $samples_per_sec * $sec;
	for (my $i=0; $i<$cnt; $i++) {
		push @samples, $osc->( $i / ($samples_per_sec / $freq) );
	}

	save_as_wav(
		$filename,
		$samples_per_sec,
		BITS_PER_SAMPLE_16,
		\@samples );
}

1;
__END__

=head1 NAME

Sound::NeSynth - Perl extension for Synthsis

=head1 SYNOPSIS

  use Sound::NeSynth qw( test_tone );
  
  # 440Hz, 1sec => test.wav
  test_tone( 'test.wav', 440, 1 );

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
