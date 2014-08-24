package Device::MindWave::Packet::ThinkGear::DataValue::EEG;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::ThinkGear::DataValue);

my @FIELDS = qw(delta theta low_alpha high_alpha
                low_beta high_beta low_gamma high_gamma);

sub new
{
    my ($class, @values) = @_;

    my $self = {};
    @{$self}{@FIELDS} = @values;
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

    return [ 0x18, map { _value_to_three_bytes($self->{$_}) } @FIELDS ];
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear::DataValue::EEG

=head1 DESCRIPTION

Implementation of the 'ASIC EEG' data value. This is a series of raw
EEG values.

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
