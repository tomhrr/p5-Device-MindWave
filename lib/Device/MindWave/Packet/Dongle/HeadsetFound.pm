package Device::MindWave::Packet::Dongle::HeadsetFound;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::Dongle);

sub new
{
    my ($class, $hsu, $hsl) = @_;

    my $self = { headset_upper => $hsu,
                 headset_lower => $hsl };
    bless $self, $class;
    return $self;
}

sub code
{
    return 0xD0;
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x04, 0xD0, 0x02,
             $self->{'headset_upper'},
             $self->{'headset_lower'} ];
}

sub as_bytes
{
    my ($self) = @_;

    my $bytes = $self->data_as_bytes();
    my $checksum = checksum($bytes);

    return [ 0xAA, 0xAA, @{$bytes}, $checksum ];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::Dongle::HeadsetFound

=head1 DESCRIPTION

Implementation of the 'Headset Found' packet (number 1 in the
documentation).

=head1 CONSTRUCTOR

=over 4

=item B<new>

=back

=head1 PUBLIC METHODS

=over 4

=item B<code>

=item B<as_bytes>

=item B<data_as_bytes>

=back

=cut
