package Device::MindWave::Packet::ThinkGear::DataValue::EEG;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::ThinkGear::DataValue);

sub new
{
    my ($class, @values) = @_;

    my $self = { delta      => $values[0],
                 theta      => $values[1],
                 low_alpha  => $values[2],
                 high_alpha => $values[3],
                 low_beta   => $values[4],
                 high_beta  => $values[5],
                 low_gamma  => $values[6],
                 high_gamma => $values[7], };
    bless $self, $class;
    return $self;
}

sub _value_to_three_bytes
{
    my ($value) = @_;

    return ((($value >> 16) & 0xFF),
            (($value >> 8)  & 0xFF),
            (($value)       & 0xFF));
}

sub data_as_bytes
{
    my ($self) = @_;

    return [ 0x18,
             map { _value_to_three_bytes($self->{$_}) }
                 qw(delta theta low_alpha high_alpha
                    low_beta high_beta low_gamma high_gamma) ];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear::DataValue::RawWave

=head1 DESCRIPTION

Implementation of the 'RAW Wave' data value. This is a 16-bit signed
(two's complement) value.

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
