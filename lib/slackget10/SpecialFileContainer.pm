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

Version 1.0.0

=cut

our $VERSION = '1.0.0';

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
	return undef unless(defined($root));
	my $self={};
	$self->{ROOT} = $root;
	unless($args{FILELIST} or $args{PACKAGES} or $args{CHECKSUMS}){
		warn "[slackget10::SpecialFileContainer] Required parameter FILELIST, PACKAGES or CHECKSUMS not found in the contructor\n";
		return undef;
	}
	$self->{DATA}->{config} = $args{config} if(defined($args{config}) && ref($args{config}) eq 'slackget10::Config');
	$self->{DATA}->{FILELIST} = slackget10::SpecialFiles::FILELIST->new($args{FILELIST},$self->{DATA}->{config},$root) or return undef;
	$self->{DATA}->{PACKAGES} = slackget10::SpecialFiles::PACKAGES->new($args{PACKAGES},$self->{DATA}->{config},$root) or return undef;
	$self->{DATA}->{CHECKSUMS} = slackget10::SpecialFiles::CHECKSUMS->new($args{CHECKSUMS},$self->{DATA}->{config},$root) or return undef;
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
	printf("compiling FILELIST...");
	$|++;
	$self->{DATA}->{FILELIST}->compile ;
	print "ok\n";
	printf("compiling PACKAGES...");
	$|++;
	$self->{DATA}->{PACKAGES}->compile ; 
	print "ok\n";
	printf("compiling CHECKSUMS...");
	$|++;
	$self->{DATA}->{CHECKSUMS}->compile ;
	print "ok\n";
	printf("merging data...");
	$|++;
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
	$self->{DATA}->{PACKAGELIST} = $packagelist ;
	## WARNING: DEBUG ONLY
# 	use slackget10::File;
# 	
# 	my $file = new slackget10::File ();
# 	$file->Write("debug/specialfilecontainer_$self->{ROOT}.xml",$self->to_XML) ;
# 	$file->Close;
	print "ok\n";
}

=head2 id

Return the id of the SpecialFileContainer object (like: 'slackware', 'linuxpackages', etc.)

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

1; # End of slackget10::SpecialFileContainer
