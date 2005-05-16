package slackget10::PackageList;

use warnings;
use strict;

require slackget10::Package;
require slackget10::List ;

=head1 NAME

slackget10::PackageList - This class is a container of slackget10::Package object

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';
our @ISA = qw( slackget10::List );

=head1 SYNOPSIS

This class is a container of slackget10::Package object, and allow you to perform some operations on this packages list. As the Package class, it is a slack-get's internal representation of data.

    use slackget10::PackageList;

    my $packagelist = slackget10::PackageList->new();
    $packagelist->add($package);
    $packagelist->get($index);
    my $package = $packagelist->Shift();
    

=head1 CONSTRUCTOR

This class constructor don't take any parameters, but you can eventually disable the root tag <packagelist> by using 'no-root-tag' => 1.

	my $PackageList = new slackget10::PackageList ();
	my $PackageList = new slackget10::PackageList ('no-root-tag' => 1);

=cut

sub new
{
	my ($class,%args) = @_ ;
	my $self={list_type => 'slackget10::Package','root-tag' => 'package-list'};
	foreach (keys(%args))
	{
		$self->{$_} = $args{$_};
	}
	bless($self,$class);
	return $self;
}

=head1 FUNCTIONS

This class inheritate from slackget10::List, so you may want read the slackget10::List documentation for the supported methods of this class.

=cut

# =head2 add
# 
# Add the package passed in argument to the list. The argument must be a slackget10::Package object
# 
# 	$PackageList->add($package);
# 
# =cut
# 
# sub add {
# 	my ($self,$pack) = @_ ;
# 	
# 	return undef if(ref($pack) ne 'slackget10::Package');
# 	push @{$self->{LIST}}, $pack;
# 	return 1;
# }
# 
# =head2 get
# 
# return the $index slackget10::Package object in the list
# 
# 	$PackageList->get($index);
# 
# =cut
# 
# sub get {
# 	my ($self,$idx) = @_ ;
# 	return $self->{LIST}->[$idx];
# }
# 
# =head2 get_all
# 
# return a reference on an array containing all packages.
# 
# 	$arrayref = $PackageList->get_all();
# 
# =cut
# 
# sub get_all {
# 	my $self = shift ;
# 	return $self->{LIST};
# }
# 
# =head2 Shift
# 
# Same as the Perl shift. Shifts of and return the first slackget10::Package of the slackget10::PackageList;
# 
# 	$package = $PackageList->Shift();
# 
# =cut
# 
# sub Shift {
# 	my ($self) = @_ ;
# 	return shift(@{$self->{LIST}});
# }
# 
# =head2 to_XML
# 
# return an XML encoded string.
# 
# 	$xml = $PackageList->to_XML();
# 
# =cut
# 
# sub to_XML
# {
# 	my $self = shift;
# 	my $xml = '';
# 	$xml .= "<packagelist>\n" unless($self->{'no-root-tag'});
# 	foreach (@{$self->{LIST}}){
# 		$xml .= $_->to_XML();
# 	}
# 	$xml .= "</packagelist>\n" unless($self->{'no-root-tag'});
# 	return $xml;
# }
# 
# =head2 to_string
# 
# Alias for to_XML()
# 
# =cut
# 
# sub to_string{
# 	my $self = shift;
# 	$self->to_XML();
# }


=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-PackageList@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::PackageList
