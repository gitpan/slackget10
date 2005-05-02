package slackget10::Config;

use warnings;
use strict;

use XML::Simple;

=head1 NAME

slackget10::Config - An interface to the configuration file

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is use to load a configuration file (config.xml) and the servers list file (servers.xml). It only encapsulate the XMLin() method of XML::Simple, there is no accessors or treatment method for this class.
There is only a constructor which take only one argument : the name of the configuration file.

After loading you can acces to all values of the config file in the same way that with XML::Simple.

The only purpose of this class, is to allow other class to check that the config file have been properly loaded.

    use slackget10::Config;

    my $config = slackget10::Config->new('/etc/slack-get/config.xml') or die "cannot load config.xml\n";
    print "I will use the encoding: $config->{common}->{'file-encoding'}\n";
    print "slack-getd is configured as: $config->{daemon}->{mode}\n" ;

This module need XML::Simple to work.

=cut

sub new
{
	my ($class,$file) = @_ ;
	return undef unless(-e $file && -r $file);
	my $self= XMLin($file) or return undef;
	bless($self,$class);
	return $self;
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

1; # End of slackget10::Config
