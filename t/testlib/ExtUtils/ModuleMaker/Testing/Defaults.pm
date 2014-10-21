package ExtUtils::ModuleMaker::Testing::Defaults;
# as of 08/24/2005
use strict;
local $^W = 1;

my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

my %default_values = (
        NAME             => q{EU::MM::Testing::Defaults},
        LICENSE          => q{perl},
        VERSION          => 0.01,
        ABSTRACT         => q{Module abstract (<= 44 characters) goes here},
        AUTHOR           => q{Hilton Stallone},
        CPANID           => q{RAMBO},
        ORGANIZATION     => q{Parliamentary Pictures},
        WEBSITE          => q{http://parliamentarypictures.com},
        EMAIL            => q{hiltons@parliamentarypictures.com},
        BUILD_SYSTEM     => q{ExtUtils::MakeMaker},
        COMPACT          => 0,
        VERBOSE          => 0,
        INTERACTIVE      => 0,
        NEED_POD         => 1,
        NEED_NEW_METHOD  => 1,
        CHANGES_IN_POD   => 0,
        PERMISSIONS      => 0755,
        SAVE_AS_DEFAULTS => 0,
        USAGE_MESSAGE    => $usage,
);

sub default_values {
    my $self = shift;
    return { %default_values };
}

1;

