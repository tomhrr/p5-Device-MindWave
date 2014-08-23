package Device::MindWave::Packet::ThinkGear;

use strict;
use warnings;

use base qw(Device::MindWave::Packet);

our $VERSION = 0.01;

sub new
{
    my $class = shift;
    my $self = { data_values => \@_, index => 0 };
    bless $self, $class;
    return $self;
}

sub next_data_value
{
    my ($self) = @_;

    return $self->{'data_values'}->[$self->{'index'}++];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear

=head1 DESCRIPTION

Implementation of the ThinkGear packet. See
L<http://wearcam.org/ece516/mindset_communications_protocol.pdf> for
documentation on this type of packet.

The C<ThinkGear::DataValue> modules are used to store the 'actual'
data: this module simply provides an iterator over those data values.

=head1 CONSTRUCTOR

=over 4

=item B<new>

=back

=head1 PUBLIC METHODS

=over 4

=item B<next_data_value>

Return the next C<ThinkGear::DataValue> from the packet. Returns
the undefined value if no data values remain.

=back

=cut
