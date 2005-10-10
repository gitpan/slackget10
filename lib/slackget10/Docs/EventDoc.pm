package slackget10::Docs::EventDoc ;

use vars qw($VERSION);
$VERSION = '1.0.0_1';

1;
__END__

=head1 NAME

slackget10::Docs::EventDoc - A documentation which describe the network event base communication system.

=head1 DESCRIPTION

This documentation give all the programmation informations for programming with the event base communication system of slack-get 1.0.x.

=head1 VERSION

The version of this document is : 1.0.0_1

=head1 Introduction

This system (for convenience we will call it EBCS in the rest of this document) is mainly usefull in network communication, but all communications are networked in slack-get 1.0.x branch :-)

The communication via EBCS is implemented in communications between slack-getd, slack-browser and slack-get. Eventually, if other binary came in the distribution (and if they have to communicate with those 3 programs) they will use EBCS.

The principle of EBCS is simple : programs emit a network message, this one is handle by the L<slackget10::Network> class, and this one dispatch message to treatment callbacks. There is default handler in L<slackget10::Network> but there are not really usefull.

Before starting the core documentation, please note that the version number of this document is build on the this scheme : <slack-get version number>_<version of this document>. This means that the number after the underscore ('_') is the version of this document for a specific slack-get release.

=head2 Events/Callbacks

In this parapgrah we will discuss about available network messages (called "events" here) and about callbacks. Network messages in EBCS always respect this format :

	<event>:[<extra arguments to this event>:]<message>

In all messages <event> and <message> are mandatory. There is currently 5 events :

	* success
	* info
	* error
	* unknown_said
	* choice

Thoses messages are used in the followings contexts :

C<success> : A command finished in success state.

C<info> : A message is emit by a program but this is not an error, a success and not a choice. There is 3 info level.

C<error> : An error occured and the program report it. This is not the worst case because if you can receive an error message this mean that the sender program is always able to transmit it !

C<unknown_said> : A message is emit by a client and the server cannot handle it. So it report it as an unknown command. This allow differents programs (which may have different versions) to adapt their communication protocol.

C<choice> : This message is send when a choice between 2 or more packages is available.


For all message, there is a hook nammed "on_<event>". All hooks can be connected to a callback (via a CODEREF), please read L<slackget10::Network> for more information on how to implement a callback and register it.

Here is a list of the correspondence between events, hooks and callbacks (format is : <event> : <hook format> : callback description):

C<success> : on_success : callback may take a string wich describe the success state.

C<info> : on_info : callback may take 2 parameters : the info level (integer between 1 and 3 included), and a string (wich describe the info message)

C<error> : on_error : callback may take a string which is the error message. For the moment I have no use of interaction here. Indeed if a choice is needed we have the on_choice hook and if the message is not an error we have the on_info hook.

C<unknown_said> : on_unknown : The callback need to take a string as argument. The string passed is the full message wich have been not understand by the remote program.

C<choice> : on_choice : This method must take a string as argument. The string is an XML serialized slackget10::PackageList (L<slackget10::PackageList>). This callback must take care of the response (i.e must send the response to the asker).

=head2 EBCS protocol

Protocol message are given here for information :

C<success message> :

	success:<message>

C<info message> :

	info:<level>:<message>

C<error message> :

	error:<message>

C<choice message> :

	choice:<XML serialized slackget10::PackageList>

C<unknow message> :

	unknown_said:<complete un-understand message>


All thoses message are handles by a private method of the slackget10::Network class ( _handle_protocol() ), so you only have to care about callbacks.

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 SEE ALSO

L<slackget10>, L<http://www.gnu.org/copyleft/fdl.html>, L<slackget10::Network>

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This documentation is a free documentation; you can redistribute it and/or modify it
under the terms of the GNU/FDL License..

=cut

