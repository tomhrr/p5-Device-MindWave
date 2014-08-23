use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Device::MindWave',
    AUTHOR           => q{Tom Harrison <tomhrr@cpan.org>},
    VERSION_FROM     => 'lib/Device/MindWave.pm',
    ABSTRACT         => 'Read data from a NeuroSky MindWave headset',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Device::SerialPort' => 0,
        'IO::File'           => 0,
        'List::Util'         => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Device-MindWave-*' },
);
