# t/07_proxy.t
use strict;
local $^W = 1;
use Test::More tests => 49;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);

my $odir = cwd();
my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

########################################################################

my ($mod, $filetext);
my $testmod = 'Delta';

SKIP: {
    eval { require Module::Build };
    skip "Module::Build not installed", 44 if $@;

    ########## Variant:  'Module::Build and proxy Makefile.PL' ##########

    ok( 
        $mod = ExtUtils::ModuleMaker->new(
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build and proxy Makefile.PL',
            AUTHOR         => {
               'NAME'         => 'Phineas T. Bluster',
               'CPANID'       => 'PTBLUSTER',
               'ORGANIZATION' => 'Peanut Gallery',
               'EMAIL'        => 'phineas@anonymous.com',
               'WEBSITE'      => 'http://www.anonymous.com/~phineas',
            },
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );
    
    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
    
    for ( qw/Build.PL LICENSE Makefile.PL MANIFEST README Todo/) {
        ok( -f, "file $_ exists" );
    }
    ok(! -f 'Changes', 'Changes file correctly not created');
    for ( qw/lib scripts t/) {
        ok( -d, "directory $_ exists" );
    }
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');
    
    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');
    
    six_file_tests(8, $testmod); # first arg is # entries in MANIFEST

    ########## Variant:  'Module::Build and Proxy' ##########

    ok( 
        $mod = ExtUtils::ModuleMaker->new(
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build and Proxy',
            AUTHOR         => {
               'NAME'         => 'Phineas T. Bluster',
               'CPANID'       => 'PTBLUSTER',
               'ORGANIZATION' => 'Peanut Gallery',
               'EMAIL'        => 'phineas@anonymous.com',
               'WEBSITE'      => 'http://www.anonymous.com/~phineas',
            },
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );
    
    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
    
    for ( qw/Build.PL LICENSE Makefile.PL MANIFEST README Todo/) {
        ok( -f, "file $_ exists" );
    }
    ok(! -f 'Changes', 'Changes file correctly not created');
    for ( qw/lib scripts t/) {
        ok( -d, "directory $_ exists" );
    }
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');
    
    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');
    
    six_file_tests(8, $testmod); # first arg is # entries in MANIFEST
}
 
ok(chdir $odir, 'changed back to original directory after testing');

