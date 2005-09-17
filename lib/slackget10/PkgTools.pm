package slackget10::PkgTools;

use warnings;
use strict;

require slackget10::Status ;
use File::Copy ;

=head1 NAME

slackget10::PkgTools - A wrapper for the pkgtools action(installpkg, upgradepkg and removepkg)

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is anoter wrapper for slack-get. It will encapsulate the pkgtools system call.

    use slackget10::PkgTools;

    my $pkgtool = slackget10::PkgTools->new($config);
    $pkgtool->install($package1);
    $pkgtool->remove($package_list);
    foreach (@{$packagelist->get_all})
    {
    	print "Status for ",$_->name," : ",$_->status()->to_string,"\n";
    }
    $pkgtool->upgrade($package_list);

=cut

sub new
{
	my ($class,$config) = @_ ;
	return undef if(!defined($config) && ref($config) ne 'slackget10::Config') ;
	my $self={};
	$self->{CONF} = $config ;
	$self->{STATUS} = {
		0 => "Package have been installed successfully.\n",
		1 => "Package have been upgraded successfully.\n",
		2 => "Package have been removed successfully.\n",
		3 => "Can't install package : new package not found in the cache.\n",
		4 => "Can't remove package : no such package installed.\n",
		5 => "Can't upgrade package : new package not found in the cache.\n",
		6 => "Can't install package : an error occured during $self->{CONF}->{common}->{pkgtools}->{'installpkg-binary'} system call\n",
		7 => "Can't remove package : an error occured during $self->{CONF}->{common}->{pkgtools}->{'removepkg-binary'} system call\n",
		8 => "Can't upgrade package : an error occured during $self->{CONF}->{common}->{pkgtools}->{'upgradepkg-binary'} system call\n",
		9 => "Package scheduled for install on next reboot.\n",
		10 => "An error occured in the slackget10::PkgTool class (during installpkg, upgradepkg or removepkg) but the class is unable to understand the error.\n"
	};
	bless($self,$class);
	
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Take a slackget10::Config object as argument :

	my $pkgtool = new slackget10::PkgTool ($config);

=head1 FUNCTIONS

slackget10::PkgTools methods used the followings status :

		0 : Package have been installed successfully.
		1 : Package have been upgraded successfully.
		2 : Package have been removed successfully.
		3 : Can't install package : new package not found in the cache.
		4 : Can't remove package : no such package installed.
		5 : Can't upgrade package : new package not found in the cache.
		6 : Can't install package : an error occured during <installpkg-binary /> system call
		7 : Can't remove package : an error occured during <removepkg-binary /> system call
		8 : Can't upgrade package : an error occured during <upgradepkg-binary /> system call
		9 : Package scheduled for install on next reboot.
		10 : An error occured in the slackget10::PkgTool class (during installpkg, upgradepkg or removepkg) but the class is unable to understand the error.

=head2 install

Take a single slackget10::Package object or a single slackget10::PackageList as argument and call installpkg on all this packages.
Return 1 or undef if an error occured. But methods from the slackget10::PkgTools class don't return on the first error, it will try to install all packages. Additionnally, for each package, set a status.

	$pkgtool->install($package_list);

=cut

sub install {
	 
	sub _install_package
	{
		my ($self,$pkg) = @_;
		my $status = new slackget10::Status (codes => $self->{STATUS});
		#$self->{CONF}->{common}->{'update-directory'}/".$server->shortname."/cache/
		if($pkg->getValue('install_later'))
		{
			mkdir "/tmp/slack_get_boot_install" unless( -e "/tmp/slack_get_boot_install") ;
		}
		elsif( -e "$self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz")
		{
			if(system("$self->{CONF}->{common}->{pkgtools}->{'installpkg-binary'} $self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz")==0)
			{
				$status->current(0);
				return $status ;
			}
			else
			{
				$status->current(6);
				return $status ;
			}
			
		}
		else
		{
			$status->current(3);
			return $status ;
		}
	}
	my ($self,$object) = @_;
	if(ref($object) eq 'slackget10::PackageList')
	{
		print "Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
			$pack->status($self->_install_package($pack));
		}
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
		print "[install] Do the job for a slackget10::Package '$object'\n";
		$object->status($self->_install_package($object));
	}
	else
	{
		return undef;
	}
}

