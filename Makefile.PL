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

);
