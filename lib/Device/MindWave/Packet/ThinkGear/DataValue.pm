package Device::MindWave::Packet::ThinkGear::DataValue;

use strict;
use warnings;

our $VERSION = 0.01;

sub as_string
{
    die "Abstract method 'as_string' not implemented.";
}

sub data_as_bytes
{
    die "Abstract method 'data_as_bytes' not implemented.";
}

1;

__END__

=head1 NAME

Device::MindWave::Packet::ThinkGear::DataValue

=head1 DESCRIPTION

Interface module for MindWave ThinkGear data values.

=head1 PUBLIC METHODS

=over 4

=item B<as_string>

Returns the data value's details as a human-readable string.

=item B<data_as_bytes>

Returns the data value's payload as an arrayref of bytes.

=back

=cut
