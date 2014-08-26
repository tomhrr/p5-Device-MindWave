package Device::MindWave::Packet::Dongle::StandbyMode;

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
    return 0xD4;
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x03, 0xD4, 0x01, 0x00 ];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::Dongle::StandbyMode

=head1 DESCRIPTION

Implementation of the 'Dongle in Standby Mode' packet (number 5 in the
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
