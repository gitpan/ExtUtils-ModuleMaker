package ExtUtils::ModuleMaker::Interactive;
use strict;
local $^W = 1;
use ExtUtils::ModuleMaker;
use ExtUtils::ModuleMaker::Licenses::Standard;
use ExtUtils::ModuleMaker::Licenses::Local;
# use File::Path;
use Carp;
use Exporter;
use vars qw ( @ISA @EXPORT_OK );
@ISA = qw( Exporter );
@EXPORT_OK  = qw( run_interactive );

# This package is designed solely to house subroutines used in
# modulemaker's interactive mode.

########## BEGIN DECLARATIONS ##########

my %Author_Menu = (
    N => [ 'Name        ', 'NAME' ],
    C => [ 'CPAN ID     ', 'CPANID' ],
    O => [ 'Organization', 'ORGANIZATION' ],
    W => [ 'Website     ', 'WEBSITE' ],
    E => [ 'Email       ', 'EMAIL' ],
);

my %Directives_Menu = (
    C => [ 'Compact        ', 'COMPACT' ],
    P => [ 'Permissions    ', 'PERMISSIONS' ],
    V => [ 'Verbose        ', 'VERBOSE' ],
    D => [ 'Include POD    ', 'NEED_POD' ],
    N => [ 'Include new    ', 'NEED_NEW_METHOD' ],
    H => [ 'History in POD ', 'CHANGES_IN_POD' ],
);

my %Flagged =
  ( ( map { $_ => 0 } qw (0 N F) ), ( map { $_ => 1 } qw (1 Y T) ), );

my $License_Standard = ExtUtils::ModuleMaker::Licenses::Standard->interact();
my $License_Local    = ExtUtils::ModuleMaker::Licenses::Local->interact();
my @lic              = (
    (
        map { [ $_, $License_Standard->{$_} ] }
          sort { $License_Standard->{$a} cmp $License_Standard->{$b} }
          keys( %{$License_Standard} )
    ),
    (
        map { [ $_, $License_Local->{$_} ] }
          sort { $License_Standard->{$a} cmp $License_Standard->{$b} }
          keys( %{$License_Local} )
    ),
);

my %Build_Menu = (
    E => 'ExtUtils::MakeMaker',
    B => 'Module::Build',
    P => 'Module::Build and proxy Makefile.PL',
);

my %destinations = (
    'Main Menu' => {
        A => 'Author Menu',
        L => 'License Menu',
        D => 'Directives_Menu',
        B => 'Build Menu',
        Q => 'done',
    },
    'Author Menu' => {
        R => 'Main Menu',
        Q => 'done',
    },
    Directives_Menu => {
        R => 'Main Menu',
        Q => 'done',
    },
    'License Menu' => {
        C => 'Copyright_Display',
        L => 'License_Display',
        R => 'Main Menu',
        Q => 'done',
        P => 'License Menu',
    },
    'Build Menu' => {
        R => 'Main Menu',
        Q => 'done',
    },
);

my %messages = (

    #---------------------------------------------------------------------

    'Main Menu' => <<EOF,
modulemaker: Main Menu

    Feature              Current Value
N - Name of module       '##name##'
S - Abstract             '##abstract##'
A - Author information
L - License              '##license##'
D - Directives
B - Build system         '##build##'
G - Generate module

Q - Quit program

Please choose which feature you would like to edit: 
EOF
    #---------------------------------------------------------------------

    'Author Menu' => <<EOF,
modulemaker: Author Menu

    Feature       Current Value
##Data Here##

R - Return to main menu

Please choose which feature you would like to edit:
EOF

    #---------------------------------------------------------------------

    Directives_Menu => <<EOF,
modulemaker: Directives Menu

    Feature           Current Value
##Data Here##

R - Return to main menu

Please choose which feature you would like to edit:
EOF

    #---------------------------------------------------------------------

    'License Menu' => <<EOF,
modulemaker: License Menu

ModuleMaker provides many licenes to choose from, many of them approved by opensource.org.

        License Name
##Licenses Here##

# - Enter the number of the license you want to use
C - Display the Copyright
L - Display the License
R - Return to main menu

Please choose which license you would like to use:
EOF

    #---------------------------------------------------------------------

    License_Display => <<EOF,
Here is the current license:

##License Here##

C - Display the Copyright
L - Display the License
P - Pick a different license
R - Return to main menu

Please choose which license you would like to use:
EOF

    #---------------------------------------------------------------------

    Copyright_Display => <<EOF,
Here is the current copyright:

##Copyright Here##

C - Display the Copyright
L - Display the License
P - Pick a different license
R - Return to main menu

Please choose which license you would like to use:
EOF

    #---------------------------------------------------------------------

    Build_Menu => <<EOF,
Here is the current build system:

##Build Here##

E - ExtUtils::MakeMaker
B - Module::Build
P - Module::Build and proxy Makefile.PL
R - Return to main menu

Please choose which build system you would like to use:
EOF

    #---------------------------------------------------------------------
);

