package slackget10::Log;

use 5.006;
use strict;
use warnings;
use slackget10::File ;


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use slackget10::Std ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
# 	
# ) ] );
# 
# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
# 
# our @EXPORT = qw(
# 	
# );

our $VERSION = '0.3.6';

sub new
{
	shift ;
	my @arg= @_ ;
        my $self= {};
	$self->{'LOG_FORMAT'} = '[ %d/%m/%y AT %h H %n min %s sec ] <%P> %M' ;
	$self->{'NAME'} = 'slackget10::Log';
	$self->{'VERSION'} = $VERSION;
	$self->{'LOG_FILE'} = '/var/log/slack-get.log';
	$self->{'LOG_LEVEL'} = 1;
	$self->{'LOG_ROTATE'} = undef;
	$self->{'LRO'} = undef;
	$self->{'SIZE_UNIT'} = 'mo' ;
	$self->{'CRITICAL_SIZE'} = 5;
	$self->{'LR_SEND_BY_FTP'} = undef;
	$self->{'LR_SEND_BY_MAIL'} = undef;
	$self->{'LR_COPY_TO'} = undef;
	$self->{'LR_MAIL_OPTIONS'} = undef ;
	$self->{'LR_FTP_OPTIONS'} = undef ;
	$self->{'_PRIV_NB_LOGED_MSG'} = 0;
	for (my $k=0;$k<=$#arg;$k=$k+2)
	{
# 		print "\$arg[$k] : $arg[$k]\n\$arg[$k+1] : $arg[$k+1]\n";
		$self->{"$arg[$k]"} = $arg[$k+1];
	}
	$self->{FILE} = new slackget10::File ($self->{'LOG_FILE'},'file-encoding' => $self->{'FILE_ENCODING'});
	bless $self;
	return $self;
}

sub _getLogLine
{
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon++;
	$mon="0$mon" if(length($mon)<2);
	$hour="0$hour" if(length($hour)<2);
	$min="0$min" if(length($min)<2);
	$sec="0$sec" if(length($sec)<2);
	$year += 1900 ;
	my $line = $self->{'LOG_FORMAT'} ;
	my $NAME = $self->{'NAME'};
	my $VERSION = $self->{'VERSION'};
	#$log_line =~ s/%/$/g;
	$line =~ s/%P/$NAME/g;
	$line =~ s/%V/$VERSION/g;
	$line =~ s/%d/$mday/g;
	$line =~ s/%m/$mon/g;
	$line =~ s/%y/$year/g;
	$line =~ s/%h/$hour/g;
	$line =~ s/%n/$min/g;
	$line =~ s/%s/$sec/g;
	return $line ;
}
sub Log
{
	my ($self,$lvl,$msg) = @_ ;
	my $log_lvl = $self->{'LOG_LEVEL'};
	my $log_file = $self->{'LOG_FILE'};
	if( -e $log_file )
	{
		unless(-w $log_file )
		{
			warn "[ slackget10::Log ] $log_file is not writable";
			return undef;
		}
	}
	if($lvl <= $log_lvl)
	{
		my $ll = $self->_getLogLine() ;
		$ll=~ s/%M/$msg/g ;
		$self->{FILE}->Add($ll);
		$self->{FILE}->Write ;
	}
	if(defined($self->{'LOG_ROTATE'}))
	{
		if($self->{'_PRIV_NB_LOGED_MSG'} >= 10)
		{
			$self->Rotate;
			$self->{'_PRIV_NB_LOGED_MSG'} = 0 ;
		}
		else
		{
			$self->{'_PRIV_NB_LOGED_MSG'}++;
		}
	}
	return 1;
}

sub preview
{
	## function added for slack-gui
	my ($self,$msg) = @_ ;
	my $log_lvl = $self->{'LOG_LEVEL'};
	my $log_file = $self->{'LOG_FILE'};
	my $ll = $self->_getLogLine() ;
	$ll=~ s/%M/$msg/g ;
	return $ll;
}

sub Rotate
{
	my ($self,$lr_obj) = shift;
	my $lro = undef;
	eval "use slackget10::Log::logRotate;";
	if($@)
	{
		warn "[ slackget10::Log ] can't load module slackget10::Log::logRotate.";
		return undef;
	}
	if(defined($lr_obj) && ref $lr_obj eq 'slackget10::Log::logRotate')
	{
		$lro = $lr_obj;
	}
	elsif(defined($self->{'LOG_ROTATE'}) && ref $self->{'LOG_ROTATE'} eq 'slackget10::Log::logRotate')
	{
		$lro = $self->{'LOG_ROTATE'};
	}
	elsif(defined($self->{'LOG_ROTATE'}) && ref $self->{'LOG_ROTATE'} ne 'slackget10::Log::logRotate')
	{
		my %ref = ();
		$ref{'LOG_FILE'} = $self->{'LOG_FILE'} if(defined($self->{'LOG_FILE'}));
		$ref{'SIZE_UNIT'} = $self->{'SIZE_UNIT'} if(defined($self->{'SIZE_UNIT'}));
		$ref{'CRITICAL_SIZE'} = $self->{'CRITICAL_SIZE'} if(defined($self->{'CRITICAL_SIZE'}));
		$ref{'AUTO_REMOVE'} = $self->{'AUTO_REMOVE'} if(defined($self->{'AUTO_REMOVE'}));
		$ref{'LR_SEND_BY_FTP'} = $self->{'LR_SEND_BY_FTP'} if(defined($self->{'LR_SEND_BY_FTP'}));
		$ref{'LR_SEND_BY_MAIL'} = $self->{'LR_SEND_BY_MAIL'} if(defined($self->{'LR_SEND_BY_MAIL'}));
		$ref{'LR_MAIL_OPTIONS'} = $self->{'LR_MAIL_OPTIONS'} if(defined($self->{'LR_MAIL_OPTIONS'})&& defined($self->{'LR_SEND_BY_MAIL'}));
		$ref{'LR_FTP_OPTIONS'} = $self->{'LR_FTP_OPTIONS'} if(defined($self->{'LR_FTP_OPTIONS'}) && defined($self->{'LR_SEND_BY_FTP'}));
		$ref{'LR_COPY_TO'} = $self->{'LR_COPY_TO'} if(defined($self->{'LR_COPY_TO'}));
		$lro = slackget10::Log::logRotate->new( %ref );
	}
	else
	{
		warn "[ slackget10::Log::logRotate() ] I cannot create nor catch a valid instance of slackget10::Log::logRotate.\n";
		return undef;
	}
	$lro->logRotate;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

slackget10::Log - Perl extension for slack-get's log system

=head1 SYNOPSIS

  use slackget10::Log;
  my $lo = slackget10::Log->new(
  	LOG_FILE = '/var/log/slack-get.log'
  	NAME = 'slack-get',
	LOG_LEVEL = 2
  );
  $lo->Log(1,"This is a log message\n");

=head1 DESCRIPTION

This module is use by slack-get for the log system

=head2 EXPORT

None, it's an Object Oriented module.

This module is really easy to use, it provide an OO interface to contain and process logs data.

=head1 CONSTRUCTOR

	my $lo = slackget10::Log->new(
		LOG_FORMAT => $CONF{'log-format'},
		NAME => $NAME,
		VERSION => $VERSION,
		LOG_FILE => $CONF{'log-file'},
		LOG_LEVEL => $CONF{'log-level'}
	);

=head2 new

The constructor take severals options :


     * LOG_FORMAT the log format (read the configuration manpage for more details).


     * NAME the name of the module or binary wich is attach to this slackget10::Log object


     * VERSION version of the module or binary wich is attach to this slackget10::Log object


     * LOG_FILE the file where were loged messages


     * LOG_LEVEL the log level


     * LOG_ROTATE undef disable the log rotation, other value enabled it.


     * CRITICAL_SIZE the maximum size of the log file (if the file is bigger than CRITICAL_SIZE the rotation process is launch).


Moreover, this constructor accept every argument of slackget10::Log::logRotate.

=head1 METHODS


=head2 Log 

Log(LOG_LEVEL, MESSAGE) : write MESSAGE in LOG_FILE if LOG_LEVEL is ge with the constructor's LOG_LEVEL. You can typically read this like : "log MESSAGE if the log level request by the constructor is ge than LOG_LEVEL" 

=cut


=head2 Rotate 

Rotate([a slackget10::Log::logRotate object]) : this method try to catch a valid slackget10::Log::logRotate or create a new one and launch the logRotate routine of this object. You can optionnaly pass the slackget10::Log::logRotate object as an argument. 

=cut


=head2 preview 

preview(MESSAGE) : return a log characters string without write it in LOG_FILE. This method is use by slack-GUI to give a preview of the log format. 

=cut


=head1 SEE ALSO
        
man pages : slack-get(8), slack-get.conf(5), slack-plugins.conf(5)

perldoc : slackget10::Log::logRotate
        
http://slackget.infinityperl.org/

=head1 AUTHOR

Arnaud DUPUIS, E<lt>a.dupuis@infinityperl.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Arnaud DUPUIS

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
