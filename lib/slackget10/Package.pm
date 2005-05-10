package slackget10::Package;

use warnings;
use strict;

=head1 NAME

slackget10::Package - This class is the internal representation of a package for slack-get 1.0

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This module is used to represent a package for slack-get

    use slackget10::Package;

    my $package = slackget10::Package->new('package-1.0.0-noarch-1');
    $package->setValue('description',"This is a test of the slackget10::Package object");
    $package->fill_object_from_package_name();

=head1 CONSTRUCTOR

The constructor take two parameters : a package name, and an id (the namespace of the package like 'slackware' or 'linuxpackages')

	my $package = new slackget10::Package ('aaa_base-10.0.0-noarch-1','slackware');

The constructor automatically call the fill_object_from_package_name() method.

You also can pass some extra arguments like that :

	my $package = new slackget10::Package ('aaa_base-10.0.0-noarch-1', 'package-object-version' => '1.0.0');

The constructor return undef if the id is not defined.

=cut

sub new
{
	my ($class,$id,%args) = @_ ;
	return undef unless($id);
	my $self={%args};
	$self->{ROOT} = $id ;
	bless($self,$class);
	$self->fill_object_from_package_name();
	return $self;
}

=head1 FUNCTIONS

=head2 setValue

Set the value of a named key to the value passed in argument.

	$package->setValue($key,$value);

=cut

sub setValue {
	my ($self,$key,$value) = @_ ;
# 	print "Setting $key=$value for $self\n";
	$self->{PACK}->{$key} = $value ;
}

=head2 merge

This method merge $another_package with $package. WARNING: $another_package will be destroy in the operation (this is a collateral damage ;-), for some dark preocupation of memory.

This method overwrite existing value.

	$package->merge($another_package);

=cut

sub merge {
	my ($self,$package) = @_ ;
	foreach (keys(%{$package->{PACK}})){
		$self->{PACK}->{$_} = $package->{PACK}->{$_} ;
	}
	$package = undef;
}

=head2 getValue

Return the value of a key :

	$string = $package->getValue($key);

=cut

sub getValue {
	my ($self,$key) = @_ ;
	return $self->{PACK}->{$key};
}

=head2 _setId [PRIVATE]

set the package ID (normally the package complete name, like aaa_base-10.0.0-noarch-1). In normal use you don't need to use this method

	$package->_setId('aaa_base-10.0.0-noarch-1');

=cut

sub _setId{
	my ($self,$id)=@_;
	$self->{ROOT} = $id;
}

=head2 get_id

return the package id (full name, like aaa_base-10.0.0-noarch-1).

	$string = $package->get_id();

=cut

sub get_id {
	my $self= shift;
	return $self->{ROOT};
}

=head2 fill_object_from_package_name

Try to extract the maximum informations from the name of the package. The constructor automatically call this method.

	$package->fill_object_from_package_name();

=cut

sub fill_object_from_package_name{
	my $self = shift;
	if($self->{ROOT}=~ /^(.*)-([0-9].*)-(i[0-9]86|noarch)-(\d{1,2})(\.tgz)?$/)
	{
		$self->setValue('name',$1);
		$self->setValue('version',$2);
		$self->setValue('architecture',$3);
		$self->setValue('package-version',$4);
		$self->setValue('package-maintener','Slackware team') if(defined($self->{SOURCE}) && $self->{SOURCE}=~/^slackware$/i);
	}
	elsif($self->{ROOT}=~ /^(.*)-([0-9].*)-(i[0-9]86|noarch)-(\d{1,2})(\w*)(\.tgz)?$/)
	{
		$self->setValue('name',$1);
		$self->setValue('version',$2);
		$self->setValue('architecture',$3);
		$self->setValue('package-version',$4);
		$self->setValue('package-maintener',$5);
	}
	else
	{
		$self->setValue('name',$self->{ROOT});
	}
}

=head2 extract_informations

Extract informations about a package from a string. This string must be a line of the description of a package.

	$package->extract_informations($data);

This method is designe to be called by the slackget10::SpecialFiles::PACKAGES class, and automatically call the clean_description() method.

=cut

sub extract_informations {
	my $self = shift;
	foreach (@_){
# 		print "Analysing package " ;
		if($_ =~ /PACKAGE NAME:\s+(.*)\.tgz\s*\n/)
		{
			$self->_setId($1);
# 			print "[DEBUG] slackget10::Package -> rename package to $1\n";
			$self->fill_object_from_package_name();
			
		}
		if($_ =~ /(COMPRESSED PACKAGE SIZE|PACKAGE SIZE \(compressed\)):\s+(.*) K\n/)
		{
# 			print "size_c ";
			$self->setValue('compressed-size',$2);
		}
		if($_ =~ /(UNCOMPRESSED PACKAGE SIZE|PACKAGE SIZE \(uncompressed\)):\s+(.*) K\n/)
		{
# 			print "size_u ";
			$self->setValue('uncompressed-size',$2);
		}
		if($_ =~ /PACKAGE LOCATION:\s+(.*)\s*\n/)
		{
# 			print "location ";
			$self->setValue('location',$1);
		}
		if($_ =~ /PACKAGE REQUIRED:\s+(.*)\s*\n/)
		{
			$self->setValue('required',$1);
		}
		if($_ =~ /PACKAGE SUGGESTS:\s+(.*)\s*\n/)
		{
			$self->setValue('suggest',$1);
		}
		if($_=~/PACKAGE DESCRIPTION:\s*\n(.*)/ms)
		{
# 			print "descr ";
			$self->setValue('description',$1);
			$self->{PACK}->{description}=~ s/\n/\n\t\t/g;
			$self->clean_description ;
		}
	}
}

