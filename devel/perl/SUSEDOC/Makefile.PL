use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SUSEDOC',
    AUTHOR              => q{Juergen Weigert <jw@suse.de>},
    VERSION_FROM        => 'SUSEDOC.pm',
    ABSTRACT_FROM       => 'SUSEDOC.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', POSTOP => 'sh ./mkdist.sh' },
    clean               => { FILES => [ 'SUSEDOC-*', '*.orig' ] },
);
