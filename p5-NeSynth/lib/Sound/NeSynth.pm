package Sound::NeSynth;

use 5.008009;
use strict;
use warnings;
use Math::Trig qw( pi );

use Sound::WaveFile qw(save_as_wav);

our $VERSION = '0.01';

# Preloaded methods go here.
sub test_tone {
	my $filename = shift;
	my $freq = shift;
	my $sec = shift;

	my $samples_per_sec = 44100;
	my $bits_per_sample = 16;

	my $osc = sub {
		my $x = shift;
		return sin( 2.0 * pi() * $x );
	};

	my @samples = ();
	my $cnt = $samples_per_sec * $sec;
	for (my $i=0; $i<$cnt; $i++) {
		push @samples, $osc->( $i / ($samples_per_sec / $freq) );
	}

	Sound::WaveFile::save_as_wav( $filename, $samples_per_sec, $bits_per_sample, \@samples );
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Sound::NeSynth - Perl extension for Synthsis

=head1 SYNOPSIS

  use Sound::NeSynth;
  
  # 440Hz, 1sec => test.wav
  Sound::NeSynth::test_tone( 'test.wav', 440, 1 );

=head1 DESCRIPTION

perl meats groove!

=head2 EXPORT

None by default.

=head1 SEE ALSO

Sound::WaveFile

=head1 AUTHOR

techno-cat, E<lt>techno.cat.miau(at)gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by techno-cat

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.13.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
