package slackget10::File;

use warnings;
use strict;

=head1 NAME

slackget10::File - A class to manage files.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

slackget10::File is the class which represent a file for slack-get. You can perform all operation on file with this module. 

Access to hard disk are economized by taking a copy of the file in memory, so if you work on big file it may be a bad idea to use this module. Or maybe you have some interest to close the file while you don't work on it.

	use slackget10::File;

	my $file = slackget10::File->new('foo.txt'); # if foo.txt exist the constructor will call the Read() method
	$file->add("an example\n");
	$file->Write();
	$file->Write("bar.txt"); # write foo.txt (plus the addition) into bar.txt
	$file->Close(); # Free the memory !
	$file->Read(); # But the slackget10::File object is not destroy and you can re-load the file content
	$file->Read("baz.txt"); # Or changing file (the object will be update with the new file)

The main advantage of this module is that you don't work directly on the file but on a copy. So you can make errors, they won't be wrote until you call the Write() method

=cut

sub new
{
	my ($class,$file,%args) = @_ ;
	my $self={%args};
# 	print "\nActual file-encoding: $self->{'file-encoding'}\nargs : $args{'file-encoding'}\nFile: $file\n";<STDIN>;
	bless($self,$class);
	$self->{'file-encoding'} = 'utf-8' unless(defined($self->{'file-encoding'}));
# 	print "using $self->{'file-encoding'} as file-encoding\n";<STDIN>;
	$self->{FILENAME} = $file;
	if(defined($file) && -e $file){
		$self->Read();
	}
	else
	{
		$self->{FILE} = [];
	}
	return $self;
}

=head1 CONSTRUCTOR

Take a filename as argument.

	my $file = slackget10::File->new('foo.txt'); # if foo.txt exist the constructor will call the Read() method
	$file->add("an example\n");
	$file->Write();
	$file->Write("bar.txt");

Additionnaly you can pass an file encoding (default is utf8). For example as a European I prefer that files are stored and compile in the iso-8859-1 charset so I use the following :

	my $file = slackget10::File->new('foo.txt','file-encoding' => 'iso-8859-1');

=head1 FUNCTIONS

=head2 Read

Take a filename as argument, and load the file in memory.

	$file->Read($filename);

You can call this method without passing parameters, if you have give a filename to the constructor.

	$file->Read();

This method doesn't return the file, you must call Get_file() to do that.

=cut

sub Read 
{
        my ($self,$file)=@_;
	if($file)
	{
		$self->{FILENAME} = $file ;
	}
	else
	{
		$file = $self->{FILENAME};
	}
        unless ( -e $file or -R $file)
        {
                warn "[ slackget10::File ] unable to read $file : $!\n";
                return undef ;
        }
        my $tmp;
        my @file = ();
        open (F2,"<:encoding($self->{'file-encoding'})",$file);
        while (defined($tmp=<F2>))
        {
                push @file,$tmp;
        }
        close (F2);
	$self->{FILE} = \@file ;
        return 1;

}

=head2 Lock_file

This method lock the file for slack-get application (not really for others...) by creating a file with the name of the current open file plus a ".lock". This is not a protection but an information system for slack-getd sub process. This method return undef if the lock can't be made.

	my $file = new slackget10::File ('test.txt');
	$file->Lock_file ; # create a file test.txt.lock

ATTENTION: You can only lock the current file of the object. With the previous example you can't do :

	$file->Lock_file('toto.txt') ;

ATTENTION 2 : Don't forget to unlock your locked file :)

=cut

sub Lock_file
{
	my $self = shift;
	return undef if $self->is_locked ;
	Write({'file-encoding'=>$self->{'file-encoding'}},"$self->{FILENAME}.lock",$self) or return undef;
	return 1;
}

=head2 Unlock_file

Unlock a locked file. Only the locker object can unlock a file ! Return 1 if all goes well, else return undef. Return 2 if the file was not locked. Return 0 (false in scalar context) if the file was locked but by another slackget10::File object.

	my $status = $file->Unlock_file ;

=cut