=head2 upgrade

Take a single slackget10::Package object or a single slackget10::PackageList as argument and call upgradepkg on all this packages.
Return 1 or undef if an error occured. But methods from the slackget10::PkgTools class don't return on the first error, it will try to install all packages. Additionnally, for each package, set a status.

	$pkgtool->install($package_list) ;

=cut

sub upgrade {
	
	sub _upgrade_package
	{
		my ($self,$pkg) = @_;
		my $status = new slackget10::Status (codes => $self->{STATUS});
		#$self->{CONF}->{common}->{'update-directory'}/".$server->shortname."/cache/
		if( -e "$self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz")
		{
			print "\tTrying to upgrade package: $self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz\n";
			if(system("$self->{CONF}->{common}->{pkgtools}->{'upgradepkg-binary'} $self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz")==0)
			{
				$status->current(1);
				return $status ;
			}
			else
			{
				$status->current(8);
				return $status ;
			}
		}
		else
		{
			$status->current(5);
			return $status ;
		}
	}
	my ($self,$object) = @_;
	if(ref($object) eq 'slackget10::PackageList')
	{
		print "Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
			$pack->status($self->_upgrade_package($pack));
		}
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
		print "Do the job for a slackget10::Package\n";
		$object->status($self->_upgrade_package($object));
	}
	else
	{
		return undef;
	}
}

=head2 remove

Take a single slackget10::Package object or a single slackget10::PackageList as argument and call installpkg on all this packages.
Return 1 or undef if an error occured. But methods from the slackget10::PkgTools class don't return on the first error, it will try to install all packages. Additionnally, for each package, set a status. 

	$pkgtool->install($package_list);

=cut

sub remove {
	
	sub _remove_package
	{
		my ($self,$pkg) = @_;
		my $status = new slackget10::Status (codes => $self->{STATUS});
		#$self->{CONF}->{common}->{'update-directory'}/".$server->shortname."/cache/
		if( -e "$self->{CONF}->{common}->{'update-directory'}/".$pkg->getValue('package-source')."/cache/".$pkg->get_id.".tgz")
		{
			print "\tTrying to remove package: ".$pkg->get_id."\n";
			if(system("$self->{CONF}->{common}->{pkgtools}->{'removepkg-binary'} ".$pkg->get_id)==0)
			{
				$status->current(2);
				return $status ;
			}
			else
			{
				$status->current(7);
				return $status ;
			}
		}
		else
		{
			$status->current(4);
			return $status ;
		}
	}
	my ($self,$object) = @_;
	if(ref($object) eq 'slackget10::PackageList')
	{
		print "Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
			$pack->status($self->_remove_package($pack));
		}
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
		print "Do the job for a slackget10::Package\n";
		$object->status($self->_remove_package($object));
	}
	else
	{
		return undef;
	}
}

#         <package id="imagemagick-6.1.9_0-i486-1">
#                 <date hour="10:29:00" day-number="22" month-number="01" year="2005" />
#                 <compressed-size>3339</compressed-size>
#                 <package-source>slackware</package-source>
#                 <location>./slackware/xap</location>
#                 <version>6.1.9_0</version>
#                 <name>imagemagick</name>
#                 <uncompressed-size>12750</uncompressed-size>
#                 <description>imagemagick (a robust collection of image processing tools)
#                         ImageMagick is a collection of tools for manipulating and displaying
#                 digital images.  It can merge images, transform image dimensions,
#                 do screen captures, create animation sequences, and convert between
#                 many different image formats.
#                         ImageMagick was written by John Cristy of ImageMagick Studio.
#                         Home page:  http://www.imagemagick.org/
# 
#                 </description>
#                 <info-homepage> http://www.imagemagick.org/</info-homepage>
#                 <signature-checksum>ff61e93f6c325f062dc319d265466aad</signature-checksum>
#                 <checksum>aad2b267f0e49f88b1f8ac726be2d6e3</checksum>
#                 <architecture>i486</architecture>
#                 <package-location>slackware/xap/</package-location>
#                 <package-version>1</package-version>
#         </package>



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

1; # End of slackget10::PkgTools
