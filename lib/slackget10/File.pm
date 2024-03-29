package slackget10::File;

use warnings;
use strict;

=head1 NAME

slackget10::File - A class to manage files.

=head1 VERSION

Version 1.0.3

=cut

our $VERSION = '1.0.3';

=head1 SYNOPSIS

slackget10::File is the class which represent a file for slack-get. 

Access to hard disk are saved by taking a copy of the file in memory, so if you work on big file it may be a bad idea to use this module. Or maybe you have some interest to close the file while you don't work on it.

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
	$self->{'file-encoding'} = 'utf8' unless(defined($self->{'file-encoding'}));
	if(defined($file) && -e $file && !defined($args{'load-raw'}))
	{
		$self->{TYPE} = `LC_ALL=C file -b $file | awk '{print \$1}'`;
		chomp $self->{TYPE};
		$self->{TYPE} = 'ASCII' if($self->{TYPE} eq 'empty');
		die "[slackget10::File::constructor] unsupported file type \"$self->{TYPE}\" for file $file. Supported file type are gzip, bzip2, ASCII and XML\n" unless($self->{TYPE} eq 'gzip' || $self->{TYPE} eq 'bzip2' || $self->{TYPE} eq 'ASCII' || $self->{TYPE} eq 'XML' || $self->{TYPE} eq 'Quake') ;
	}
# 	print "using $self->{'file-encoding'} as file-encoding for file $file\n";
	$self->{FILENAME} = $file;
	$self->{MODE} = $args{'mode'} if($args{'mode'} && ($args{'mode'} eq 'write' or $args{'mode'} eq 'append' or $args{'mode'} eq 'rewrite'));
	$self->{MODE} = 'append' if(defined($self->{MODE}) && $self->{MODE} eq 'rewrite');
	$self->{BINARY} = 0;
	$self->{BINARY} = $args{'binary'} if($args{'binary'});
	$self->{SKIP_WL} = $args{'skip-white-line'} if($args{'skip-white-line'});
	$self->{SKIP_WL} = $args{'skip-white-lines'} if($args{'skip-white-lines'});
	$self->{LOAD_RAW} = undef;
	$self->{LOAD_RAW} = $args{'load-raw'} if($args{'load-raw'});
	if(defined($file) && -e $file && !defined($self->{'no-auto-load'})){
		$self->Read();
	}
	else
	{
		$self->{FILE} = [];
	}
	return $self;
}

=head1 CONSTRUCTOR

=head2 new

Take a filename as argument.

	my $file = slackget10::File->new('foo.txt'); # if foo.txt exist the constructor will call the Read() method
	$file->add("an example\n");
	$file->Write();
	$file->Write("bar.txt");

This class try to determine the type of the file via the command `file` (so you need `file` in your path). If the type of the file is not in gzip, bzip2, ASCII or XML the constructor die()-ed. You can avoid that, if you need to work with unsupported file, by passing a "load-raw" parameter.

Additionnaly you can pass an file encoding (default is utf8). For example as a European I prefer that files are stored and compile in the iso-8859-1 charset so I use the following :

	my $file = slackget10::File->new('foo.txt','file-encoding' => 'iso-8859-1');

You can also disabling the auto load of the file by passing a parameter 'no-auto-load' => 1 :

	my $file = slackget10::File->new('foo.txt','file-encoding' => 'iso-8859-1', 'no-auto-load' => 1);

You can also pass an argument "mode" which take 'append or 'write' as value :

	my $file = slackget10::File->new('foo.txt','file-encoding' => 'iso-8859-1', 'mode' => 'rewrite');

This will decide how to open the file (> or >>). Default is 'write' ('>').

Note: for backward compatibility mode => "rewrite" is still accepted as a valid mode. It is an alias for "append"

You can also specify if the file must be open as binary or normal text with the "binary" argument. This one is boolean (0 or 1). The default value is 0 :

	my $file = slackget10::File->new('package.tgz','binary' => 1); # In real usage package.tgz will be read UNCOMPRESSED by Read().
	my $file = slackget10::File->new('foo.txt','file-encoding' => 'iso-8859-1', 'mode' => 'rewrite', binary => 0);

