package slackget10;

use warnings;
use strict;

require slackget10::Base ;
require slackget10::Log ;
require slackget10::Network::Auth ;
require slackget10::Config ;
require slackget10::PkgTools ;

=head1 NAME

slackget10 - The main slack-get 1.0 library

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

slack-get (http://slackget.infinityperl.org) is an apt-get like tool for Slackware Linux. This bundle is the core library of this program.

The name slackget10 means slack-get 1.0 because this module is complely new and is for the 1.0 release. It is entierely object oriented, and require some other modules (like XML::Simple, Net::Ftp and LWP::Simple).

This module is still pre-in alpha development phase and I release it on CPAN only for coder which want to see the new architecture. For more informations, have a look on subclasses.

    use slackget10;

    my $sgo = slackget10->new(
    	-config => '/etc/slack-get/config.xml',
	-name => 'slack-getd',
	-version => '1.0.1228'
    );
    
    $sgo->log()->Log(1,"A log message") ;
    

=cut

=head1 CONSTRUCTOR

The constructor (new()), is used to instanciate all needed class for a slack-get instance.

=head2 new

You have to pass the followings arguments to the constructor :

	-config => the name of the configuration file.
	-name => the name of the application wich create 
	-version => the version of the calling program

-name and -version arguments are passed to the constructor of the slackget10::Log object.

=cut

sub new {
	my $class = 'slackget10' ;
	my $self = {} ;
	if(scalar(@_)%2 != 0)
	{
		$class = shift(@_) ;
	}
	my %args = @_ ;
	die "FATAL: You must pass a configuration file as -config parameter.\n" if(!defined($args{'-config'}) || ! -e $args{'-config'}) ;
	die "FATAL: You must pass a name for this instance of slackget10 via the -name parameter.\n" if(!defined($args{'-name'})) ;
	die "FATAL: You must pass a version to this constructor via the -version parameter.\n" if(!defined($args{'-version'})) ;
	$self->{'config'} = new slackget10::Config ( $args{'-config'} )  or die "FATAL: error during configuration file parsing\n$!\n" ;
# 	printf("create log...
# 		LOG_FORMAT => $self->{'config'}->{common}->{'log'}->{'log-format'},
# 		NAME => $args{'-name'},
# 		VERSION => $args{'-version'},
# 		LOG_FILE => $self->{'config'}->{common}->{'log'}->{'log-file'},
# 		LOG_LEVEL => $self->{'config'}->{common}->{'log'}->{'log-level'},
# 		FILE_ENCODING => $self->{'config'}->{common}->{'file-encoding'}
# 	\n");
	$self->{'log'} = slackget10::Log->new(
		LOG_FORMAT => $self->{'config'}->{common}->{'log'}->{'log-format'},
		NAME => $args{'-name'},
		VERSION => $args{'-version'},
		LOG_FILE => $self->{'config'}->{common}->{'log'}->{'log-file'},
		LOG_LEVEL => $self->{'config'}->{common}->{'log'}->{'log-level'},
		FILE_ENCODING => $self->{'config'}->{common}->{'file-encoding'}
	);
	$self->{'base'} = new slackget10::Base ( $self->{'config'} );
	$self->{'pkgtools'} = new slackget10::PkgTools ( $self->{'config'} );
	$self->{'auth'} = slackget10::Network::Auth->new( $self->{'config'} );
	bless($self,$class) ;
	return $self;
}

=head1 FUNCTIONS

=head2 load_plugins

Search for all plugins in the followings directories : <all @INC directories>/lib/slackget10/Plugin/, <INSTALLDIR>/lib/slackget10/Plugin/, <HOME DIRECTORY>/lib/slackget10/Plugin/.

When you call this method, she scan in thoses directory and try to load all files ending by .pm. The loading is in 4 times :

1) scan for plug-in

2) try to "require" all the finded modules.

3) Try to instanciate all modules successfully "require"-ed. To do that, this method call the new() method of the plug-in and passed the current slackget10 object reference. The internal code is like that :

	# slackget10::Plugin::MyPlugin is the name of the plug-in
	# $self is the reference to the current slackget10 object.
	
	my $plugin = slackget10::Plugin::MyPlugin->new( $self ) ;

The plug-in can internally store this reference, and by the way acces to the instance of this objects : slackget10, slackget10::Base, slackget10::Config, slackget10::Network::Auth and slackget10::PkgTools.

IN ALL CASE, PLUG-INS ARE NOT ALLOWED TO MODIFY THE slackget10 OBJECT !

For performance consideration we don't want to clone all accesible objects, so all plug-in developper will have to respect this rule : you never modify object accessible from this object ! At the very least if you have a good idea send me an e-mail to discuss it.

4) dispatch plug-ins' instance by supported HOOK.

=cut

