# t/16_mmkr_alt_no_Todo.t
use strict;
local $^W = 1;
use vars qw( @INC );
use Test::More 
tests =>  32;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
        _identify_pm_files_in_personal_dir
        _hide_pm_files_in_personal_dir
        _reveal_pm_files_in_personal_dir
    )
);
use lib ("./t/testlib");
use_ok( 'Auxiliary', qw(
        read_file_string
        read_file_array
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
        _tests_pm_hidden
    )
);
use_ok( 'File::Copy' );
use Carp;


SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (32 - 5) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, @filelines, %lines);

    ########################################################################

    {   # Set 1
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $persref;

        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 1, hidden => 0 });

        _hide_pm_files_in_personal_dir($persref);
        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 0, hidden => 1 });

        # real tests go here

        my $alt = "ExtUtils/ModuleMaker/Alt_no_Todo.pm";
        copy( "$odir/t/testlib/$alt", "$mmkr_dir/$alt")
            or die "Unable to copy $alt for testing: $!";
        ok(-f "$mmkr_dir/$alt", "file copied for testing");

        $testmod = 'Beta';
        
        ok(! system(qq{$^X -I"$odir/blib/lib" "$odir/blib/script/modulemaker" -Icn Alpha::$testmod -d ExtUtils::ModuleMaker::Alt_no_Todo }), 
            "able to call modulemaker utility");

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README/);
        ok(! -f "Todo", "Todo not created");
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );

        unlink( "$mmkr_dir/$alt" )
            or croak "Unable to unlink $alt for testing: $!";
        ok(! -f "$mmkr_dir/$alt", "file $alt deleted after testing");

        _reveal_pm_files_in_personal_dir($persref);
        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 1, hidden => 0 });

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
} # end SKIP block



