package Device::MindWave::Packet::Dongle::RequestDenied;

use strict;
use warnings;

use base qw(Device::MindWave::Packet::Dongle);

sub new
{
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub code
{
    return 0xD3;
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x02, 0xD3, 0x00 ];
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

Device::MindWave::Packet::Dongle::RequestDenied

=head1 DESCRIPTION

Implementation of the 'Request Denied' packet (number 4 in the
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