=head2 to_XML

return the package as an XML encoded string.

	$xml = $package->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	my $xml = "\t<package id=\"$self->{ROOT}\">\n";
	if($self->{PACK}->{'package-date'}){
		$xml .= "\t\t".$self->{PACK}->{'package-date'}->to_XML();
		$self->{TMP}->{'package-date'}=$self->{PACK}->{'package-date'};
		delete($self->{PACK}->{'package-date'});
	}
	foreach (keys(%{$self->{PACK}})){
		$xml .= "\t\t<$_>$self->{PACK}->{$_}</$_>\n" if(defined($self->{PACK}->{$_}));
	}
	$self->{PACK}->{'package-date'}=$self->{TMP}->{'package-date'};
	delete($self->{TMP});
	$xml .= "\t</package>\n";
	return $xml;
}

=head2 to_string

Alias for to_XML()

=cut

sub to_string{
	my $self = shift;
	$self->toXML();
}

=head2 description

return the description of the package.

	$string = $package->description();

=cut

sub description{
	my $self = shift;
	return $self->{PACK}->{description};
}

=head2 clean_description

remove the "<package_name>: " string in front of each line of the description. Change < to &lt; and > to &gt;. Finally remove extra tabulation (for identation).

	$package->clean_description();

=cut

sub clean_description{
	my $self = shift;
	if($self->{PACK}->{name})
	{
		$self->{PACK}->{description}=~ s/\Q$self->{PACK}->{name}:\E\s//ig;
		$self->{PACK}->{description}=~ s/\t{4,}/\t\t\t/g;
		$self->{PACK}->{description}=~ s/\n\s+\n//g;
		$self->{PACK}->{description}=~ s/</&lt;/g;
		$self->{PACK}->{description}=~ s/>/&gt;/g;
		$self->{PACK}->{description}=~ s/&/&amp;/g;
	}
	$self->{PACK}->{description}.="\n\t\t";
	return 1;
}

=head2 print_restricted_info

Print a part of package information.

	$package->print_restricted_info();

=cut

sub print_restricted_info {
	my $self = shift;
	print "Information on package ".$self->get_id." :\n".
	"\tshort name : ".$self->name()." \n".
	"\tArchitecture : ".$self->architecture()." \n".
	"\tDownload size : ".$self->compressed_size()." KB \n".
	"\tSource : ".$self->getValue('package-source')."\n".
	"\tPackage version : ".$self->version()." \n";
}

=head2 print_full_info

Print all informations found in the package.

	$package->print_full_info();

=cut

sub print_full_info {
	my $self = shift;
	print "Information on package ".$self->get_id." :\n";
	foreach (keys(%{$self->{PACK}})) {
		print "\t$_ : $self->{PACK}->{$_}\n";
	}
}

=head2 fprint_restricted_info

Same as print_restricted_info, but output in HTML

	$package->fprint_restricted_info();

=cut

sub fprint_restricted_info {
	my $self = shift;
	print "<u><li>Information on package ".$self->get_id." :</li></u><br/>\n".
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>short name : </strong> ".$self->name()." <br/>\n".
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Architecture : </strong> ".$self->architecture()." <br/>\n".
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Download size : </strong> ".$self->compressed_size()." KB <br/>\n".
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Source : </strong> ".$self->getValue('package-source')."<br/>\n".
	"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Package version : </strong> ".$self->version()." <br/>\n";
}

=head2 fprint_full_info

Same as print_full_info, but output in HTML

	$package->fprint_full_info();

=cut

sub fprint_full_info {
	my $self = shift;
	print "<u><li>Information on package ".$self->get_id." :</li></u><br/>\n";
	foreach (keys(%{$self->{PACK}})){
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>$_ : </strong> $self->{PACK}->{$_}<br/>\n";
	}
}

=head2 grab_info_from_description

Try to find some informations in the description. For example, packages from linuxpackages.net contain a line starting by Packager: ..., this method will extract this information and re-set the package-maintener tag.

The supported tags are: package-maintener, info-destination-slackware, info-packager-mail, info-homepage, info-packager-tool, info-packager-tool-version

	$package->grab_info_from_description();

=cut

