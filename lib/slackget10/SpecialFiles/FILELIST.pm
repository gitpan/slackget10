package slackget10::SpecialFiles::FILELIST;

use warnings;
use strict;

use slackget10::File;
use slackget10::Date;
use slackget10::Package;

=head1 NAME

slackget10::SpecialFiles::FILELIST - An interface for the special file FILELIST.TXT

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class contain all methods for the treatment of the FILELIST.TXT file

    use slackget10::SpecialFiles::FILELIST;

    my $spec_file = slackget10::SpecialFiles::FILELIST->new('FILELIST.TXT');
    $spec_file->compil();
    my $ref = $spec_file->get_file_list() ;

This class care about package-namespace, which is the root set of a package (slackware, extra or pasture for packages from Slackware)

=head1 WARNINGS

All classes from the slackget10::SpecialFiles:: namespace need the followings methods :

	- a contructor new()
	- a method compil()
	- a method get_result(), which one can be an alias on another method of the class.

Moreover, the get_result() methode need to return a hashref. Keys of this hashref are the filenames.

Classes from ths namespace represent an abstraction of the special file they can manage so informations stored in the returned hashref must have a direct link with this special file.

=head1 CONSTUSTOR

The constructor take only one argument : the file FILELIST.TXT with his all path.

	my $spec_chk = slackget10::SpecialFiles::CHECKSUMS->new('/home/packages/FILELIST.TXT');

The constructor return undef if the file does not exist.

=cut

sub new
{
	my ($class,$file,$root) = @_ ;
	my $self={};
	$self->{ROOT} = $root;
	return undef unless(defined($file) && -e $file);
	print "Loading $file as FILELIST\n";
	$self->{FILE} = new slackget10::File ($file);
	$self->{DATA} = {};
	bless($self,$class);
	return $self;
}

=head1 FUNCTIONS

=head2 compile

This method take no arguments, and extract the list of couple (file/package-namespace). Those couple are store into an internal data structure.

	$list->compile();

=cut

sub compile {
	my $self = shift;
	if($self->{FILE}->Get_line(0)=~ /(\w+) (\w+)  (\d+) ([\d:]+) \w+ (\d+)/)  # match a date like : Tue Apr  5 12:56:29 PDT 2005
	{
		$self->{METADATA}->{date} = new slackget10::Date (
			'day-name' => $1,
			'day-number' => $3,
			'month' => $2,
			'hour' => $4,
			'year' => $6
			
		);
	}
	foreach ($self->{FILE}->Get_file()){
		next if($_=~ /\.asc$/);
		if($_=~/(\d+)-(\d+)-(\d+)\s+(\d+):(\d+)\s+\.\/(.*)\/([^\/\s\n]*)\.tgz$/i){
			next if ($6=~ /source\//);
			$self->{DATA}->{$7} = new slackget10::Package ($7);
			$self->{DATA}->{$7}->setValue('package-source',$self->{ROOT}) if($self->{ROOT});
			$self->{DATA}->{$7}->setValue('package-path',$6);
# 			$self->{DATA}->{$7}->{'package-path'} = $6;
			$self->{DATA}->{$7}->setValue('package-date',new slackget10::Date (
				'year' => $1,
				'month-number' => $2,
				'day-number' => $3,
				'hour' => "$4:$5:00"
			));
# 			$self->{DATA}->{$7}->{'package-date'} = new slackget10::Date (
# 				'year' => $1,
# 				'month-number' => $2,
# 				'day-number' => $3,
# 				'hour' => "$4:$5:00"
# 			);
		}
		elsif($_=~/(.*)\.tgz$/i){
			print "Skipping $1 even if it's a .tgz\n";
		}
	}
	$self->{FILE}->Close();
}

=head2 get_file_list

Return a hashref build on this model 

	$ref = {
		filename => package-namespace
	}

Where filename is a full name, and package-namespace is one of the : slackware, extra, pasture

	my $ref = $list->get_file_list() ;

=cut

sub get_file_list {
	my $self = shift;
	return $self->{DATA} ;
}

=head2 get_package

Return informations relative to a packages as a hashref.

	my $hashref = $list->get_package($package_name) ;

=cut

sub get_package {
	my ($self,$pack_name) = @_ ;
	return $self->{DATA}->{$pack_name} ;
}

=head2 get_result

Alias for get_file_list().

=cut

sub get_result {
	my $self = shift;
	return $self->get_file_list();
}

=head2 get_date

return a slackget10::Date object, which is the date of the FILELIST.TXT

	my $date = $list->get_date ;

=cut

sub get_date {
	my $self = shift;
	return $self->{METADATA}->{date} ;
}

=head2 to_XML

return a string containing all packages name carriage return separated.

WARNING: ONLY FOR DEBUG

	my $string = $spec_file->to_string();

=cut

sub to_XML {
	my $self = shift;
	my $xml = "<filelist>\n";
	foreach (keys(%{$self->{DATA}})){
		$xml .= "\t<package id=\"$_\">\n";
		$xml .= "\t\t<package-path>$self->{DATA}->{$_}->{'package-path'}</package-path>\n" if($self->{DATA}->{$_}->{'package-path'});
		$xml.= "\t\t".$self->{DATA}->{$_}->{'package-date'}->to_XML ;
# 		foreach my $key (keys(%{$self->{DATA}->{$_}})) {
# 			$xml .= "\t\t<$key>$self->{DATA}->{$_}->{$key}</$key>\n";
# 		}
		$xml .= "\t</package>\n";
	}
	$xml .= "</filelist>\n";
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

1; # End of slackget10::SpecialFiles::FILELIST
