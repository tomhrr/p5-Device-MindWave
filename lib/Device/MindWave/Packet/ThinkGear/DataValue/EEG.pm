package Device::MindWave::Packet::ThinkGear::DataValue::EEG;

use strict;
use warnings;

use Device::MindWave::Utils qw(checksum);

use base qw(Device::MindWave::Packet::ThinkGear::DataValue);

my @FIELDS = qw(delta theta low_alpha high_alpha
                low_beta high_beta low_gamma high_gamma);

sub new
{
    my ($class, $bytes, $index) = @_;

    $index += 2;

    my @values;
    for (my $i = 0; $i < 8; $i++) {
        my $offset = $i * 3;
        push @values, (($bytes->[$index + $offset]     << 16) |
                       ($bytes->[$index + $offset + 1] << 8)  |
                       ($bytes->[$index + $offset + 2]));
    }

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

    return [ 0x83, 0x18, map { _value_to_three_bytes($self->{$_}) } @FIELDS ];
}

sub length
{
    return 26;
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

=item B<length>

=back

=cut
