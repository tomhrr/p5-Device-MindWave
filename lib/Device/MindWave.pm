package Device::MindWave;

use strict;
use warnings;

use Device::SerialPort;
use Device::MindWave::Utils qw(checksum
                               packet_isa);
use Device::MindWave::Packet::Parser;

use constant TRIES => 20;

our $VERSION = '0.01';

sub new
{
    my $class = shift;
    my %args = @_;

    my $port;
    if (exists $args{'fh'}) {
        $port = $args{'fh'};
    } elsif (exists $args{'port'}) {
        $port = Device::SerialPort->new($args{'port'});
        if (not $port) {
            die "Cannot open ".($args{'port'}).": $!";
        }
        $port->baudrate(115200);
        $port->user_msg(0);
        $port->parity("even");
        $port->databits(8);
        $port->stopbits(1);
        $port->handshake("none");
        $port->write_settings();
    } else {
        die "Either 'fh' or 'port' must be provided.";
    }

    my $self = { port   => $port,
                 is_fh  => (exists $args{'fh'}),
                 parser => Device::MindWave::Packet::Parser->new() };
    bless $self, $class;
    return $self;
}

sub _read
{
    my ($self, $len) = @_;

    if ($self->{'is_fh'}) {
        my $buf;
        my $bytes = $self->{'port'}->read($buf, $len);
        return ($buf, $bytes);
    } else {
        my $buf = $self->{'port'}->read($len);
        return ($buf, (length $buf));
    }
}

sub _write
{
    my ($self, $data) = @_;

    if ($self->{'is_fh'}) {
        $self->{'port'}->write($data, (length $data), 0);
    } else {
        $self->{'port'}->write($data);
    }

    return 1;
}

sub _write_bytes
{
    my ($self, $bytes) = @_;

    my $data = join '', map { chr($_) } @{$bytes};
    return $self->_write($data);
}

sub _to_headset_id_bytes
{
    my ($upper, $lower) = @_;

    if ($upper > 255) {
        $lower = $upper & 0xFF;
        $upper = ($upper >> 8) & 0xFF;
    }

    return ($upper, $lower);
}

sub connect_nb
{
    my ($self, $upper, $lower) = @_;

    ($upper, $lower) = _to_headset_id_bytes($upper, $lower);
    $self->_write_bytes([ 0xC0, $upper, $lower ]);
    return 1;
}

sub connect
{
    my ($self, @args) = @_;

    $self->connect_nb(@args);

    my $tries = 15;
    while ($tries--) {
        my $packet = $self->read_packet();
        if (packet_isa($packet, 'Dongle::HeadsetFound')) {
            return 1;
        } elsif (packet_isa($packet, 'Dongle::HeadsetNotFound')) {
            die "Headset not found.";
        } elsif (packet_isa($packet, 'Dongle::RequestDenied')) {
            die "Request denied by dongle.";
        }
        sleep 1;
    }

    die "Unable to connect to headset.";
}

sub auto_connect_nb
{
    my ($self) = @_;

    $self->_write_bytes([ 0xC2 ]);

    return 1;
}

sub auto_connect
{
    my ($self) = @_;

    $self->auto_connect_nb();

    my $tries = 15;
    while ($tries--) {
        my $packet = $self->read_packet();
        if (packet_isa($packet, 'Dongle::HeadsetFound')) {
            return 1;
        } elsif (packet_isa($packet, 'Dongle::HeadsetNotFound')) {
            die "No headset was found.";
        } elsif (packet_isa($packet, 'Dongle::RequestDenied')) {
            die "Request denied by dongle.";
        }
        sleep 1;
    }

    die "Unable to connect to any headset.";
}

sub disconnect_nb
{
    my ($self) = @_;

    $self->_write_bytes([ 0xC1 ]);
    
    return 1;
}

sub disconnect
{
    my ($self) = @_;

    $self->disconnect_nb();

    my $tries = 15;
    while ($tries--) {
        my $packet = $self->read_packet();
        if (packet_isa($packet, 'Dongle::HeadsetDisconnected')) {
            return 1;
        } elsif (packet_isa($packet, 'Dongle::RequestDenied')) {
            die "Request denied by dongle.";
        }
        sleep 1;
    }

    die "Unable to disconnect from headset.";
}

sub read_packet
{
    my ($self) = @_;

    my $tries = TRIES();
    my $prev_byte = 0;
    while ($tries--) {
        my ($byte, undef) = $self->_read(1);
        if (((ord $prev_byte) == 0xAA) and ((ord $byte) == 0xAA)) {
            last;
        } else {
            $prev_byte = $byte;
        }
    }

    if ($tries == 0) {
        die "Unable to find synchronisation bytes (read ".(TRIES())." bytes).";
    }

    my ($len, undef) = $self->_read(1);
    $len = ord $len;
    if (($len < 0) or ($len > 169)) {
        die "Length byte has invalid value ($len): expected 0-169.";
    }

    my $data = '';
    $tries = TRIES();
    my $remaining = $len;
    while ((length $data != $len) and ($tries--)) {
        my ($new_data, undef) = $self->_read($remaining);
        $data .= $new_data;
        $remaining = $len - (length $data);
    }
    my @bytes = map { ord $_ } split //, $data;

    my $len_actual = @bytes;
    if ($len != $len_actual) {
        die "Length from packet ($len) does not match actual length ".
            "($len_actual).";
    }

    my ($checksum, undef) = $self->_read(1);
    $checksum = ord $checksum;
    my $checksum_actual = checksum(@bytes);

    if ($checksum != $checksum_actual) {
        die "Checksum ($checksum) from packet does not match ".
            "actual checksum ($checksum_actual).";
    }

    return $self->{'parser'}->parse(\@bytes);
}

1;

__END__

=head1 NAME

Device::MindWave

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Device::MindWave;

    my $mw = Device::MindWave->new(port => '/dev/ttyUSB0');
    $mw->auto_connect();
    while (my $packet = $mw->read_packet()) {
        print $packet->as_string(),"\n";
    }
    ...

=head1 DESCRIPTION

Provides for connecting to and disconnecting from a NeuroSky MindWave
headset, as well as reading and parsing the data that it produces.

=head1 CONSTRUCTOR

=over 4

=item B<new>

Arguments (hash):

=over 8

=item port

The port name (e.g. 'COM4', '/dev/ttyUSB0').

=item fh

An object representing the MindWave. Must implement C<read> and
C<write>, as per L<IO::Handle>.

=back

One of C<port> and C<fh> must be provided. Returns a new instance of
L<Device::MindWave>.

=back

=head1 PUBLIC METHODS

=over 4

=item B<connect_nb>

=item B<connect>

=item B<auto_connect_nb>

=item B<auto_connect>

=item B<disconnect_nb>

=item B<disconnect>

=item B<read_packet>

=back

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