sub grab_info_from_description{
	my $self = shift;
	if($self->{PACK}->{description}=~ /this\s+version\s+.*\s+was\s+comp(iled|lied)\s+for\s+([^\n]*)\s+(.|\n)*\s+by\s+(.*)/i){
		$self->setValue('info-destination-slackware',$2);
		$self->setValue('package-maintener',$4);
	}
	elsif($self->{PACK}->{description}=~ /Package\s+created\s+by:\s+(.*)\s+&lt;(.*)&gt;/i){
		$self->setValue('info-packager-mail',$2);
		$self->setValue('package-maintener',$1);
	}
	elsif($self->{PACK}->{description}=~ /Package\s+created\s+by\s+(.*)\s+\[(.*)\]/i){
		$self->setValue('info-homepage',$2);
		$self->setValue('package-maintener',$1);
	}
	elsif($self->{PACK}->{description}=~ /Package\s+created\s+.*by\s+(.*)\s+\((.*)\)/i){
		$self->setValue('package-maintener',$1);
		$self->setValue('info-packager-mail',$2);
	}
	elsif($self->{PACK}->{description}=~ /Package\s+Maintainer:\s+(.*)\s+\((.*)\)/i){
		$self->setValue('package-maintener',$1);
		$self->setValue('info-packager-mail',$2);
	}
	elsif($self->{PACK}->{description}=~ /Packaged\s+by\s+(.*)\s+&lt;(.*)&gt;/i){
		$self->setValue('package-maintener',$1);
		$self->setValue('info-packager-mail',$2);
	}
	elsif($self->{PACK}->{description}=~ /Packaged\s+by:?\s+(.*)(\s+(by|for|to|on))?/i){
		$self->setValue('package-maintener',$1);
	}
	elsif($self->{PACK}->{description}=~ /Package\s+created\s+by:?\s+(.*)/i){
		$self->setValue('package-maintener',$1);
	}
	elsif($self->{PACK}->{description}=~ /Packager:\s+(.*)\s+&lt;(.*)&gt;/i){
		$self->setValue('package-maintener',$1);
		$self->setValue('info-packager-mail',$2);
	}
	elsif($self->{PACK}->{description}=~ /Packager:\s+(.*)/i){
		$self->setValue('package-maintener',$1);
	}
	elsif($self->{PACK}->{description}=~ /Packager\s+(.*)/i){
		$self->setValue('package-maintener',$1);
	}
	if($self->{PACK}->{description}=~ /Homepage: (.*)/i){
		$self->setValue('info-homepage',$1);
	}
	elsif($self->{PACK}->{description}=~ /Package URL: (.*)/i){
		$self->setValue('info-homepage',$1);
	}
	
	if($self->{PACK}->{description}=~ /Package creat(ed|e) with ([^\s]*) ([^\s]*)/i){
		$self->setValue('info-packager-tool',$2);
		$self->setValue('info-packager-tool-version',$3);
	}
	
}

=head2 filelist

return the list of files in the package. WARNING: by default this list is not included !

	$string = $package->filelist();

=cut

sub filelist{
	my $self = shift;
	return $self->{PACK}->{'file-list'};
}

=head2 name

return the name of the package. 
Ex: for the package aaa_base-10.0.0-noarch-1 name() will return aaa_base

	my $string = $package->name();

=cut

sub name{
	my $self = shift;
	return $self->{PACK}->{name};
}

=head2 compressed_size

return the compressed size of the package

	$number = $package->compressed_size();

=cut

sub compressed_size{
	my $self = shift;
	return $self->{PACK}->{'compressed-size'};
}

=head2 uncompressed_size

return the uncompressed size of the package

	$number = $package->uncompressed_size();

=cut

sub uncompressed_size{
	my $self = shift;
	return $self->{PACK}->{'uncompressed-size'};
}

=head2 location

return the location of the installed package.

	$string = $package->location();

=cut

sub location{
	my $self = shift;
	return $self->{PACK}->{location};
}

=head2 conflicts

return the list of conflicting pakage.

	$string = $apckage->conflict();

=cut

sub conflicts{
	my $self = shift;
	return $self->{PACK}->{conflicts};
}

=head2 suggests

return the suggested package related to the current package.

	$string = $package->suggest();

=cut

sub suggests{
	my $self = shift;
	return $self->{PACK}->{suggests};
}

=head2 required

return the required packages for installing the current package

	$string = $package->required();

=cut

sub required{
	my $self = shift;
	return $self->{PACK}->{required};
}

=head2 architecture

return the architecture the package is compiled for.

	$string = $package->architecture();

=cut

sub architecture {
	my $self = shift;
	return $self->{PACK}->{architecture};
}

=head2 version

return the package version.

	$string = $package->version();

=cut

sub version {
	my $self = shift;
	return $self->{PACK}->{version};
}

# 
# =head2
# 
# return the 
# 
# =cut
# 
# sub {
# 	my $self = shift;
# 	return $self->{PACK}->{};
# }

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-Package@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Package