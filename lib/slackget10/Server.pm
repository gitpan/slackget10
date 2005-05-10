package slackget10::Server;

use warnings;
use strict;

=head1 NAME

slackget10::Server - A to represent a server from the servers.xml file.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is used by slack-get to represent a server store in the servers.xml file. In this class (and in the related ServerList), the word "server" is used to describe an update source, a server entity of the servers.xml file. This word is not use to describe a traditionnal TCP/IP server. A slackget10::Server object can contain many TCP/IP server, this allow it to switch when a FTP or HTTP host doesn't response.

    use slackget10::Server;

    my $server = slackget10::Server->new('slackware');
    my $xml = XML::Simple::XMLin($servers_file,,KeyAttr => {'server' => 'id'});
    $server->fill_object_from_xml($xml->{'slackware'});
    $server->setValue('description','The official Slackware web site');

This class' usage is mostly the same that the slackget10::Package one. There is one big difference with the package class : you must use the accessors for setting the fast and slow servers list.

=CONSTRUCTOR

The constructor require the following argument :

	- an id (stricly needed)

Additionnaly you can pass the followings :

	description => a string which describe the mirror
	web-link => a web site URL for the mirror.
	update-repository => A hash reference build on the model of the servers.xml file. For example for the faster mirror (the one you want you use for this Server object) :
	
	my $server = slackget10::Server->new('slackware','update-repository' => {faster => http://ftp.belnet.be/packages/slackware/slackware-10.1/}); 

Some examples:

	# the simpliest and recommended way
	my $server = slackget10::Server->new('slackware'); 
	$server->fill_object_from_xml($xml_simple_hashref);
	
	or 
	
	# The harder and realy not recommended unless you know what you are doing.
	
	my $server = slackget10::Server->new('slackware',
		'description'=>'The official Slackware web site',
		'web-link' => 'http://www.slackware.com/',
		'update-repository' => {faster => 'http://ftp.belnet.be/packages/slackware/slackware-10.1/'}
	); 
=cut

sub new
{
	my ($class,$id,%args) = @_ ;
	return undef unless(defined($id));
	my $self={};
	$self->{ID} = $id ;
	$self->{DATA} = {%args};
	$self->{DATA}->{hosts}->{old} = [] ;
	bless($self,$class);
	
	return $self;
}

=head1 CONSTRUCTOR


=head1 FUNCTIONS

=head2 setValue

Set the value of a named key to the value passed in argument.

	$package->setValue($key,$value);

=cut

sub setValue {
	my ($self,$key,$value) = @_ ;
# 	print "Setting $key=$value for $self\n";
	$self->{DATA}->{$key} = $value ;
}

=head2 getValue

Return the value of a key :

	$string = $server->getValue($key);

=cut

sub getValue {
	my ($self,$key) = @_ ;
	return $self->{DATA}->{$key};
}

=head2 fill_object_from_xml

Fill the data section of the slackget10::Server object with information from a servers.xml section.

	$server->fill_object_from_xml($xml->{'slackware'});

=cut

sub fill_object_from_xml {
	my ($self,$xml) = @_ ;
# 	require Data::Dumper ;
# 	print Data::Dumper::Dumper($xml);
	$self->setValue('description',$xml->{'description'}) if(defined($xml->{'description'}));
	$self->setValue('web-link',$xml->{'web-link'}) if(defined($xml->{'web-link'}));
	if(defined($xml->{'update-repository'}))
	{
		if(defined($xml->{'update-repository'}->{faster})){
			require slackget10::Network::Connection;
			unless(slackget10::Network::Connection::is_url(undef,$xml->{'update-repository'}->{faster})){
				warn "[slackget10::Server] the faster host of the update-repository section will not be accept as a valid URL by slackget10::Connection class !\n";
			}
			$self->setValue('host',$xml->{'update-repository'}->{faster});
		}
		if(defined($xml->{'update-repository'}->{fast}) && defined($xml->{'update-repository'}->{fast}->{li}) && ref($xml->{'update-repository'}->{fast}->{li}) eq 'ARRAY')
		{
			$self->_fill_fast_host_section($xml->{'update-repository'}->{fast});
		}
		else
		{
			$self->{DATA}->{hosts}->{fast} = [] ;
		}
		if(defined($xml->{'update-repository'}->{slow}) && defined($xml->{'update-repository'}->{slow}->{li}) && ref($xml->{'update-repository'}->{slow}->{li}) eq 'ARRAY')
		{
			$self->_fill_slow_host_section($xml->{'update-repository'}->{slow});
		}
		else
		{
			$self->{DATA}->{hosts}->{slow} = [] ;
		}
	}
	else
	{
		warn "[slackget10::Server] no update-repository found for the update source '$self->{ID}'\n";
		return undef;
	}
	return 1;
}

=head2 _fill_fast_host_section [PRIVATE]

fill the DATA section of the object (sub-section fast host), with a part of the XML tree of a servers.xml file.

In normal use you don't have to use this method. In all case prefer pass all required argument to the constructor, and call the fill_object_from_xml() method.

	$self->_fill_fast_host_section($xml->{'update-repository'}->{fast});

=cut

sub _fill_fast_host_section 
{
	my ($self,$xml) = @_ ;
	if(defined($xml->{li}) && ref($xml->{li}) eq 'ARRAY')
	{
		$self->{DATA}->{hosts}->{fast} = $xml->{li} ;
	}
	else
	{
		$self->{DATA}->{hosts}->{fast} = [] ;
	}
}

=head2 _fill_slow_host_section [PRIVATE]

fill the DATA section of the object (sub-section slow host), with a part of the XML tree of a servers.xml file.

In normal use you don't have to use this method. In all case prefer pass all required argument to the constructor, and call the fill_object_from_xml() method.

	$self->_fill_slow_host_section($xml->{'update-repository'}->{slow});

=cut

sub _fill_slow_host_section 
{
	my ($self,$xml) = @_ ;
	if(defined($xml->{li}) && ref($xml->{li}) eq 'ARRAY')
	{
		$self->{DATA}->{hosts}->{slow} = $xml->{li} ;
	}
	else
	{
		$self->{DATA}->{hosts}->{slow} = [] ;
	}
}

=head2 next_host

This method have 3 functionnalities : return the next fastest host, set it as the current host, and add the old host to the old hosts list.

	my $host = $server->next_host ;

return undef if no new host is found
=cut

sub next_host
{
	my $self = shift;
	push @{$self->{DATA}->{hosts}->{old}}, $self->host;
	$self->{DATA}->{host} = undef ;
	if(defined(my $host = shift(@{$self->{DATA}->{hosts}->{fast}})))
	{
		$self->{DATA}->{host} = $host ;
	}
	else
	{
		warn "[slackget10::Server] no more host in the 'fast' category for update source '$self->{ID}'\n";
		if(defined(my $host = shift(@{$self->{DATA}->{hosts}->{slow}})))
		{
			$self->{DATA}->{host} = $host ;
		}
		else
		{
			warn "[slackget10::Server] no more host in the 'slow' category for update source '$self->{ID}'\n";
			return undef;
		}
	}
	return $self->host ;
}

=head2 print_info

This method is used to print the content of the current Server object.

	$server->print_info ;

=cut

sub print_info 
{
	my $self = shift ;
	print "Information for the '$self->{ID}' update source :\n";
	if(defined($self->getValue('description')))
	{
		print "\tDescription: ".$self->getValue('description')."\n";
	}
	else
	{
		print "\tDescription: no descrition found\n";
	}
	if(defined($self->getValue('web-link')))
	{
		print "\tWeb site: ".$self->getValue('web-link')."\n";
	}
	else
	{
		print "\tWeb site: no link found\n";
	}
	if(defined($self->getValue('host')))
	{
		print "\tCurrent host: ".$self->getValue('host')."\n";
	}
	else
	{
		print "\tCurrent host: no current host configured !\n";
	}
}

=head2 to_string

return the same information that the print_info() method as a string.

	my $string = $server->to_string ;

=cut

sub to_string 
{
	my $self = shift ;
	my $str = "Information for the '$self->{ID}' update source :\n";
	if(defined($self->getValue('description'))){
		$str .= "\tDescription: ".$self->getValue('description')."\n";
	}
	else
	{
		$str .= "\tDescription: no descrition found\n";
	}
	if(defined($self->getValue('web-link'))){
		$str .= "\tWeb site: ".$self->getValue('web-link')."\n";
	}
	else
	{
		$str .= "\tWeb site: no link found\n";
	}
	if(defined($self->getValue('host'))){
		$str .= "\tCurrent host: ".$self->getValue('host')."\n";
	}
	else
	{
		$str .= "\tCurrent host: no current host configured !\n";
	}
	return $str ;
}

=head1 ACCESSORS

Some accessors for the current object/

=cut

=head2 host

return the current host :

	my $host = $server->host

=cut

sub host {
	return $_[0]->{DATA}->{host};
}

=head2 description

return the description of the server.

	my $descr = $server->description ;

=cut

sub description {
	return $_[0]->{DATA}->{description};
}

=head2 url

return the URL of the website for the server.

	system("$config->{common}->{'default-browser'} $server->url &");

=cut

sub url {
	return $_[0]->{DATA}->{'web-link'};
}

=head2 shortname

Return the shortname of the server. The shortname is the name of the id attribute of the server tag in servers.xml => <server id="the_shortname">

	my $id = $server->shortname ;

=cut

sub shortname {
	return $_[0]->{ID};
}

=head2 set_fast_servers_array

...not yet implemented...

=cut

=head1 FORMATTED OUTPUT

Different methods to properly output a server.

=head2 to_XML

return the server info as an XML encoded string.

	$xml = $server->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	return undef unless(defined($self->{ID}));
	my $xml = "\t<server id=\"$self->{ID}\">\n";
	$xml .= "\t\t<web-link>".$self->url."</web-link>\n";
	$xml .= "\t\t<description>".$self->description."</description>\n";
	$xml .= "\t\t<update-repository>\n";
	$xml .= "\t\t\t<faster>".$self->host."</faster>\n";
	if(defined($self->{DATA}->{hosts}->{fast}) && defined($self->{DATA}->{hosts}->{fast}->[0]))
	{
		$xml .= "\t\t\t\t<fast>\n";
		foreach my $serv (@{$self->{DATA}->{hosts}->{fast}})
		{
			$xml .= "\t\t\t\t\t<li>$serv</li>\n";
		}
		$xml .= "\t\t\t\t</fast>\n";
	}
	if(defined($self->{DATA}->{hosts}->{slow}) && defined($self->{DATA}->{hosts}->{slow}->[0]))
	{
		$xml .= "\t\t\t\t<slow>\n";
		foreach my $serv (@{$self->{DATA}->{hosts}->{slow}})
		{
			$xml .= "\t\t\t\t\t<li>$serv</li>\n";
		}
		$xml .= "\t\t\t\t</slow>\n";
	}
	$xml .= "\t\t</update-repository>\n";
# 	foreach my $key (keys(%{$self->{DATA}})){
# 		if($key eq 'update-repository')
# 		{
# 			foreach my $key2 (keys(%{$self->{DATA}->{'update-repository'}}))
# 			{
# 				if($key2 eq 'fast' or $key2 eq 'slow' && ref($self->{DATA}->{'update-repository'}->{$key2}) eq 'HASH' && defined($self->{DATA}->{'update-repository'}->{$key2}->{li}) && ref($self->{DATA}->{'update-repository'}->{$key2}->{li}) eq 'ARRAY' ) {
# 					$xml .= "\t\t<$key2>\n";
# 					foreach (@{$self->{DATA}->{'update-repository'}->{$key2}->{li}}){
# 						$xml .= "\t\t\t<li>$_</li>\n";
# 					}
# 					$xml .= "\t\t</$key2>\n";
# 				}
# 			}
# 		}
# 		else
# 		{
# 			$xml .= "\t\t<$key>$self->{DATA}->{$key}</$key>\n";
# 		}
# 	}
	$xml .= "\t</server>\n";
	return $xml;
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

1; # End of slackget10::Server