sub Unlock_file
{
	my $self = shift;
	if($self->is_locked)
	{
		if($self->_verify_lock_maker)
		{
			unlink "$self->{FILENAME}.lock" or return undef ;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 2;
	}
	return 1;
}

sub _verify_lock_maker
{
	my $self = shift;
	my $file = new slackget10::File ("$self->{FILENAME}.lock");
	my $locker = $file->Get_line(0) ;
	$file->Close ;
	undef($file);
	my $object = ''.$self;
# 	print "[debug file] compare object=$object and locker=$locker\n";
	if($locker eq $object)
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 is_locked

Return 1 if the file is locked by a slackget10::File object, else return undef.

	print "File is locked\n" if($file->is_locked);

=cut

sub is_locked
{
	my $self = shift;
	return 1 if(-e "$self->{FILENAME}.lock");
	return undef;
}

=head2 Write

Take a filename to write data and raw data 

	$file->Write($filename,@data);

You also can cal this method without any parameter :

	$file->Write ;

In this case, the Write() method will wrote data in memory into the last opened file (with Read() or new()).

The default encoding of this method is utf-8, pass an extra arument : file-encoding to the constructor to change that.
=cut

sub Write
{
        my ($self,$name,@data)=@_;
	$name=$self->{FILENAME} unless($name);
	@data = @{$self->{FILE}} unless(@data);
#         if(open (FILE, ">$name"))
# 	print "using $self->{'file-encoding'} as file-encoding for writing\n";
	if(open (FILE, ">:encoding($self->{'file-encoding'})",$name))
        {
                foreach (@data)
                {
                        print FILE $_;
                }
                close (FILE) or return(undef);
        }
        else
        {
                warn "[ slackget10::File ] unable to write '$name' : $!\n";
                return undef;
        }
        return 1;
}

=head2 Add

Take a table of lines and add them to the end of file image (in memory). You need to commit your change by calling the Write() method !

	$file->Add(@data);
	or
	$file->Add($data);
	or
	$file->Add("this is some data\n");

=cut

sub Add {
	my ($self,@data) = @_;
	$self->{FILE} = [@{$self->{FILE}},@data];
}

=head2 Get_file

Return the current file in memory as an array.

	@file = $file->Get_file();

=cut

sub Get_file{
	my $self = shift;
	return @{$self->{FILE}};
}

=head2 Get_line

Return the $index line of the file (the index start at 0).

	@file = $file->Get_line($index);

=cut

sub Get_line {
	my ($self,$index) = @_;
	return $self->{FILE}->[$index];
}

=head2 Get_selection

	Same as get file but return only lines between $start and $stop.

	my @array = $file->Get_selection($start,$stop);

You can ommit the $stop parameter (in this case Get_line() return the lines from $start to the end of file)

=cut

sub Get_selection {
	my ($self,$start,$stop) = @_ ;
	$stop = $#{$self->{FILE}} unless($stop);
	return @{$self->{FILE}}[$start..$stop];
}


=head2 Close

Free the memory. This method close the current file memory image. If you don't call the Write() method before closing, the changes you have made on the file are lost !

	$file->Close();

=cut

sub Close {
	my $self = shift;
	$self->{FILE} = [];
}

=head2 Write_and_close

An alias which call Write() and then Close();

	$file->Write_and_close();
	or
	$file->Write_and_close("foo.txt");

=cut

sub Write_and_close{
	my ($self,$file) = @_;
	$self->Write($file);
	$self->Close();
}

=head2 encoding

Without parameter return the current file encoding, with a parameter set the encoding for the current file.

	print "The current file encoding is ",$file->encoding,"\n"; # return the current encoding
	$file->encoding('utf8'); # set the current file encoding to utf8

=cut

sub encoding
{
	my ($self,$encoding) = @_;
	if(defined($encoding))
	{
		$self->{'file-encoding'} = $encoding ;
	}
	else
	{
		return $self->{'file-encoding'};
	}
}

=head1 AUTHOR

DUPUIS Arnaud, C<< <a.dupuis@infinityperl.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-slackget10-file@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=slackget10>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 DUPUIS Arnaud, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of slackget10::File
