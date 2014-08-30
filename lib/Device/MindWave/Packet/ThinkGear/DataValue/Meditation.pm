package Device::MindWave::Packet::ThinkGear::DataValue::Meditation;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::ThinkGear::DataValue);

sub new
{
    my ($class, $bytes, $index) = @_;

    my $self = { value => $bytes->[$index + 1] };
    bless $self, $class;
    return $self;
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x05, $self->{'value'} ];
}

sub length
{
    return 2;
}

sub as_string
{
    my ($self) = @_;

    return "Meditation (".$self->{'value'}."/100)";
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear::DataValue::Meditation

=head1 DESCRIPTION

Implementation of the 'Meditation' data value. This is a single-byte
value in the range 0-100.

=head1 CONSTRUCTOR

=over 4

=item B<new>

=back

=head1 PUBLIC METHODS

=over 4

=item B<as_string>

=item B<data_as_bytes>

=item B<length>

=back

=cut
