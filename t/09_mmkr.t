# t/09_mmkr.t
use strict;
local $^W = 1;
use Test::More 
# tests => 8;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok('File::Temp', qw| tempdir |); }
BEGIN { use_ok('Cwd'); }
use lib ("./t/testlib");
use _Auxiliary qw(
    check_MakefilePL 
    check_pm_file
    make_compact
);

# Simple tests of modulemaker utility in non-interactive mode

my $cwd = cwd();
my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred);

{
    # provide name and call for compact top-level directory

    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC}),
        "able to call modulemaker utility");

    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
    @pred = (
        "XYZ::ABC",
        "lib\/XYZ\/ABC\.pm",
        "A\.\\sU\.\\sThor",
        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
    );
    check_MakefilePL($topdir, \@pred);
    ok(chdir $cwd, 'changed back to original directory after testing');
}

{
    # provide name and call for compact top-level directory
    # add in abstract
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\"}),  #"
        "able to call modulemaker utility with abstract");

    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
    @pred = (
        "XYZ::ABC",
        "lib\/XYZ\/ABC\.pm",
        "A\.\\sU\.\\sThor",
        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
        "This\\sis\\svery\\sabstract\.",
    );
    check_MakefilePL($topdir, \@pred);
    ok(chdir $cwd, 'changed back to original directory after testing');
}

{
    # provide name and call for compact top-level directory
    # add in abstract and author-name
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\"}), #"
        "able to call modulemaker utility with abstract");

    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
    @pred = (
        "XYZ::ABC",
        "lib\/XYZ\/ABC\.pm",
        "John\\sQ\\sPublic",
        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
        "This\\sis\\svery\\sabstract\.",
    );
    check_MakefilePL($topdir, \@pred);
    ok(chdir $cwd, 'changed back to original directory after testing');
}

{
    # provide name and call for compact top-level directory
    # add in abstract and author-name and e-mail
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\" -e jqpublic\@calamity.jane.net}),   #"
        "able to call modulemaker utility with abstract");

    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
    @pred = (
        "XYZ::ABC",
        "lib\/XYZ\/ABC\.pm",
        "John\\sQ\\sPublic",
        "jqpublic\@calamity\.jane\.net",
        "This\\sis\\svery\\sabstract\.",
    );
    check_MakefilePL($topdir, \@pred);
    ok(chdir $cwd, 'changed back to original directory after testing');
}

{
    # provide name and call for compact top-level directory
    # call option to omit POD from .pm file
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    $module_name = 'XYZ::ABC';
    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -IcPn "$module_name" }),
        "able to call modulemaker utility");

    ($topdir, $pmfile) = make_compact($module_name); 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    ok(-f $pmfile, "$pmfile created");
    
    %pred = (
        'pod_present'       => 0,
    );
    check_pm_file($pmfile, \%pred);

    ok(chdir $cwd, 'changed back to original directory after testing');
}

{
    # provide name and call for compact top-level directory
    # call option to omit constructor (sub new()) from .pm file
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    $module_name = 'XYZ::ABC';
    ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icqn "$module_name" }),
        "able to call modulemaker utility");

    ($topdir, $pmfile) = make_compact($module_name); 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    ok(-f $pmfile, "$pmfile created");
    
    %pred = (
        'constructor_present'       => 0,
    );
    check_pm_file($pmfile, \%pred);

    ok(chdir $cwd, 'changed back to original directory after testing');
}

