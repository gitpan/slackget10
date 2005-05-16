package slackget10::Base;

use warnings;
use strict;

require XML::Simple ;
require slackget10::PackageList;
require slackget10::Package;
require slackget10::File;
require slackget10::Server;
require slackget10::ServerList ;
require slackget10::Date ;


=head1 NAME

slackget10::Base - A module which centralize some base methods usefull to slack-get

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This module centralize bases tasks like package directory compilation, etc. This class is mainly designed to be a wrapper so it can change a lot before the release.

    use slackget10::Base;

    my $base = slackget10::Base->new();
    my $packagelist = $base->compil_package_directory('/var/log/packages/');
    $packagelist = $base->load_list_from_xml_file('installed.xml');

=cut

sub new
{
	my ($class,$config) = @_ ;
	return undef if(!defined($config) && $config ne 'slackget10::Config') ;
	my $self = {CONF => $config};
	bless($self,$class);
	return $self;
}

=head1 CONSTRUCTOR

=head1 FUNCTIONS

=cut

sub ls
{
	my $self = shift;
	my $dir = shift;
	if (! opendir( DIR, $dir) )
	{
		warn "unable to open $dir : $!.";
		return undef;
	}
	my @files = grep !/(?:^\.$)|(?:^\.\$)|(?:^\.\.)/, readdir DIR;
	closedir DIR;
	for(my $k=0; $k<=$#files;$k++)
	{
		if($files[$k] !~ /^(\.\.|\.)$/)
		{
			$files[$k] = $dir.'/'.$files[$k] ;
		}
	}
	return @files;
}
sub dir2files
{
	my $self = shift;
	my @files = @_ ;
	my @f_files = ();
	
	foreach my $a (@files)
	{
		unless(-d $a)
		{
			push @f_files,$a;
		}
		else
		{
			unless(-l $a)
			{
				my @temp = $self->ls($a) ;
				@f_files = (@f_files,$self->dir2files(@temp));
			}
		}
	}
	return @f_files;
}

=head2 compil_packages_directory

take a directory where are store installed packages files and return a slackget10::PackageList object

	my $packagelist = $base->compil_package_directory('/var/log/packages/');

=cut

sub compil_packages_directory
{
	my ($self,$dir) = @_;
	my @files = $self->dir2files($dir);
	my $ref;
	my $packagelist = new slackget10::PackageList ;
	foreach (@files)
	{
# 		print "[DEBUG] in slackget10::Base, method compil_package_directory file-encoding=$self->{CONF}->{common}->{'file-encoding'}\n";
		my $sg_file = new slackget10::File ($_,'file-encoding' => $self->{CONF}->{common}->{'file-encoding'}) ;
		die $! unless $sg_file;
		my @file = $sg_file->Get_file();
		$_ =~ /^.*\/([^\/]*)$/;
		$ref->{$1}= new slackget10::Package ($1);
		my $pack = $ref->{$1};
		for(my $k=0;$k<=$#file;$k++)
		{
			if($file[$k] =~ /^PACKAGE NAME:\s+(.*)$/)
			{
				my $name = $1;
				unless(defined($pack->getValue('name')) or defined($pack->getValue('version')) or defined($pack->getValue('architecture')) or defined($pack->getValue('package-version')))
				{
					print "[DEBUG] Package forced to be renamed.\n";
					$pack->_setId($name);
					$pack->fill_object_from_package_name();
				}
				
			}
			elsif($file[$k] =~ /^COMPRESSED PACKAGE SIZE:\s+(.*) K$/)
			{
				$pack->setValue('compressed-size',$1);
			}
			elsif($file[$k] =~ /^UNCOMPRESSED PACKAGE SIZE:\s+(.*) K$/)
			{
				$pack->setValue('uncompressed-size',$1);
			}
			elsif($file[$k] =~ /^PACKAGE LOCATION:\s+(.*) K$/)
			{
				$pack->setValue('location',$1);
			}
			elsif($file[$k]=~/PACKAGE DESCRIPTION:/)
			{
				my $tmp = "";
				$k++;
				while($file[$k]!~/FILE LIST:/)
				{
					$tmp .= "\t\t\t$file[$k]";
					$k++;
				}
				$pack->setValue('description',"$tmp\n\t\t");
				### NOTE: On my system, with 586 packages installed the difference between with or without including the file list is very important
				### NOTE: with the file list the installed.xml file size is near 11 MB
				### NOTE: without the file list, the size is only 400 KB !!
				### NOTE: So I have decided that the file list is not include by default
				if(defined($self->{'include-file-list'}))
				{
					$pack->setValue('file-list',join("\t\t\t",@file[($k+1)..$#file])."\n\t\t");
				}
				last;
				
				
				
			}
		}
		$pack->clean_description();
		$pack->grab_info_from_description();
		$packagelist->add($pack);
		$sg_file->Close();
		
	}
	return $packagelist;
}


=head2 load_installed_list_from_xml_file

Load the data for filling the list from an XML file. Return a slackget10::PackageList. This method is design for reading a installed.xml file.

	$packagelist = $base->load_installed_list_from_xml_file('installed.xml');

=cut

sub load_installed_list_from_xml_file {
	my ($self,$file) = @_;
	my $package_list = new slackget10::PackageList ;
	my $xml_in = XML::Simple::XMLin($file,KeyAttr => {'package' => 'id'});
	foreach my $pack_name (keys(%{$xml_in->{'package'}})){
		my $package = new slackget10::Package ($pack_name);
		foreach my $key (keys(%{$xml_in->{'package'}->{$pack_name}})){
			$package->setValue($key,$xml_in->{'package'}->{$pack_name}->{$key}) ;
		}
		$package_list->add($package);
	}
	return $package_list;
}


=head2 load_packages_list_from_xml_file

Load the data for filling the list from an XML file. Return a hashref built on this model :

	my $hashref = {
		'key' => slackget10::PackageList,
		...
	};

Ex:

	my $hashref = {
		'slackware' => blessed(slackget10::PackageList),
		'slacky' => blessed(slackget10::PackageList),
		'audioslack' => blessed(slackget10::PackageList),
		'linuxpackages' => blessed(slackget10::PackageList),
	};

This method is design for reading a packages.xml file.

	$hashref = $base->load_packages_list_from_xml_file('packages.xml');

=cut

sub load_packages_list_from_xml_file {
	my ($self,$file) = @_;
	my $ref = {};
	
	my $xml_in = XML::Simple::XMLin($file,KeyAttr => {'package' => 'id'});
	foreach my $group (keys(%{$xml_in})){
		my $package_list = new slackget10::PackageList ;
		foreach my $pack_name (keys(%{$xml_in->{$group}->{'package'}})){
			#TODO: finir..quoi j'en sais rien...Par contre je sais pas si c'est une bonne idée de séparer les PackageList.
			my $package = new slackget10::Package ($pack_name);
			foreach my $key (keys(%{$xml_in->{$group}->{'package'}->{$pack_name}})){
				if($key eq 'date')
				{
					$package->setValue($key,slackget10::Date->new(%{$xml_in->{$group}->{'package'}->{$pack_name}->{$key}}));
				}
				else
				{
					$package->setValue($key,$xml_in->{$group}->{'package'}->{$pack_name}->{$key}) ;
				}
				
			}
			$package_list->add($package);
		}
		$ref->{$group} = $package_list;
	}
	return $ref;
}


=head2 load_server_list_from_xml_file

Load a server list from a servers.xml file.

	$serverlist = $base->load_server_list_from_xml_file('servers.xml');

=cut

sub load_server_list_from_xml_file {
	my ($self,$file) = @_;
	my $server_list = new slackget10::ServerList ;
	my $xml_in = XML::Simple::XMLin($file,KeyAttr => {'server' => 'id'});
	foreach my $server_name (keys(%{$xml_in->{'server'}})){
		my $server = new slackget10::Server ($server_name);
		$server->fill_object_from_xml( $xml_in->{server}->{$server_name} );
# 		$server->print_info ;print "\n\n";
		$server_list->add($server);
	}
	return $server_list;
}


=head2 set_include_file_list

By default the file list is not include in the installed.xml for some size consideration (on my system including the file list into installed.xml make him grow 28 times ! It passed from 400 KB to 11 MB),

So you can use this method to include the file list into installed.xml. BE carefull, to ue it BEFORE compil_packages_directory() !

	$base->set_include_file_list();
	$packagelist = $base->compil_packages_directory();

=cut

sub set_include_file_list{
	my $self = shift;
	$self->{'include-file-list'} = 1;
}


=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-base@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::Base
