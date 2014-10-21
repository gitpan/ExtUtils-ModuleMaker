package ExtUtils::ModuleMaker::Defaults;
# as of 09-05-2005
use strict;
use vars qw( $VERSION );
$VERSION = '0.39';

my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

my %default_values = (
        LICENSE          => 'perl',
        VERSION          => '0.01',
        ABSTRACT         => 'Module abstract (<= 44 characters) goes here',
        AUTHOR           => 'A. U. Thor',
        CPANID           => 'MODAUTHOR',
        ORGANIZATION     => 'XYZ Corp.',
        WEBSITE          => 'http://a.galaxy.far.far.away/modules',
        EMAIL            => 'a.u.thor@a.galaxy.far.far.away',
        BUILD_SYSTEM     => 'ExtUtils::MakeMaker',
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

=head1 NAME

ExtUtils::ModuleMaker::Defaults - Default values for ExtUtils::ModuleMaker objects

=head1 METHODS

=head3 C<default_values()>

  Usage     : $self->default_values() within new(); within
              ExtUtils::ModuleMaker::Interactive::_prepare_author_defaults() 
              and _prepare_directives_defaults(); 
              within t/testlib/Testing/Defaults.pm
  Purpose   : Set the default values for ExtUtils::ModuleMaker object elements
  Returns   : Reference to a hash of default values
  Argument  : n/a
  Comment   : Can be overridden by establishing a Personal::Defaults file.

=cut

1;
