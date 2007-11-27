
package slackget10::MD5;

use warnings;
use strict;

=head1 NOM

slackget10::MD5 - A simple class to verify files checksums

=head1 VERSION

Version 0.1

=cut

our $VERSION = '0.1';

=head1 SYNOPSIS

A simple class to verify files checksums with md5sum.

    use slackget10::MD5;

    my $slackget10_gpg_object = slackget10::MD5->new();

IMPORTANT NOTE : This class is not design to be use by herself (the constructor for example is totaly useless). the slackget10::Package class inheritate of this class and this is the way is design slackget10::MD5 : to be only an abstraction of the MD5 verification operations.

You may prefer to inheritate from this class, but take attention to the fact that I design it to be inheritate by the slackget10::Package class !

=cut

=head1 CONSTRUCTOR

new() : The constructor doesn't take any arguments but be sure the md5sum binary is in the PATH !

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={};
	bless($self,$class);
	return $self;
}

=head1 METHODS

=head2 verify_md5

This method call the getValue() accessor (from the slackget10::Package class) on the 'checksum' or 'signature-checksum' field, and check if it match with the MD5 of the file passed in argument.

If the argument ends with ".tgz" this method use the 'checksum' field and if it ends with ".asc" it use the 'signature-checksum' field.

	$package->verify_md5("/home/packages/update/package-cache/apache-1.3.33-i486-1.tgz") && $sgo->installpkg($packagelist->get_indexed("apache-1.3.33-i486-1")) ;

Returned values :

	undef : if a problem occur (ex: the current instance do not inheritate from slackget10::Package, the file is not a package nor a signature, etc.)
	1 : if the MD5 is ok
	0 : if not.

This method also set a 'computed-checksum' and a 'computed-signature-checksum' in the current slackget10::Package object.

=cut

sub verify_md5
{
	my ($self,$file) = @_;
	return undef if(ref($self) eq '' || !$self->can("getValue")) ;
	my $out = `2>&1 LANG=en_US md5sum $file`;
	chomp $out;
	if($out=~ /^([^\s]+)\s+.*/)
	{
		my $tmp_md5 = $1;
		print "\$tmp_md5 : $tmp_md5\n";
		if($file =~ /\.tgz$/)
		{
			$self->setValue('computed-checksum',$tmp_md5);
			if($self->getValue('checksum') eq $tmp_md5)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		elsif($file =~ /\.asc$/)
		{
			$self->setValue('computed-signature-checksum',$tmp_md5);
			if($self->getValue('signature-checksum') eq $tmp_md5)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		else
		{
			return undef;
		}
	}
	
	return undef;
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

1; # Fin de slackget10::MD5

