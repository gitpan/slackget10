package slackget10;

use warnings;
use strict;

=head1 NAME

slackget10 - The main slack-get 1.0 library

=head1 VERSION

Version 0.03b

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

slack-get (http://slackget.infinityperl.org) is an apt-get like tool for Slackware Linux. This bundle is the core library of this program.

The name slackget10 means slack-get 1.0 because this module is complely new and is for the 1.0 release. It is entierely object oriented, and require some other modules (like XML::Simple, Net::Ftp and LWP::Simple).

This module is still pre-in alpha development phase and I release it on CPAN only for coder which want to see the new architecture. For more informations, have a look on subclasses.

This release is mainly concentrate on the reinforcement of existing functionnalities (you can now found the /var/log/packages/ directory "compiler" at the root of this package), and adding the network support.
The development is now concentrate on the libraries needed by slackgetd.

    use slackget10;

    my $foo = slackget10->new();
    ...

# =head1 CONSTRUCTOR
# 
# =head1 FUNCTIONS
# 
# =head2 function1
# 
# =cut
# 
# sub function1 {
# }
# 
# =head2 function2
# 
# =cut
# 
# sub function2 {
# }

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
