package Device::MindWave::Utils;

use strict;
use warnings;

use List::Util qw(sum);

use base qw(Exporter);
our @EXPORT_OK = qw(checksum);

sub checksum
{
    my @bytes = @_;

    my $sum = sum(0, @bytes);
    my $byte = $sum & 0xFF;
    return ((~$byte) & 0xFF);
}

1;

__END__

=head1 NAME

Device::MindWave::Utils

=head1 DESCRIPTION

Utility functions used in various libraries.

=head1 PUBLIC FUNCTIONS

=over 4

=item B<checksum>

Takes a list of bytes as its arguments. Returns the checksum of those
bytes as an integer. The checksum is calculated by summing the bytes,
taking the lowest eight bits, and returning the one's complement of
that value.

=back

=cut
