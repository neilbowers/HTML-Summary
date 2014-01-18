use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	        => 'HTML::Summary',
    'VERSION_FROM'  => 'lib/HTML/Summary.pm', # finds $VERSION
    'PREREQ_PM'     => {
        'Jcode'             => '2.06',
        'HTML::TreeBuilder' => 0,
        'constant'          => 0,
        'vars'              => 0,
        'strict'            => 0,
        'warnings'          => 0,
        'Exporter'          => 0,
    },

    ($mm_ver >= 6.48
        ? (MIN_PERL_VERSION => 5.006)
        : ()
    ),

    ($mm_ver >= 6.31
        ? (LICENSE => 'perl')
        : ()
    ),

    ($mm_ver <= 6.45
        ? ()
        : (META_MERGE => {
            'meta-spec' => { version => 2 },
            resources => {
                bugtracker  => 'http://rt.cpan.org/Public/Dist/Display.html?Name=HTML-Summary',
                repository  => {
                    type => 'git',
                    web  => 'https://github.com/neilbowers/HTML-Summary',
                    url  => 'git://github.com/neilbowers/HTML-Summary.git',
                },
            },
          })
    ),

);

