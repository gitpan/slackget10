package slackget10::Base;

use warnings;
use strict;

require XML::Simple ;
require slackget10::PackageList;
require slackget10::Package;
require slackget10::File;


=head1 NAME

slackget10::Base - The great new slackget10::Base!

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use slackget10::Base;

    my $foo = slackget10::Base->new();
    ...

=cut

sub new
{
	my ($class,$arg) = @_ ;
	my $self;
	if($arg)
	{
		$self = $arg ;
	}
	else
	{
		$self = {};
	}
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
		print "Impossible d'ouvrir le répertoire $dir : $!.";
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
		my $sg_file = new slackget10::File ($_) ;
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
				### FIXME: On my system, with 586 packages installed the difference between with or without including the file list is very important
				### FIXME: with the file list the installed.xml file size is near 11 MB
				### FIXME: without the file list, the size is only 400 KB !!
				### FIXME: So I have decided that the file list is not include by default
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


=head2 load_list_from_xml_file

Load the data for filling the list from an XML file. Return a slackget10::PackageList

	$packagelist = $base->load_list_from_xml_file('installed.xml');

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