sub load_plugins {
	my $self = shift;
	my $HOOKS = shift;
	#NOTE : searching for install plug-in
	$self->log()->Log(2,"searching for plug-in\n") ;
	my @plugins_name;
	foreach my $dir (@INC)
	{
		if( -e "$dir/slackget10/Plugin" && -d "$dir/slackget10/Plugin")
		{
			foreach my $name (`ls -1 $dir/slackget10/Plugin/*.pm`)
			{
				chomp $name ;
				$name =~ s/.+\/([^\/]+)\.pm$/$1/;
				$self->log()->Log(2,"found plug-in: $name\n") ;
# 				print "[SG10] found plug-in: $name\n" ;
				push @plugins_name, $name;
			}
		}	
		
	}
	#NOTE : loading plug-in
	$self->log()->Log(2,"loading plug-in\n") ;
	my @loaded_plugins;
	foreach my $plg (@plugins_name)
	{
		my $ret = eval qq{require slackget10::Plugin::$plg} ;
		unless($ret)
		{
			if($@)
			{
				warn "Fatal Error while parsing plugin $plg : $@\n";
				$self->log()->Log(1,"Fatal Error while parsing plugin $plg : $@\n") ;
			}
			elsif($!)
			{
				warn "Fatal Error while loading plugin $plg : $!\n";
				$self->log()->Log(1,"Fatal Error while parsing plugin $plg : $!\n") ;
			}
		}
		else
		{
# 			print "[SG10] loaded success for plug-in $plg\n" ;
			push @loaded_plugins, $plg;
		}
	}
	#NOTE : creating new instances
	$self->log()->Log(2,"creating new plug-in instance\n") ;
	my @plugins;
	foreach my $plugin (@loaded_plugins)
	{
		my $package = "slackget10::Plugin::$plugin";
		my $ret = eval{ $package->new($self) ; }  ; 
		if($@ or !$ret)
		{
			warn "Fatal Error while creating new instance of plugin $package: $@\n";
			$self->log()->Log(1,"Fatal Error while creating new instance of plugin $package: $@\n") ;
		}
		else
		{
# 			print "[SG10] $plugin instanciates\n" ;
			push @plugins, $ret;
		}
	}
	@plugins_name = ();
	@loaded_plugins = ();
	$self->{'plugin'}->{'raw_table'} = \@plugins ;
	$self->{'plugin'}->{'sorted'} = {} ;
	# NOTE: dispatching plug-ins by hooks.
	$self->log()->Log(2,"dispatching plug-in by supported HOOKS\n") ;
	foreach my $hook (@{ $HOOKS })
	{
		$self->{'plugin'}->{'sorted'}->{$hook} = [] ;
		foreach my $plugin (@plugins)
		{
			if($plugin->can(lc($hook)))
			{
# 				print "[SG10] registered plug-in $plugin for hook $hook\n" ;
				push @{ $self->{'plugin'}->{'sorted'}->{$hook} },$plugin ;
			}
		}
	}
}

=head2 call_plugins

Main method for calling back differents plug-in. This method is quite easy to use : just call it with a hook name in parameter.

call_plugins() will iterate on all plug-ins wich implements the given HOOK.

	$sgo->call_plugins( 'HOOK_START_DAEMON' ) ;

Additionaly you can pass all arguments you need to pass to the callback which take care of the HOOK. All extra arguments are passed to the callback.

Since all plug-ins have access to many objects which allow them to perform all needed operations (like logging etc), they have to care about output and user information.

So all call will be eval-ed and juste a little log message will be done on error.

=cut

sub call_plugins
{
	my $self = shift;
	my $HOOK = shift ;
	my @returned;
	foreach my $pg ( @{ $self->{'plugin'}->{'sorted'}->{$HOOK} })
	{
		my $callback = lc($HOOK);
		push @returned, eval{ $pg->$callback(@_) ;} ;
		if($@)
		{
			$self->{'log'}->Log(1,"An error occured while attempting to call plug-in ".ref($pg)." for hook $HOOK. The error occured in method $callback. The evaluation return the following error : $@\n");
		}
	}
	return @returned ;
}

=head1 ACCESSORS

=head2 log

Return the log object of the current instance of the slackget10 object.

	$sgo->log()->Log(1,"This is a log message\n") ;

=cut

sub log
{
	my $self = shift;
	return $self->{'log'} ;
}

=head2 base

Return the slackget10::Base object of the current instance of the slackget10 object.

	$sgo->base()->compil_package_directory('/var/log/packages/');

=cut

sub base
{
	my $self = shift;
	return $self->{'base'} ;
}

=head2 pkgtools

Return the slackget10::PkgTools object of the current instance of the slackget10 object.

	$sgo->pkgtools()->install( $package_list ) ;

=cut

sub pkgtools
{
	my $self = shift;
	return $self->{'pkgtools'} ;
}

=head2 config

Return the slackget10::Config object of the current instance of the slackget10 object.

	print $sgo->config()->{common}->{'file-encoding'} ;

=cut

sub config
{
	my $self = shift;
	return $self->{'config'} ;
}

=head2 auth

Return the slackget10::Network::Auth object of the current instance of the slackget10 object.

	$sgo->auth()->can_connect($client) or die "Client not allowed to connect here\n";

=cut

sub auth
{
	my $self = shift;
	return $self->{'auth'} ;
}

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10
