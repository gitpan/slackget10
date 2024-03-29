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
	$self->{DATA} = {
		'info-output' => undef,
		'connection-id' => 0
	};
	bless($self,$class);
	
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Take a slackget10::Config object as argument :

	my $pkgtool = new slackget10::PkgTool ($config);
=cut

sub _send_info
{
	my ($self,$action,$pkg) = @_;
	my $client=0;
	$client = $self->{DATA}->{'info-output'} if(defined($self->{DATA}->{'info-output'}) && $self->{DATA}->{'info-output'});
	#print for debug purpose
	print "[slackget10::PkgTools::DEBUG] info:$self->{DATA}->{'connection-id'}:2:progress:file=$pkg;state=now$action\n";
	
	print $client->put("info:$self->{DATA}->{'connection-id'}:2:progress:file=$pkg;state=now$action\n") if($client && defined($self->{DATA}->{'connection-id'}) && $self->{DATA}->{'connection-id'});
}

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
# 		print "[slackget10::PkgTools::_install_package DEBUG] try to install package ",$pkg->get_id,"\n";
		if($pkg->getValue('install_later'))
		{
# 			print "[slackget10::PkgTools::_install_package DEBUG] package ",$pkg->get_id," will be installed later.\n";
			mkdir "/tmp/slack_get_boot_install" unless( -e "/tmp/slack_get_boot_install") ;
		}
		elsif( -e "$self->{CONF}->{common}->{'update-directory'}/package-cache/".$pkg->get_id.".tgz")
		{
			$self->_send_info('install',$pkg->get_id());
# 			print "[slackget10::PkgTools::_install_package DEBUG] log file : $self->{CONF}->{common}->{'log'}->{'log-file'}\n";
			if(system("2>>$self->{CONF}->{common}->{'log'}->{'log-file'} $self->{CONF}->{common}->{pkgtools}->{'installpkg-binary'} $self->{CONF}->{common}->{'update-directory'}/package-cache/".$pkg->get_id.".tgz")==0)
			{
# 				print "[slackget10::PkgTools::_install_package DEBUG] package ",$pkg->get_id," have been correctly installed\n";
				$status->current(0);
				return $status ;
			}
			else
			{
# 				print "[slackget10::PkgTools::_install_package DEBUG] package ",$pkg->get_id," have NOT been correctly installed\n";
				$status->current(6);
				return $status ;
			}
			
		}
		else
		{
# 			print "[slackget10::PkgTools::_install_package DEBUG] package ",$pkg->get_id," can't be installed.\n";
			$status->current(3);
			return $status ;
		}
	}
	my ($self,$object) = @_;
	if(ref($object) eq 'slackget10::PackageList')
	{
# 		print "[install] Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
# 			print "[install] sending ",$pack->get_id," to _install_package.\n";
			$pack->status($self->_install_package($pack));
		}
# 		print "[install] end of the install loop.\n";
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
# 		print "[install] Do the job for a slackget10::Package '$object'\n";
		$object->status($self->_install_package($object));
	}
	else
	{
		return undef;
	}
# 	print "[slackget10::PkgTools DEBUG] all job processed.\n";
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
		if( -e "$self->{CONF}->{common}->{'update-directory'}/package-cache/".$pkg->get_id.".tgz")
		{
			$self->_send_info('upgrade',$pkg->get_id());
# 			print "\tTrying to upgrade package: $self->{CONF}->{common}->{'update-directory'}/package-cache/".$pkg->get_id.".tgz\n";
			if(system("2>>$self->{CONF}->{common}->{'log'}->{'log-file'} $self->{CONF}->{common}->{pkgtools}->{'upgradepkg-binary'} $self->{CONF}->{common}->{'update-directory'}/package-cache/".$pkg->get_id.".tgz")==0)
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
# 		print "Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
			$pack->status($self->_upgrade_package($pack));
		}
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
# 		print "Do the job for a slackget10::Package\n";
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
		if( -e "$self->{CONF}->{common}->{'packages-history-dir'}/".$pkg->get_id)
		{
			$self->_send_info('remove',$pkg->get_id());
# 			print "\tTrying to remove package: ".$pkg->get_id."\n";
			if(system("2>>$self->{CONF}->{common}->{'log'}->{'log-file'} $self->{CONF}->{common}->{pkgtools}->{'removepkg-binary'} ".$pkg->get_id)==0)
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
# 		print "Do the job for a slackget10::PackageList\n";
		foreach my $pack ( @{ $object->get_all() })
		{
			$pack->status($self->_remove_package($pack));
		}
	}
	elsif(ref($object) eq 'slackget10::Package')
	{
# 		print "Do the job for a slackget10::Package\n";
		$object->status($self->_remove_package($object));
	}
	else
	{
		return undef;
	}
}

=head2 info_output

Accessor to set/get the output medium to send informations about current operation. You must set a valid handle (STD*, filehandle, socket, etc.) or undef.

You can get an undefined value if the handle is not set.

Setting the output media activate the output system.

=cut

sub info_output
{
	return $_[1] ? $_[0]->{DATA}->{'info-output'}=$_[1] : $_[0]->{DATA}->{'info-output'};
}

=head2 connection_id

Accessor to set/get the connection id of a connection to or from a slack-get daemon. This is here if the output handle is that kind of connection. Anyway this value must be true so set it to 1 if you want an output.

=cut

sub connection_id
{
	return $_[1] ? $_[0]->{DATA}->{'connection-id'}=$_[1] : $_[0]->{DATA}->{'connection-id'};
}



=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc slackget10


You can also look for information at:

=over 4

=item * Infinity Perl website

L<http://www.infinityperl.org>

=item * slack-get specific website

L<http://slackget.infinityperl.org>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=slackget10>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/slackget10>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/slackget10>

=item * Search CPAN

L<http://search.cpan.org/dist/slackget10>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Bertrand Dupuis (yes my brother) for his contribution to the documentation.

=head1 SEE ALSO

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::PkgTools
