use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'ExtUtils::ModuleMaker',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker.pm', # finds $VERSION
    AUTHOR       => 'R. Geoffrey Avery (modulemaker@PlatypiVentures.com)',
    ABSTRACT     => 'A simple replacement for h2xs -XA',
	EXE_FILES    => [
						'scripts/modulemaker',
					],
    PREREQ_PM    => {
						Test::More      => 0.44,
						Getopt::Std		=> 0, # in the Perl core
						Getopt::Long    => 0, # in the Perl core
						File::Basename	=> 0, # in the Perl core
						File::Path		=> 0, # in the Perl core
					},
);