########## END DECLARATIONS ##########

########## BEGIN SUBROUTINES  ##########

sub run_interactive {
    my $MOD = shift;
    my $where = 'Main Menu';
    while () {
        if ( $where eq 'done' ) {
            last;
        } elsif ( $where eq 'Module Name' ) {
        } elsif ( $where eq 'Abstract' ) {
        } elsif ( $where eq 'Main Menu' ) {
            $where = Main_Menu($MOD);
        } elsif ( $where eq 'License Menu' ) {
            $where = License_Menu($MOD);
        } elsif ( $where eq 'Author Menu' ) {
            $where = Author_Menu($MOD);
        } elsif ( $where eq 'License_Display' ) {
            $where = License_Display($MOD);
        } elsif ( $where eq 'Copyright_Display' ) {
            $where = Copyright_Display($MOD);
        } elsif ( $where eq 'Directives_Menu' ) {
            $where = Directives_Menu($MOD);
        } elsif ( $where eq 'Build Menu' ) {
            $where = Build_Menu($MOD);
        } else {
            $where = Main_Menu($MOD);
        }
    }
    return $MOD;
}

sub Main_Menu {
    my $MOD = shift;

    LOOP:  {
        my $string = $messages{'Main Menu'};
        defined $MOD->{NAME} 
            ? $string =~ s|##name##|$MOD->{NAME}|
            : $string =~ s|##name##||;
        $string =~ s|##abstract##|$MOD->{ABSTRACT}|;
        $string =~ s|##license##|$MOD->{LICENSE}|;
        $string =~ s|##build##|$MOD->{BUILD_SYSTEM}|;
    
        my $response = Question_User( $string, 'menu' );
    
        return ( $destinations{'Main Menu'}{$response} )
          if ( exists $destinations{'Main Menu'}{$response} );
    
        if ( $response eq 'N' ) {
            my $value =
              Question_User( "Please enter a new value for Primary Module Name",
                'data' );
            $MOD->{NAME} = $value;
        }
        elsif ( $response eq 'S' ) {
            my $value =
              Question_User( "Please enter a 44-character max Abstract for this extension",
                'data' );
            $MOD->{ABSTRACT} = $value;
        }
        # not documented or yet included in main menu
    #    elsif ( $response eq 'V' ) {
    #        $MOD->verify_values();
    #        print "Module verification done\n";
    #    }
        elsif ( $response eq 'G' ) {
            $MOD->set_author_data();
        # verify_values() returns an empty list if all values are
        # good; so if its return value is true, we need to repeat
        # the prompts; otherwise, we can proceed to complete_build()
            if (! $MOD->verify_values()) {
                print "Module files ready for generation.  Proceed to 'Q'.\n";
                return ('Main Menu');
            } else {
                next LOOP;
            }
        }
    } # END LOOP
    return ('Main Menu');
}

sub Author_Menu {
    my $MOD = shift;

    my $string = $messages{'Author Menu'};
    my $stuff  = join(
        "\n",
        map {
            "$_ - $Author_Menu{$_}[0]  '"
              . $MOD->{AUTHOR}{ $Author_Menu{$_}[1] } . "'"
          } qw (N C O W E)
    );
    $string =~ s|##Data Here##|$stuff|;

    my $response = Question_User( $string, 'menu' );
    return ( $destinations{'Author Menu'}{$response} )
      if ( exists $destinations{'Author Menu'}{$response} );
    return ('Author Menu') unless ( exists( $Author_Menu{$response} ) );

    my $value =
      Question_User( "Please enter a new value for $Author_Menu{$response}[0]",
        'data' );
    $MOD->{AUTHOR}{ $Author_Menu{$response}[1] } = $value;

    return ('Author Menu');
}

