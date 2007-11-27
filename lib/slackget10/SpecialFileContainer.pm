package slackget10::SpecialFileContainer;

use warnings;
use strict;

require slackget10::SpecialFiles::PACKAGES ;
require slackget10::SpecialFiles::FILELIST ;
require slackget10::SpecialFiles::CHECKSUMS ;
require slackget10::PackageList;
require slackget10::Package ;

=head1 NAME

slackget10::SpecialFileContainer - A class to class, sort and compil the PACKAGES.TXT, CHECKSUMS.md5 and FILELIST.TXT

=head1 VERSION

Version 0.9.6

=cut

our $VERSION = '0.9.6';
our $DEBUG=0;

=head1 SYNOPSIS

This class is a front-end for the 3 sub-class slackget10::SpecialFiles::PACKAGES , slackget10::SpecialFiles::CHECKSUMS and slackget10::SpecialFiles::FILELIST.

Act as a container but also make a treatment (the compilation of the 3 subclasses in one sol object)

=head1 CONSTRUCTOR

=head2 new

take the following arguments :

	a unique id
	FILELIST => the FILELIST.TXT filename
	PACKAGES => the PACKAGES.TXT filename
	CHECKSUMS => the CHECKSUMS.md5 filename
	config => a slackget10::Config object.

    use slackget10::SpecialFileContainer;

    my $container = slackget10::SpecialFileContainer->new(
    	'slackware',
	config => $config,
    	FILELIST => /home/packages/update_files/FILELIST.TXT,
	PACKAGES => /home/packages/update_files/PACKAGES.TXT,
	CHECKSUMS => /home/packages/update_files/CHECKSUMS.md5
    );

=cut

sub new
{
	my ($class,$root,%args) = @_ ;
	print "[slackget10::SpecialFileContainer] [debug] about to create a new instance\n" if($DEBUG);
	return undef unless(defined($root));
	my $self={};
	$self->{ROOT} = $root;
	unless($args{FILELIST} or $args{PACKAGES} or $args{CHECKSUMS}){
		warn "[slackget10::SpecialFileContainer] Required parameter FILELIST, PACKAGES or CHECKSUMS not found in the contructor\n";
		return undef;
	}
	$self->{DATA}->{config} = $args{config} if(defined($args{config}) && ref($args{config}) eq 'slackget10::Config');
	$self->{DATA}->{FILELIST} = slackget10::SpecialFiles::FILELIST->new($args{FILELIST},$self->{DATA}->{config},$root) or return undef;
	print "[slackget10::SpecialFileContainer] [debug] FILELIST instance : $self->{DATA}->{FILELIST}\n" if($DEBUG);
	$self->{DATA}->{PACKAGES} = slackget10::SpecialFiles::PACKAGES->new($args{PACKAGES},$self->{DATA}->{config},$root) or return undef;
	print "[slackget10::SpecialFileContainer] [debug] PACKAGES instance : $self->{DATA}->{PACKAGES}\n" if($DEBUG);
	$self->{DATA}->{CHECKSUMS} = slackget10::SpecialFiles::CHECKSUMS->new($args{CHECKSUMS},$self->{DATA}->{config},$root) or return undef;
	print "[slackget10::SpecialFileContainer] [debug] CHECKSUMS instance : $self->{DATA}->{CHECKSUMS}\n" if($DEBUG);
	bless($self);#,$class
	return $self;
}

=head1 FUNCTIONS

=head2 compile

Mainly call the compile() method of the special files.

	$container->compile();

=cut

sub compile {
	my $self = shift;
# 	printf("compiling FILELIST...");
	$|++;
	$self->{DATA}->{FILELIST}->compile ;
# 	print "ok\n";
# 	printf("compiling PACKAGES...");
	$self->{DATA}->{PACKAGES}->compile ; 
# 	print "ok\n";
# 	printf("compiling CHECKSUMS...");
	$self->{DATA}->{CHECKSUMS}->compile ;
# 	print "ok\n";
# 	printf("merging data...");
	$self->{DATA}->{PACKAGELIST} = undef;
	my $packagelist = slackget10::PackageList->new('no-root-tag' => 1) or return undef;
	my $r_list = $self->{DATA}->{FILELIST}->get_file_list ;
	foreach my $pkg_name (keys(%{$r_list})){
# 		print "[DEBUG] Getting info on $pkg_name\n";
		my $r_pack = $self->{DATA}->{PACKAGES}->get_package($pkg_name);
		my $r_chk = $self->{DATA}->{CHECKSUMS}->get_package($pkg_name);
		my $r_list = $self->{DATA}->{FILELIST}->get_package($pkg_name);
		my $pack = new slackget10::Package ($pkg_name);
		$pack->merge($r_pack);
		$pack->merge($r_chk);
		$pack->merge($r_list);
		$packagelist->add($pack);
# 		$pack->print_restricted_info ;
	}
	$packagelist->index_list ;
	$self->{DATA}->{PACKAGELIST} = $packagelist ;
# 	my $total_size = 0;
# 	foreach (@{$packagelist->get_all})
# 	{
# 		$total_size += $_->compressed_size ;
# 	}
# 	print "TOTAL SIZE: $total_size ko\n";
	## WARNING: DEBUG ONLY
# 	use slackget10::File;
# 	
# 	my $file = new slackget10::File ();
# 	$file->Write("debug/specialfilecontainer_$self->{ROOT}.xml",$self->to_XML) ;
# 	$file->Close;
# 	print "ok\n";
}

=head2 id

Return the id of the SpecialFileContainer object id (like: 'slackware', 'linuxpackages', etc.)

	my $id = $container->id ;

=cut

sub id {
	my $self = shift;
	return $self->{ROOT} ;
}

=head2 to_XML

return a string XML encoded which represent the compilation of PACKAGES, FILELIST, CHECKSUMS constructor parameters.

	my $string = $container->to_XML();

=cut

sub to_XML {
	my $self = shift;
	my $xml = "  <$self->{ROOT}>\n";
# 	print "\t[$self] XMLization of the $self->{DATA}->{PACKAGELIST} packagelist\n";
	$xml .= $self->{DATA}->{PACKAGELIST}->to_XML ;
	$xml .= "  </$self->{ROOT}>\n";
	return $xml;
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

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::SpecialFileContainer
