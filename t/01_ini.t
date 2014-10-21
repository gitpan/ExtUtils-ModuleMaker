# t/01_ini.t - check module loading
use strict;
local $^W = 1;
use Test::More 
tests =>  5;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'File::Save::Home', qw|
    get_home_directory
    get_subhome_directory_status
    make_subhome_directory
    restore_subhome_directory_status
| );

my ($realhome);

ok( $realhome = get_home_directory(), 
    "HOME or home-equivalent directory found on system");

my $mmkr_dir_ref = get_subhome_directory_status(".modulemaker");
my $mmkr_dir = make_subhome_directory($mmkr_dir_ref);
ok( $mmkr_dir, "personal defaults directory found on system");

END {
    ok( restore_subhome_directory_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");
}

