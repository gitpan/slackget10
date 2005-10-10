package slackget10::Local;

use warnings;
use strict;

require slackget10::File ;
require XML::Simple;
$XML::Simple::PREFERRED_PARSER='XML::Parser' ;

=head1 NAME

slackget10::Local - A class to load the locales

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '0.6.1';

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
	print "[slackget10::Local] loading file \"$file\"\n";
	my $data = XML::Simple::XMLin( $file , KeyAttr=> {'message' => 'id'}) ;
	$self->{DATA} = $data->{'message'} ;
	$self->{LP_NAME} = $data->{name} ;
	return 1;
}

=head2 get_indexes

Return the list of all index of the current loaded local. Dependending of the context, this method return an array or an arrayref.

	# Return a list
	foreach ($local->get_indexes) {
		print "$_ : ",$local->Get($_),"\n";
	}
	
	# Return an arrayref
	my $index_list = $local->get_indexes ;

=cut

sub get_indexes
{
	my $self = shift;
	my @a = keys( %{$self->{DATA} });
	return wantarray ? @a : \@a;
}

=head2 Get

Return the localized message of a given token :

	my $error_on_modification = $local->Get('__ERR_MOD') ;

Return undef if the token doesn't exist.

=cut

sub Get {
	my ($self,$token) = @_ ;
# 	return undef unless(defined($token));
	return $self->{DATA}->{$token}->{'content'};
}

sub to_XML
{
	my $self = shift;
	my @msg = sort {$a cmp $b} keys(%{ $self->{DATA} });
	my $xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\n<local name=\"$self->{LP_NAME}\">\n";
	foreach my $token (@msg)
	{
		unless(defined( $self->{DATA}->{$token}->{content} ))
		{
			print "token \"$token\" have no associate value.\n";
			next;
		}
		
		$xml .= "\t<message id=\"$token\"><![CDATA[$self->{DATA}->{$token}->{content}]]></message>\n";
	}
	$xml .= "</local>";
}

=head2 name

Accessor for the name pf the Local (langpack).

	print "The current langpack name is : ", $local->name,"\n";
	$local->name('Japanese'); # Set the name of the langpack to 'Japanese'.

=cut

sub name
{
	my $self = shift;
	my $name = shift;
	return $name ? ($self->{LP_NAME}=$name) : $self->{LP_NAME};
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
