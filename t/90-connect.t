#!perl
use 5.006;
use strict;
use warnings;

use Test::More tests => 18;

use Device::MindWave;
use Device::MindWave::Tester;

{
    my $mwt = Device::MindWave::Tester->new();
    my $mw = Device::MindWave->new(fh => $mwt);
    $mw->connect_nb('1234');

    $mwt->push_bytes(0xAA, 0xAA, 0x04, 0xD0, 0x02, 0x05, 0x05, 0x23);
    my $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::HeadsetFound');
    is($packet->code(), 0xD0, 'Packet has correct code');

    $mwt->push_bytes(0xAA, 0xAA, 0x04, 0xD1, 0x02, 0x05, 0x05, 0x22);
    $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::HeadsetNotFound');
    is($packet->code(), 0xD1, 'Packet has correct code');

    $mwt->push_bytes(0xAA, 0xAA, 0x04, 0xD2, 0x02, 0x05, 0x05, 0x21);
    $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::HeadsetDisconnected');
    is($packet->code(), 0xD2, 'Packet has correct code');

    $mwt->push_bytes(0xAA, 0xAA, 0x02, 0xD3, 0x00, 0x2C);
    $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::RequestDenied');
    is($packet->code(), 0xD3, 'Packet has correct code');

    $mwt->push_bytes(0xAA, 0xAA, 0x03, 0xD4, 0x01, 0x00, 0x2A);
    $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::StandbyMode');
    is($packet->code(), 0xD4, 'Packet has correct code');

    $mwt->push_bytes(0xAA, 0xAA, 0x03, 0xD4, 0x01, 0x01, 0x29);
    $packet = $mw->read_packet();
    isa_ok($packet, 'Device::MindWave::Packet');
    isa_ok($packet, 'Device::MindWave::Packet::Dongle::ScanMode');
    is($packet->code(), 0xD5, 'Packet has correct code');
}

1;
