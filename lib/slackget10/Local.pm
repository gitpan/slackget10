package slackget10::Local;

use warnings;
use strict;

require slackget10::File ;

=head1 NAME

slackget10::Local - A class to load the locales

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class' purpose is to load and export the local.

    use slackget10::Local;

    my $local = slackget10::Local->new();
    $local->Load('/usr/local/share/slack-get/local/francais/LC_MESSAGES');
    print $local->Get('__SETTINGS') ;

=cut

sub new
{
	my ($class,$file) = @_ ;
	my $self={};
	bless($self,$class);
	if(defined($file) && -e $file)
	{
		$self->Load($file);
	}
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Can take an argument : the LC_MESSAGES file. In this case the constructor automatically call the Load() method.

	my $local = new slackget10::Local();
	or
	my $local = new slackget10::Local('/usr/local/share/slack-get/local/francais/LC_MESSAGES');

=head1 FUNCTIONS

=head2 Load

Load the local from a given file

	$local->Load('/usr/local/share/slack-get/local/francais/LC_MESSAGES') or die "unable to load local\n";

Return undef if something goes wrong, 1 else.

=cut

sub Load {
	my ($self,$file) = @_ ;
	return undef unless(defined($file) && -e $file);
	my $local = new slackget10::File ( $file ) ;
	foreach ($local->Get_file()){
		chomp;
		next if($_=~ /^\s*#/ or $_=~ /^\s*$/);
		if($_=~ /^([^=\s]*)\s*=\s*(.*)/)
		{
# 			print "Setting token '$1' with message '$2'\n";
			$self->{DATA}->{$1} = $2;
		}
	}
	return 1;
}

=head2 Get

Return the localized message of a given token :

	my $error_on_modification = $local->Get('__ERR_MOD') ;

Return undef if the token doesn't exist.

=cut

sub Get {
	my ($self,$token) = @_ ;
# 	return undef unless(defined($token));
	return $self->{DATA}->{$token};
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

1; # End of slackget10::Local
