package Device::MindWave::Packet::Parser;

use strict;
use warnings;

use Device::MindWave::Packet::Dongle::HeadsetFound;
use Device::MindWave::Packet::Dongle::HeadsetNotFound;
use Device::MindWave::Packet::Dongle::HeadsetDisconnected;
use Device::MindWave::Packet::Dongle::RequestDenied;
use Device::MindWave::Packet::Dongle::StandbyMode;
use Device::MindWave::Packet::Dongle::ScanMode;
use Device::MindWave::Packet::ThinkGear;
use Device::MindWave::Packet::ThinkGear::DataValue::PoorSignal;
use Device::MindWave::Packet::ThinkGear::DataValue::Attention;
use Device::MindWave::Packet::ThinkGear::DataValue::Meditation;
use Device::MindWave::Packet::ThinkGear::DataValue::BlinkStrength;
use Device::MindWave::Packet::ThinkGear::DataValue::RawWave;
use Device::MindWave::Packet::ThinkGear::DataValue::EEG;

our $VERSION = 0.01;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub _parse_thinkgear_data_value
{
    my ($self, $bytes, $index) = @_;

    my $excode = 0;
    for (; $index < @{$bytes}; $index++) {
        if ($bytes->[$index] == 0x55) {
            $excode++;
        } else {
            last;
        }
    }

    my $code = $bytes->[$index];
    if (not defined $code) {
        die "No code found in ostensible ThinkGear data value.";
    }

    if (($code > 0) and ($code < 0x7F)) {
        $index++;
        my $value = $bytes->[$index];
        $index++;

        if ($code == 0x02) {
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::PoorSignal->new($value);
            return ($packet, $index);
        } elsif ($code == 0x04) {
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::Attention->new($value);
            return ($packet, $index);
        } elsif ($code == 0x05) {
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::Meditation->new($value);
            return ($packet, $index);
        } elsif ($code == 0x16) {
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::BlinkStrength->new($value);
            return ($packet, $index);
        } else {
            warn "Unhandled single-byte value code: $code";
            return (undef, $index);
        }
    } else {
        $index++;
        my $length = $bytes->[$index];
        $index++;

        if ($code == 0x80) {
            my $upper = $bytes->[$index];
            my $lower = $bytes->[$index + 1];
            my $value = ($upper << 8) | $lower;
            if ($value > 32767) {
                $value -= 65535;
            }
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::RawWave->new($value);
            return ($packet, ($index + 2));
        } elsif ($code == 0x83) {
            my @values;
            for (my $i = 0; $i < 8; $i++) {
                my $offset = $i * 3;
                push @values, (($bytes->[$index + $offset]     << 16) |
                               ($bytes->[$index + $offset + 1] << 8)  |
                               ($bytes->[$index + $offset + 2]));
            }
            my $packet = Device::MindWave::Packet::ThinkGear::DataValue::EEG->new(@values);
            return ($packet, ($index + 24));
        } else {
            $index += $length;
            warn "Unhandled multi-byte value code: $code";
            return (undef, $index);
        }
    }
}

sub _parse_thinkgear
{
    my ($self, $bytes) = @_;

    my $index = 0;
    my $length = @{$bytes};
    my @dvs;
    my $dv;
    while ($index < $length) {
        ($dv, $index) = $self->_parse_thinkgear_data_value($bytes, $index);
        if (defined $dv) {
            push @dvs, $dv;
        }
    }

    return Device::MindWave::Packet::ThinkGear->new(@dvs);
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
    } else {
        return $self->_parse_thinkgear($bytes);
    }
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
