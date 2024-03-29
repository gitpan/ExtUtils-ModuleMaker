# t/miscargs/919.t
# tests of miscellaneous arguments passed to constructor
use strict;
local $^W = 1;
# use Test::More tests => 32;
use Test::More qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _save_pretesting_status
        _restore_pretesting_status
        read_file_string
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (32 - 10) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    my ($tdir, $mod, $testmod, $filetext);

    # Set 19:  Set CPANID to empty string and verify that no blank line is
    # added to the .pm file author info section.

    {   
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $testmod = 'Lambda';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                AUTHOR         => 'Phineas T. Bluster',
                CPANID         => q{},,
                ORGANIZATION   => 'Peanut Gallery',
                WEBSITE        => 'http://www.anonymous.com/~phineas',
                EMAIL          => 'phineas@anonymous.com',
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);

        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE      Makefile.PL 
                MANIFEST    README       Todo
            | );

        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
            );

        my @pm_pred = (
                "lib/Alpha/${testmod}.pm",
        );
        my @t_pred = (
                't/001_load.t',
        );
        ok( -f, "file $_ exists" ) for ( @pm_pred, @t_pred);
        my $line = read_file_string("lib/Alpha/${testmod}.pm");
        ok($line =~ m|
                Phineas\sT\.\sBluster\n
                [ \t]+Peanut\sGallery\n
                \s+phineas\@anonymous\.com\n
                \s+http:\/\/www\.anonymous\.com\/~phineas
            |xs,
            'POD contains correct author info -- no CPANID');
    }

    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}

