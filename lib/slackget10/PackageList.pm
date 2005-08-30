package slackget10::PackageList;

use warnings;
use strict;

require slackget10::Package;
require slackget10::List ;
require slackget10::Date ;

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

=head2 new

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

This class inheritate from slackget10::List (L<slackget10::List>), so you may want read the slackget10::List documentation for the supported methods of this class.

=cut

=head2 fill_from_xml

Fill the slackget10::PackageList from the XML data passed as argument.

	$packagelist->fill_from_xml(
		'<choice action="installpkg">
			<package id="gcc-objc-3.3.4-i486-1">
				<date hour="12:32:00" day-number="12" month-number="06" year="2004" />
				<compressed-size>1395</compressed-size>
				<location>./slackware/d</location>
				<package-source>slackware</package-source>
				<version>3.3.4</version>
				<name>gcc-objc</name>
				<uncompressed-size>3250</uncompressed-size>
				<description>gcc-objc (Objective-C support for GCC)
					Objective-C support for the GNU Compiler Collection.
					This package contains those parts of the compiler collection needed to
				compile code written in Objective-C.  Objective-C was originally
				developed to add object-oriented extensions to the C language, and is
				best known as the native language of the NeXT computer.
		
				</description>
				<signature-checksum>565a10ce130b4287acf188a6c303a1a4</signature-checksum>
				<checksum>23bae31e3ffde5e7f44617bbdc7eb860</checksum>
				<architecture>i486</architecture>
				<package-location>slackware/d/</package-location>
				<package-version>1</package-version>
				<referer>gcc-objc</referer>
			</package>
		
			<package id="gcc-objc-3.4.3-i486-1">
				<date hour="18:24:00" day-number="21" month-number="12" year="2004" />
				<compressed-size>1589</compressed-size>
				<package-source>slackware</package-source>
				<version>3.4.3</version>
				<name>gcc-objc</name>
				<signature-checksum>1027468ed0d63fcdd584f74d2696bf99</signature-checksum>
				<architecture>i486</architecture>
				<checksum>5e659a567d944d6824f423d65e4f940f</checksum>
				<package-location>testing/packages/gcc-3.4.3/</package-location>
				<package-version>1</package-version>
				<referer>gcc-objc</referer>
			</package>
		</choice>'
	);

=cut

sub fill_from_xml
{
	my ($self,@xml) = @_ ;
	my $xml = '';
	foreach (@xml)
	{
		$xml .= $_ ;
	}
	require XML::Simple ;
	my $xml_in = XML::Simple::XMLin($xml,KeyAttr => {'package' => 'id'});
# 	use Data::Dumper ;
# 	print Data::Dumper::Dumper($xml_in);
	foreach my $pack_name (keys(%{$xml_in->{'package'}})){
		my $package = new slackget10::Package ($pack_name);
		foreach my $key (keys(%{$xml_in->{'package'}->{$pack_name}})){
			if($key eq 'date')
			{
				$package->setValue($key,slackget10::Date->new(%{$xml_in->{'package'}->{$pack_name}->{$key}}));
			}
			else
			{
				$package->setValue($key,$xml_in->{'package'}->{$pack_name}->{$key}) ;
			}
			
		}
		$self->add($package);
	}
}

=head2 Sort

Apply the Perl built-in function sort() on the PackageList. This method return nothing.

	$list->Sort() ;

=cut

sub Sort
{
	my $self = shift ;
	$self->{LIST} = [ sort {$a->{ROOT} cmp $b->{ROOT} } @{ $self->{LIST} } ] ;
}

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
