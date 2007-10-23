
package slackget10::Operation;

use warnings;
use strict;

=head1 NOM

slackget10::Operation - Abstraction of an operation

=head1 VERSION

Version 0.5

=cut

our $VERSION = '0.5';

=head1 SYNOPSIS

A class to represent an operation (installation, upgrade, etc.). Mainly designed to make operations management in the GUI simplier.

	## This is a dumb example...

	use slackget10::Operation;
	
	my $op = slackget10::Operation->new(
		action => 'installpkg'
		data => $package_list,   # $package_list is a slackget10::PackageList object
	);
	$net->installpkg( $op->data() );
	


=cut

=head1 CONSTRUCTOR

new() : The constructor take the followings arguments :

	id : an operation id. If the ID is not set by you, the constructor use the class reference as ID and it's not suitable at all.
	action : the name of the operation, this name must be understood by the method which will process this operation (obviously...).
	data : data that belongs to the operation.

Commonly the operation's action will be the name of a method from the slackget10::Network class.
	
If the method receiving this object just call the appropriate method of a specific class you just have to read the documentation of this class and put in the data section the right data.

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={};
	$self->{DATA} = \%args ;
	bless($self,$class);
	$self->{DATA}->{id} = ''.$self unless($self->{DATA}->{id});
	return $self;
}

=head1 ACCESSORS

=head2 data

Get/Set the data payload of the current slackget10::Operation object.

=cut

sub data
{
	return $_[1] ? $_[0]->{DATA}->{data}=$_[1] : $_[0]->{DATA}->{data};
}

=head2 action

Get/Set the action of the current slackget10::Operation object.

	$op->action('installpkg');

=cut

sub action
{
	return $_[1] ? $_[0]->{DATA}->{action}=$_[1] : $_[0]->{DATA}->{action};
}

=head2 id

Get/Set the id of the current slackget10::Operation object. The ID usage is up to the receiving class, but in all case you must 

	print $op->id();

=cut

sub id
{
	return $_[1] ? $_[0]->{DATA}->{id}=$_[1] : $_[0]->{DATA}->{id};
}

=head2 item

Get/Set the QListViewItem object reference (for GUI only). This accessor is provided to help the design of the GUI.

=cut

sub item
{
	return $_[1] ? $_[0]->{DATA}->{item}=$_[1] : $_[0]->{DATA}->{item};
}

=head2 state

Get/Set the processing state of this operation. This state can be updated by the "thing" which process the operation, this way the current state is accessible to all object who can access this method.

You can use any data type you want to represent the state, but if you develop a plug-in or anything else for slack-get the following states are used :

	0 : operation is in queue, waiting for being processed.
	1 : operation processing in progress (in the GUI during this state an operation is locked and not accessible)
	2 : operation successfully processed.
	3: an error occur during operation's processing.
	4: operation cancelled

This list can be completed if needed.

	$op->state(2);
	
	print "operation cancelled\n" if ( $op->state == 4 ) ;

=cut

sub state
{
	return $_[1] ? $_[0]->{DATA}->{state}=$_[1] : $_[0]->{DATA}->{state};
}

=head2 state_callback

Get/Set the callback eventually executed (if defined) at a state modification of this object. Valid state (for slack-get) are the state listed in the the state() method.

	# Setting a callback which don't take any arguments
	$op->state_callback(2,\&my_success_hook) ;
	
	# Setting a callback which take some arguments
	$op->state_callback(3,\&my_error_hook,$message,$dump) ;
	
	# Calling a callback method
	$op->state_callback(2);

=cut

sub state_callback
{
	my ($self,$call_id,@data) = @_ ;
	if(@data)
	{
		$self->{DATA}->{state_callback}->{$call_id}->{callback} = $data[0];
		$self->{DATA}->{state_callback}->{$call_id}->{callback_data} = [@data[1..$#data]];
	}
	else
	{
		$self->{DATA}->{state_callback}->{$call_id}->{callback}->(@{$self->{DATA}->{state_callback}->{$call_id}->{callback_data}}) ;
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

1; # Fin de slackget10::Operation