If you want to load a raw file without uncompressing it you can pass the "load-raw" parameter :

	my $file = slackget10::File->new('package.tgz','binary' => 1, 'load-raw' => 1);

=head1 FUNCTIONS

=head2 Read

Take a filename as argument, and load the file in memory.

	$file->Read($filename);

You can call this method without passing parameters, if you have give a filename to the constructor.

	$file->Read();

This method doesn't return the file, you must call Get_file() to do that.

Supported file formats : gzipped, bzipped and ASCII file are natively supported (for compressed formats you need to have gzip and bzip2 installed in your path).

If you specify load-raw => 1 to the constructor, read will load in memory a file even if the format is not recognize.

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
		warn "[slackget10::File] unable to read $file : $!\n";
		return undef ;
	}
	my $tmp;
	my @file = ();
	if(defined($self->{TYPE}) && ($self->{TYPE} eq 'ASCII' || $self->{TYPE} eq 'XML' || $self->{TYPE} eq 'Quake') && !defined($self->{LOAD_RAW}))
	{
# 		print "[DEBUG] [slackget10::File] loading $file as 'plain text' file.";
		if(open (F2,"<:encoding($self->{'file-encoding'})",$file))
		{
			binmode(F2) if($self->{'BINARY'}) ;
			if($self->{SKIP_WL})
			{
				print "[slackget10::File DEBUG] reading and skipping white lines\n";
				while (defined($tmp=<F2>))
				{
					next if($tmp=~ /^\s*$/);
					push @file,$tmp;
				}
			}
			else
			{
				while (defined($tmp=<F2>))
				{
					push @file,$tmp;
				}
			}
			
			close (F2);
			$self->{FILE} = \@file ;
			return 1;
		}
		else
		{
			warn "[slackget10::File] cannot open \"$file\" : $!\n";
			return undef;
		}
	}
	elsif($self->{TYPE} eq 'bzip2' && !defined($self->{LOAD_RAW}))
	{
# 		print "[DEBUG] [slackget10::File] loading $file as 'bzip2' file.";
# 		my $tmp_file = `bzip2 -dc $file`;
		foreach (split(/\n/,`bzip2 -dc $file`))
		{
			push @file, "$_\n";
		}
		$self->{FILE} = \@file ;
		return 1;
	}
	elsif($self->{TYPE} eq 'gzip' && !defined($self->{LOAD_RAW}))
	{
# 		print "[DEBUG] [slackget10::File] loading $file as 'gzip' file.";
# 		my $tmp_file = `gzip -dc $file`;
		foreach (split(/\n/,`gzip -dc $file`))
		{
			push @file, "$_\n";
		}
		$self->{FILE} = \@file ;
		return 1;
	}
	elsif(defined($self->{LOAD_RAW}) or $self->{TYPE} eq '')
	{
# 		print "[DEBUG] [slackget10::File] loading $file as 'raw' file.";
		if(open(F2,$file))
		{
			binmode(F2) if($self->{'BINARY'}) ;
			while (defined($tmp=<F2>))
			{
				push @file,$tmp;
			}
			close (F2);
			$self->{FILE} = \@file ;
			return 1;
		}
		else
		{
			warn "[slackget10::File] cannot (raw) open \"$file\" : $!\n";
			return undef;
		}
	}
	else
	{
		die "[slackget10::File] Read() method cannot load file \"$file\" in memory : \"$self->{TYPE}\" is an unsupported format.\n";
	}

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
# 	print "\t[DEBUG] ( slackget10::File in Lock_file() ) locking file $self->{FILENAME} for $self\n";
	Write({'file-encoding'=>$self->{'file-encoding'}},"$self->{FILENAME}.lock",$self) or return undef;
	return 1;
}

=head2 Unlock_file

