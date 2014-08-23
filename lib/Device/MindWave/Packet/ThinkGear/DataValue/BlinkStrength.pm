package Device::MindWave::Packet::ThinkGear::DataValue::BlinkStrength;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::ThinkGear::DataValue);

sub new
{
    my ($class, $value) = @_;

    my $self = { value => $value };
    bless $self, $class;
    return $self;
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x16, $self->{'value'} ];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear::DataValue::BlinkStrength

=head1 DESCRIPTION

Implementation of the 'Blink Strength' data value. This is a
single-byte value in the range 0-255.

=head1 CONSTRUCTOR

=over 4

=item B<new>

=back

=head1 PUBLIC METHODS

=over 4

=item B<as_string>

=item B<data_as_bytes>

=back

=cut
