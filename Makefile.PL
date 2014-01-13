use ExtUtils::MakeMaker;
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
);
