package Device::MindWave;

use strict;
use warnings;

use Device::SerialPort;

our $VERSION = '0.01';

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

1;

__END__

=head1 NAME

Device::MindWave - Read data from a NeuroSky MindWave headset

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Device::MindWave;

    my $foo = Device::MindWave->new();
    ...

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=over 4

=item B<new>

=back

=head1 PUBLIC METHODS

=head1 PACKET TYPES

=head1 AUTHOR

Tom Harrison, C<< <tomhrr at cpan.org> >>

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT AND LICENCE

Copyright (C) 2014 Tom Harrison

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
