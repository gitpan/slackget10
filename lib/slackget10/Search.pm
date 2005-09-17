package slackget10::Search;

use warnings;
use strict;

=head1 NAME

slackget10::Search - The slack-get search class

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

A class to search for packages on a slackget10::PackageList object

    use slackget10::Search;

    my $search = slackget10::Search->new($packagelist);
    my @array = $search->search_package($string); # the simplier, search a matching package name
    my @array = $search->search_package_in description($string); # More specialyze, search in the package description
    my @array = $search->search_package_multi_fields($string,@fields); # search in each fields for matching $string

All methods return an array of slackget10::Package objects.

=cut

=head1 CONSTRUCTOR

=head2 new

The constructor take a slackget10::PackageList object as argument.

	my $search = slackget10::Search->new($packagelist);

=cut

sub new
{
	my ($class,$packagelist) = @_ ;
	my $self={};
	return undef if(ref($packagelist) ne 'slackget10::PackageList');
	$self->{PKGLIST} = $packagelist;
	bless($self,$class);
	return $self;
}

=head1 FUNCTIONS

=head2 search_package

This method take a string as parameter search for packages matching the string, and return an array of slackget10::Package

	@packages = $packageslist->search_package('gcc');

=cut

sub search_package {
	my ($self,$string) = @_ ;
	my @result;
	foreach (@{$self->{PKGLIST}->get_all()}){
		if($_->get_id() =~ /\Q$string\E/i or $_->name() =~ /\Q$string\E/i){
			push @result, $_;
		}
	}
	return (@result);
}

=head2 exact_search

This method take a string as parameter search for packages where the id is equal to this string. Return the index of the packages in the list.

	$idx = $packageslist->exact_search('perl-mime-base64-3.05-noarch-1');

=cut

sub exact_search
{
	my ($self,$string) = @_ ;
	my @result;
	my $k=0;
	foreach (@{$self->{PKGLIST}->get_all()}){
		next unless(defined($_));
		if($_->get_id() eq $string){
			push @result, $k;
		}
		$k++;
	}
	return (@result);
}

=head2 exact_name_search

Same as exact_search() but search on the name of the package instead of its id.

	$idx = $packageslist->exact_search('perl-mime-base64');

=cut

sub exact_name_search
{
	my ($self,$string) = @_ ;
	my @result;
	my $k=0;
	foreach (@{$self->{PKGLIST}->get_all()}){
		next unless(defined($_));
		if($_->name() eq $string){
			push @result, $k;
		}
		$k++;
	}
	return (@result);
}

=head2 search_package_in_description

Take a string as parameter, and search for this string in the package description

	my @array = $search->search_package_in description($string);

=cut

sub search_package_in_description {
	my ($self,$string) = @_ ;
	my @result;
	foreach (@{$self->{PKGLIST}->get_all()}){
		if($_->get_id() =~ /\Q$string\E/i or $_->description() =~ /\Q$string\E/i){
			push @result, $_;
		}
	}
	return (@result);
}

=head2 search_package_multi_fields

Take a string and a fiels list as parameter, and search for this string in the package required fields

	my @array = $search->search_package_multi_fields($string,@fields);

=cut

sub search_package_multi_fields {
	my ($self,$string,@fields)=@_;
	my @result;
	foreach (@{$self->{PKGLIST}->get_all()}){
		foreach my $field (@fields)
		{
			if($field=~ /^([^=]+)=(.+)/)
			{
				if(defined($_->getValue($1)) && $_->getValue($1) ne $2)
				{
					print "[search] '$1' => '",$_->getValue($1),"' ne '$2'\n";
					last ;
				}
			}
			if($_->get_id() =~ /\Q$string\E/i or (defined($_->getValue($field)) && $_->getValue($field)=~ /\Q$string\E/i)){
				push @result, $_;
				last;
			}
		}
	}
	return (@result);
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

1; # End of slackget10::Search