sub Directives_Menu {
    my $MOD = shift;

    my $string = $messages{Directives_Menu};
    my $stuff  = join(
        "\n",
        (
            map {
                "$_ - $Directives_Menu{$_}[0]  '"
                  . $MOD->{ $Directives_Menu{$_}[1] } . "'"
              } qw (C V D N H)
        ),
        "P - $Directives_Menu{P}[0]  '"
          . sprintf(
            "%04o - %d",
            $MOD->{ $Directives_Menu{P}[1] },
            $MOD->{ $Directives_Menu{P}[1] }
          )
          . "'",
    );
    $string =~ s|##Data Here##|$stuff|;

    my $response = Question_User( $string, 'menu' );
    return ( $destinations{Directives_Menu}{$response} )
      if ( exists $destinations{Directives_Menu}{$response} );
    return ('Directives_Menu') unless ( exists( $Directives_Menu{$response} ) );

    if ( $response eq 'P' ) {
        my $value =
          Question_User(
            "Please enter a new value for $Directives_Menu{$response}[0]",
            'data' );
        $value = oct($value) if ( $value =~ /^0/ );
        $MOD->{ $Directives_Menu{$response}[1] } = $value if ( $value <= 0777 );
    }
    else {
        my $value = Question_User(
            "Please enter a new value for $Directives_Menu{$response}[0]," . " (0,No,False  || 1,Yes,True)",
            'menu'
        );
        $value = $Flagged{$value};
        $MOD->{ $Directives_Menu{$response}[1] } = $Flagged{$value}
          if ( exists $Flagged{$value} );
    }

    return ('Directives_Menu');
}

sub License_Menu {
    my $MOD = shift;

    my $string   = $messages{'License Menu'};
    my $ct       = 1;
    my $licenses = join(
        "\n",
        map {
                $ct++ . ( ( $MOD->{LICENSE} eq $_->[0] ) ? '***' : '' ) . "\t"
              . $_->[1]
          } @lic
    );
    $string =~ s|##Licenses Here##|$licenses|;

    my $response = Question_User( $string, 'license', scalar(@lic) );
    return ( $destinations{'License Menu'}{$response} )
      if ( exists $destinations{'License Menu'}{$response} );

    if ( $lic[ $response - 1 ] ) {
        $MOD->{LICENSE} = $lic[ $response - 1 ][0];
    }
    $MOD->initialize_license();

    return ('License Menu');
}

sub License_Display {
    my $MOD = shift;

    my $string = $messages{License_Display};
    $string =~ s|##License Here##|$MOD->{LicenseParts}{LICENSETEXT}|;

    my $response = Question_User( $string, 'menu' );
    return ( $destinations{'License Menu'}{$response} )
      if ( exists $destinations{'License Menu'}{$response} );
    return ('License Menu');
}

sub Build_Menu {
    my $MOD = shift;

    my $string = $messages{Build_Menu};
    $string =~ s|##Build Here##|$MOD->{BUILD_SYSTEM}|;

    my $response = Question_User( $string, 'menu' );
    return ( $destinations{'Build Menu'}{$response} )
      if ( exists $destinations{'Build Menu'}{$response} );

    $MOD->{BUILD_SYSTEM} = $Build_Menu{$response}
      if exists $Build_Menu{$response};

    return ('Build Menu');
}

sub Copyright_Display {
    my $MOD = shift;

    my $string = $messages{Copyright_Display};
    $string =~ s|##Copyright Here##|$MOD->{LicenseParts}{COPYRIGHT}|;

    my $response = Question_User( $string, 'menu' );
    return ( $destinations{'License Menu'}{$response} )
      if ( exists $destinations{'License Menu'}{$response} );
    return ('License Menu');
}

sub Question_User {
    my ( $question, $flavor, $feature ) = @_;

    print "\n------------------------\n\n", $question, "\n";
    my $answer = <>;

    if ( $flavor eq 'menu' ) {
        $answer =~ m/^(.)/;
        $answer = uc($1);
    }
    elsif ( $flavor eq 'data' ) {
        chomp($answer);
    }
    elsif ( $flavor eq 'license' ) {
        chomp($answer);
        unless ( $answer =~ m/^\d+/ ) {
            $answer =~ m/^(.)/;
            $answer = uc($1);
        }
        elsif ( ( $answer < 1 ) || ( $feature < $answer ) ) {
            $answer = 'P';
        }
    }

    print "You entered '$answer'\n";
    return ($answer);
}

################### DOCUMENTATION ################### 

=head1 NAME

ExtUtils::ModuleMaker::Interactive - Hold subroutines used in
F<modulemaker>

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker::Interactive qw| run_interactive |;
    ...
    if ( $MOD->{INTERACTIVE} ) {
        $MOD = run_interactive($MOD);
	...

=head1 DESCRIPTION

This package exists solely to hold declarations of variables and
subroutines used in F<modulemaker>, the command-line utility which is
the easiest way of accessing the functionality of Perl extension
ExtUtils::ModuleMaker.

The package exports one subroutine on request:  C<run_interactive()>.
This is called once inside F<modulemaker>.  It takes an
ExtUtils::ModuleMaker as an object and returns that object.  It drives
the various screen prompts contained within F<modulemaker>.

=head1 AUTHOR

James E Keenan.  CPANID:  JKEENAN.

=head1 COPYRIGHT

Copyright (c) 2005 James E. Keenan.  All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<modulemaker>, F<ExtUtils::ModuleMaker>.

=cut