Unlock a locked file. Only the locker object can unlock a file ! Return 1 if all goes well, else return undef. Return 2 if the file was not locked. Return 0 (false in scalar context) if the file was locked but by another slackget10::File object.

	my $status = $file->Unlock_file ;

Returned value are :

	0 : error -> the file was locked by another instance of this class
	
	1 : ok lock removed
	
	2 : the file was not locked
	
	undef : unable to remove the lock.

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
# 		print "\t[DEBUG] ( slackget10::File in Unlock_file() ) $self->{FILENAME} is not lock\n";
		return 2;
	}
	return 1;
}

sub _verify_lock_maker
{
	my $self = shift;
	my $file = new slackget10::File ("$self->{FILENAME}.lock");
	my $locker = $file->Get_line(0) ;
# 	print "\t[DEBUG] ( slackget10::File in _verify_lock_maker() ) locker of file \"$self->{FILENAME}\" is $locker and current object is $self\n";
	$file->Close ;
	undef($file);
	my $object = ''.$self;
# 	print "[debug file] compare object=$object and locker=$locker\n";
	if($locker eq $object)
	{
# 		print "\t[DEBUG] ( slackget10::File in _verify_lock_maker() ) locker access granted for file \"$self->{FILENAME}\"\n";
		return 1;
	}
	else
	{
# 		print "\t[DEBUG] ( slackget10::File in _verify_lock_maker() ) locker access ungranted for file \"$self->{FILENAME}\"\n";
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
	return 1 if(-e $self->{FILENAME}.".lock");
	return undef;
}

=head2 Write

Take a filename to write data and raw data 

	$file->Write($filename,@data);

You can call this method with just a filename (in this case the file currently loaded will be wrote in the file you specify)

	$file->Write($another_filename) ; # Write the currently loaded file into $another_filename

You also can call this method without any parameter :

	$file->Write ;

In this case, the Write() method will wrote data in memory into the last opened file (with Read() or new()).

The default encoding of this method is utf-8, pass an extra argument : file-encoding to the constructor to change that.

=cut

sub Write
{
        my ($self,$name,@data)=@_;
	$name=$self->{FILENAME} unless($name);
	@data = @{$self->{FILE}} unless(@data);
#         if(open (FILE, ">$name"))
# 	print "using $self->{'file-encoding'} as file-encoding for writing\n";
	 my $mode = '>';
	if(defined($self->{MODE}) && $self->{MODE} eq 'append')
	{
		$mode = '>>';
	}
	if(open (FILE, "$mode:encoding($self->{'file-encoding'})",$name))
	{
		binmode(FILE) if($self->{'BINARY'}) ;
		# NOTE: In the case you need to clear the white line of your file, their will be a if() test no each array slot
		# This is really time consumming, so id you don't need this feature we just test once for all and gain a lot in performance.
		if($self->{SKIP_WL})
		{
			print "[slackget10::File DEBUG] mode 'skip-white-line' activate\n";
			foreach (@data)
			{
				foreach my $tmp (split(/\n/,$_))
				{
					next if($tmp =~ /^\s*$/) ;
					print FILE "$tmp\n" ;
				}
			}
		}
		else
		{
			foreach (@data)
			{
				print FILE $_;
			}
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
	$start = 0 unless($start);
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
	return $_[1] ? $_[0]->{'file-encoding'}=$_[1] : $_[0]->{'file-encoding'};
# 	Idem au code suivant (qui est vachement plus clair mais aussi beeeeaaaaauuuucoup plus long), on economise ici 2 variables locales : meilleurs perf.
# 	my ($self,$encoding) = @_;
# 	if(defined($encoding))
# 	{
# 		$self->{'file-encoding'} = $encoding ;
# 	}
# 	else
# 	{
# 		return $self->{'file-encoding'};
# 	}
}

=head2 filename

Return the filename of the file which is currently process by the slackget10::File instance.

	print $file->filename

=cut

sub filename
{
	return $_[0]->{FILENAME} ;
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

1; # End of slackget10::File
