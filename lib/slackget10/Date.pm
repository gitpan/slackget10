package slackget10::Date;

use warnings;
use strict;

=head1 NAME

slackget10::Date - A class to manage date for slack-get.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

This class is an abstraction of a date. It centralyze all operation you can do on a date (like comparisons)

    use slackget10::Date;

    my $date = slackget10::Date->new('day-name' => Mon, 'day-number' => 5, 'year' => 2005);
    $date->year ;
    my $status = $date->compare($another_date_object);
    if($date->is_equal($another_date_object))
    {
    	print "Nothing to do : date are the same\n";
    }

=head1 CONSTRUCTOR

The constructor new() take the followings arguments :

	day-name => the day name in : Mon, Tue, Wed, Thu, Fri, Sat, Sun
	day-number => the day number from 1 to 31. WARNINGS : there is no verification about the date validity !
	month-name  => the month name (Jan, Feb, Apr, etc.)
	month-number => the month number (1 to 12)
	hour => the hour ( a string like : 12:52:00). The separator MUST BE ':'
	year => a chicken name...no it's a joke the year (ex: 2005).
	use-approximation => in this case the comparisons method just compare the followings : day, month and year. (default: no)

You have to manage by yourself the date validity, because this class doesn't check the date validity. The main reason of this, is that this class is use to compare the date of specials files. 

So I use the predicate that peoples which make thoses files don't try to do a joke by a false date.

	my $date = slackget10::Date->new(
		'day-name' => Mon, 
		'day-number' => 5, 
		'year' => 2005,
		'month-number' => 2,
		'hour' => '12:02:35',
		'use-approximation' => undef
	);

=cut

my %equiv_month = (
	'Non' => 0,
	'Jan' => 1,
	'Feb' => 2,
	'Mar' => 3,
	'Apr' => 4,
	'May' => 5,
	'Jun' => 6,
	'Jul' => 7,
	'Aug' => 8,
	'Sep' => 9,
	'Oct' => 10,
	'Nov' => 11,
	'Dec' => 12,
);

sub new
{
	my ($class,%args) = @_ ;
	my $self={};
	bless($self,$class);
	$self->{DATE}->{'day-name'} = $args{'day-name'} if(defined($args{'day-name'})) ;
	$self->{DATE}->{'day-number'} = $args{'day-number'} if(defined($args{'day-number'})) ;
	$self->{DATE}->{'month-name'} = $args{'month-name'} if(defined($args{'month-name'})) ;
	$self->{DATE}->{'month-number'} = $args{'month-number'} if(defined($args{'month-number'})) ;
	$self->{DATE}->{'hour'} = $args{'hour'} if(defined($args{'hour'})) ;
	$self->{DATE}->{'year'} = $args{'year'} if(defined($args{'year'})) ;
	$self->{'use-approximation'} = $args{'use-approximation'};
	$self->_fill_undef;
	return $self;
}


=head1 FUNCTIONS

=head2 compare

This mathod compare the current date object with a date object passed as parameter.

	my $status = $date->compare($another_date);

The returned status is :

	0 : $another_date is equal to $date
	1 : $date is greater than $another_date
	2 : $date is lesser than $another_date

=cut

sub compare {
	my ($self,$date) = @_;
	return undef if(ref($date) ne 'slackget10::Date') ;
	if($self->year > $date->year){
		return 1
	}
	elsif($self->year < $date->year){
		return 2
	}
	elsif($self->monthnumber > $date->monthnumber){
		return 1
	}
	elsif($self->monthnumber < $date->monthnumber){
		return 2
	}
	elsif($self->daynumber > $date->daynumber){
		return 1
	}
	elsif($self->daynumber < $date->daynumber){
		return 2
	}
	elsif(!$self->{'use-approximation'}){
		return 0 unless($self->hour);
		return 0 unless($date->hour);
		my @hour_self = $self->hour =~ /^(\d+):(\d+):(\d+)$/g ;
		my @hour_date = $date->hour =~ /^(\d+):(\d+):(\d+)$/g ;
		if($hour_self[0] > $hour_date[0])
		{
			return 1;
		}
		elsif($hour_self[0] < $hour_date[0])
		{
			return 2;
		}
		elsif($hour_self[1] > $hour_date[1])
		{
			return 1;
		}
		elsif($hour_self[1] < $hour_date[1])
		{
			return 2;
		}
		elsif($hour_self[2] > $hour_date[2])
		{
			return 1;
		}
		elsif($hour_self[2] < $hour_date[2])
		{
			return 2;
		}
		
	}
	return 0;
}

=head2 is_equal

Take another date object as parameter and return TRYUE (1) if this two date object are equal (if compare() return 0), and else return false (0).

	if($date->is_equal($another_date)){
		...do smoething...
	}

WARNING : this method also return undef if $another_date is not a slackget10::Date object, so be carefull.

=cut

sub is_equal {
	my ($self,$date) = @_;
	return undef if(ref($date) ne 'slackget10::Date') ;
	if($self->compare($date) == 0){
		return 1;
	}
	else{
		return 0;
	}
}

=head2 _fill_undef [PRIVATE]

This method is call by the constructor to resolve the month equivalence (name/number).

This method affect 0 to all undefined numerical values.

=cut

sub _fill_undef {
	my $self = shift;
	unless(defined($self->{DATE}->{'month-number'})){
		if(defined($self->{DATE}->{'month-name'}) && exists($equiv_month{$self->{DATE}->{'month-name'}}))
		{
			$self->{DATE}->{'month-number'} = $equiv_month{$self->{DATE}->{'month-name'}};
		}
		else{
			$self->{DATE}->{'month-number'} = 0;
		}
	}
	$self->{DATE}->{'day-number'} = 0 unless(defined($self->{DATE}->{'day-number'}));
	$self->{DATE}->{'year'} = 0 unless(defined($self->{DATE}->{'year'}));
}

=head2 to_XML

return the date as an XML encoded string.

	$xml = $date->to_XML();

=cut

sub to_XML
{
	my $self = shift;
	my $xml = "<date ";
	foreach (keys(%{$self->{DATE}})){
		$xml .= "$_=\"$self->{DATE}->{$_}\" " if(defined($self->{DATE}->{$_}));
	}
	$xml .= "/>\n";
	return $xml;
}
=head1 ACCESSORS

=cut

=head2 year

return the year

	my $string = $date->year;

=cut

sub year {
	my $self = shift;
	return $self->{DATE}->{'year'};
}

=head2 monthname

return the monthname

	my $string = $date->monthname;

=cut

sub monthname {
	my $self = shift;
	return $self->{DATE}->{'month-name'};
}

=head2 dayname

return the 'day-name'

	my $string = $date->'day-name';

=cut

sub dayname {
	my $self = shift;
	return $self->{DATE}->{'day-name'};
}

=head2 hour

return the hour

	my $string = $date->hour;

=cut

sub hour {
	my $self = shift;
	return $self->{DATE}->{'hour'};
}

=head2 daynumber

return the daynumber

	my $string = $date->daynumber;

=cut

sub daynumber {
	my $self = shift;
	return $self->{DATE}->{'day-number'};
}

=head2 monthnumber

return the monthnumber

	my $string = $date->monthnumber;

=cut

sub monthnumber {
	my $self = shift;
	return $self->{DATE}->{'month-number'};
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

1; # End of slackget10::Date
