package PSPP;

use warnings;
use strict;
use IPC::Run qw( run timeout );
use Text::CSV_XS;
use File::Temp;
use Carp;

=head1 NAME

PSPP - Perl library for interacting with PSPP

=head2 DESCRIPTION

PSPP is a program for statistical analysis of sampled data. 
It is a Free replacement for the proprietary program SPSS, and appears very similar to it with a few exceptions.
PSPP is particularly aimed at statisticians, social scientists and students requiring fast convenient analysis of sampled data.

For more information, see L<http://www.gnu.org/software/pspp/>

L<http://www.columbia.edu/acis/eds/stat_pak/spss/spss-write.html>
L<http://www.ats.ucla.edu/stat/Spss/modules/input.htm>

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head2 new

Constructor.

=cut

sub new {
    my $invocant = shift;
    my $class = ref $invocant || $invocant;
    bless {
        pspp_binary => 'pspp',
        timeout     => 10,
        verbose     => 0,
        @_,
    }, $class;
}

sub variables {
    my $self = shift;
    my $variables = shift;
    if ($variables) {
        $self->{variables} = $variables;
    }
    return $self->{variables};
}

sub rows {
    my $self = shift;
    my $rows = shift;
    if ($rows) {
        $self->{rows} = $rows;
    }
    return $self->{rows};
}

sub save {
    my $self      = shift;
    my %opts      = @_;
    my $outfile   = $opts{outfile} || 'out.sav';
    my $variables = $self->{variables} or croak "You must set the variables property before attempting to save data";
    my $rows      = $self->{rows} or croak "You must set the rows property before attempting to save data";
    
    print "Variables:\n$variables\n\n" if $self->verbose;

    # Use CSV_XS to write data to tmp file
    my $csv = Text::CSV_XS->new( { binary => 1 } );
    my $fh = File::Temp->new( SUFFIX => '.csv' );
    for my $row (@$rows) {
        $csv->print( $fh, $row );
        print $fh "\n";
    }
    $fh->close;

    # Generate PSPP program
    my $syntax = <<END_SYNTAX;
DATA LIST LIST FILE="$fh"
 / $variables .
LIST.
SAVE OUTFILE="$outfile".
END_SYNTAX

    print "Syntax:\n$syntax\n\n" if $self->verbose;

    # Use IPC::Run to call PSPP binary
    my $pspp_binary = $self->{pspp_binary};
    run [$pspp_binary], \$syntax, \(my $out), \(my $err), timeout( $self->{timeout} ) or croak "$pspp_binary: $?";
    carp $err if $err;
    print "Output:\n$out\n" if $self->verbose;
    undef $fh;
    return -e $outfile;
}

sub verbose { return $_[0]->{verbose} }

########## TEST #################
my $pspp = PSPP->new( verbose => 0 );
$pspp->variables('make (A15) mpg weight price');
$pspp->rows([
            [ "AMC Concord",   22, 2930, 4099 ],
            [ "AMC Pacer",     17, 3350, 4749 ],
            [ "AMC Spirit",    22, 2640, 3799 ],
            [ "Buick Century", 20, 3250, 4816 ],
            [ "Buick Electra", 15, 4080, 7827 ],
        ]);
my $outfile = '/home/patspam/Desktop/out.sav';
unlink $outfile;
$pspp->save(outfile => $outfile) or warn "An error occurred";
print "Finished\n";

=head1 AUTHOR

Patrick Donelan, C<< <pat at patspam.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pspp at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PSPP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PSPP


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PSPP>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PSPP>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PSPP>

=item * Search CPAN

L<http://search.cpan.org/dist/PSPP/>

=back


=head1 ACKNOWLEDGEMENTS

L<http://www.gnu.org/software/pspp/>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Patrick Donelan, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    # End of PSPP
