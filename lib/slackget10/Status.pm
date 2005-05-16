package slackget10::Status;

use warnings;
use strict;

=head1 NAME

slackget10::Status - A wrapper for network operation in slack-get

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is used at a status object which can tell more informations to user. In this object are stored couples of integer (the return code of the function which return the status object), and string (the human readable description of the error)

    use slackget10::Status;

    my $status = slackget10::Status->new(
    	codes => {
		0 => "All operations goes well",
		1 => "Parameters unexpected",
		2 => "Network error"
	}
    );
    print "last error message was: ",$status->to_string,"\n";
    if($status->to_int == 2)
    {
    	die "A network error occured\n";
    }

Please note that you must see at the documentation of a class to know the returned codes.

=cut

sub new
{
	my ($class,%arg) = @_ ;
	my $self={ CURRENT_CODE => undef };
	return undef if(!defined($arg{'codes'}) && ref($arg{codes}) ne 'HASH');
	$self->{CODES} = $arg{'codes'} ;
	bless($self,$class);
	return $self;
}

=head1 CONSTRUCTOR

You need to pass to the constructor a parameter 'codes' wich contain a hashref with number return code as keys and explanation strings as values :

	my $status = new slackget10::Status (
		codes => {
			0 => "All good\n",
			1 => "Network unreachable\n",
			2 => "Host unreachable\n",
			3 => "Remote file seems not exist\n"
		}
	);

=head1 FUNCTIONS

=head2 to_string

Return the explanation string of the current status.

	if($connection->fetch_file($remote_file,$local_file) > 0)
	{
		print "ERROR : ",$status->to_string ;
		return undef;
	}
	else
	{
		...
	}

=cut

sub to_string {
	my $self = shift;
	return $self->{CODES}->{$self->{CURRENT_CODE}} ;
}

=head2 to_int

Same as to_string but return the code number.

=cut

sub to_int {
	my $self = shift;
	return $self->{CURRENT_CODE} ;
}

=head2 to_XML

return an xml ecoded string, represented the current status. The XML string will be like that :

	<status code="0" description="All goes well" />

	$xml_file->Add($status->to_XML) ;

=cut

sub to_XML
{
	my $self = shift ;
	return "<status code=\"".$self->to_int()."\" description=\"".$self->to_string()."\" />";
}

=head2 current

Called wihtout argument, just call to_int(), call with an integer argument, set the current status code to this int.

	my $code = $status->current ; # same effect as my $code = $status->to_int ;
	or
	$status->current(12);
	
Warning : call current() with a non-integer argument will fail ! The error code MUST BE AN INTEGER.

=cut

sub current
{
	my ($self,$code) = @_;
	if(!defined($code))
	{
		return $self->to_int ;
	}
	else
	{
		if($code=~ /^\d+$/)
		{
			$self->{CURRENT_CODE} = $code;
			return 1;
		}
		else
		{
			warn "[slackget10::Status] '$code' is not an integer.\n";
			return undef;
		}
	}
}

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-networking@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Status
