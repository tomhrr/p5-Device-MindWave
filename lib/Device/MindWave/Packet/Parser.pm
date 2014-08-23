package Device::MindWave::Packet::Parser;

use strict;
use warnings;

use Device::MindWave::Packet::Dongle::HeadsetFound;
use Device::MindWave::Packet::Dongle::HeadsetNotFound;
use Device::MindWave::Packet::Dongle::HeadsetDisconnected;
use Device::MindWave::Packet::Dongle::RequestDenied;
use Device::MindWave::Packet::Dongle::StandbyMode;
use Device::MindWave::Packet::Dongle::ScanMode;

our $VERSION = 0.01;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub parse
{
    my ($self, $bytes) = @_;

    if ($bytes->[0] == 0xD0) {
        my ($hsu, $hsl) = (@{$bytes}[2..3]);
        return
            Device::MindWave::Packet::Dongle::HeadsetFound->new(
                $hsu, $hsl
            );
    } elsif ($bytes->[0] == 0xD1) {
        my ($hsu, $hsl) = (@{$bytes}[2..3]);
        return
            Device::MindWave::Packet::Dongle::HeadsetNotFound->new(
                $hsu, $hsl
            );
    } elsif ($bytes->[0] == 0xD2) {
        my ($hsu, $hsl) = (@{$bytes}[2..3]);
        return
            Device::MindWave::Packet::Dongle::HeadsetDisconnected->new(
                $hsu, $hsl
            );
    } elsif ($bytes->[0] == 0xD3) {
        return Device::MindWave::Packet::Dongle::RequestDenied->new();
    } elsif ($bytes->[0] == 0xD4) {
        if ($bytes->[2] == 0x00) {
            return Device::MindWave::Packet::Dongle::StandbyMode->new();
        } elsif ($bytes->[2] == 0x01) {
            return Device::MindWave::Packet::Dongle::ScanMode->new();
        }
    }

    die "Unable to parse packet.";
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::Parser

=head1 DESCRIPTION

Provides for parsing packet payloads and returning appropriate
instances of L<Device::MindWave::Packet> implementations.

=head1 CONSTRUCTOR

=over 4

=item B<new>

Returns a new instance of L<Device::MindWave::Packet::Parser>.

=back

=head1 PUBLIC METHODS

=over 4

=item B<parse>

Takes the packet payload as an arrayref of bytes as its single
argument. Returns a L<Device::MindWave::Packet> object representing
the packet.

The packet payload includes all the packet's data, except for the two
initial synchronisation bytes, the packet length byte and the final
checksum byte.

=back

=cut
