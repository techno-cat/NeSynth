package Sound::NeSynth;

use 5.008009;
use strict;
use warnings;
use Math::Trig qw( pi );
use Sound::WaveFile; 
use Sound::WaveFile qw( save_as_wav );
use base qw( Exporter );

our %EXPORT_TAGS = ( 'all' => [ qw(
	test_tone
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

sub new {
	my $pkg = shift;
	bless {};
}

sub test_tone {
	my $filename = shift;
	my $freq = shift;
	my $sec = shift;

	my $samples_per_sec = 44100;
	my $bits_per_sample = BITS_PER_SAMPLE_16;

	my $osc = sub {
		my $x = shift;
		return sin( 2.0 * pi() * $x );
	};

	my @samples = ();
	my $cnt = $samples_per_sec * $sec;
	for (my $i=0; $i<$cnt; $i++) {
		push @samples, $osc->( $i / ($samples_per_sec / $freq) );
	}

	save_as_wav( $filename, $samples_per_sec, $bits_per_sample, \@samples );
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
