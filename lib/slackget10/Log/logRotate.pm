package slackget::Log::logRotate;

use 5.006;
use strict;
use warnings;
use File::Copy;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use slackget::Std ':all';
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

our $VERSION = '0.12';

my $toKo = sub {
	my $i_size = shift;
	my $r_size = $i_size/1024;
	return $r_size;
};

my $toMo = sub {
	my $i_size = shift;
	my $r_size = $i_size/1024;
	$r_size = $r_size / 1024;
	return $r_size;
};

sub new
{
	shift ;
	my @arg= @_ ;
        my $self= {};
	$self->{'LOG_FILE'} = '/var/log/slack-get.log';
	$self->{'SIZE_UNIT'} = 'mo' ;
	$self->{'CRITICAL_SIZE'} = 5;
	$self->{'AUTO_REMOVE'} = undef;
	$self->{'LR_SEND_BY_FTP'} = undef;
	$self->{'LR_SEND_BY_MAIL'} = undef;
	$self->{'LR_MAIL_OPTIONS'} = {
					mailto => $ENV{USER},
					smtp => '127.0.0.1',
					mail_subject => "[slackget::Log] Log rotation",
					mail_from => "slackget-Log\@$ENV{HOSTNAME}"
				};
	$self->{'LR_FTP_OPTIONS'} = {
					'login' => 'anonymous',
					'password' => "$ENV{USER}\@$ENV{HOSTNAME}",
					'server' => '127.0.0.1',
					'passive_mode' => 0,
					'upload_dir' => './'
					};
	$self->{'LR_COPY_TO'} = undef;
	$self->{'_PRIV_NB_LOGED_MSG'} = 0;
	for (my $k=0;$k<=$#arg;$k=$k+2)
	{
		#print "\$arg[$k] : $arg[$k]\n\$arg[$k+1] : $arg[$k+1]\n";
		$self->{"$arg[$k]"} = $arg[$k+1];
	}
	$self->{'NAME'} = 'slackget::Log::logRotate';
	$self->{'VERSION'} = $VERSION;
	bless $self;
	return $self;
}

sub logRotate
{
	my $self = shift;
	my @arg= @_ ;
	for (my $k=0;$k<=$#arg;$k=$k+2)
	{
		#print "\$arg[$k] : $arg[$k]\n\$arg[$k+1] : $arg[$k+1]\n";
		$self->{"$arg[$k]"} = $arg[$k+1];
	}
	if(defined($self->{'CRITICAL_SIZE'}) && $self->{'LOG_FILE'})
	{
		my ($f_size) = (stat($self->{'LOG_FILE'}))[7] ;
		if(defined($self->{'SIZE_UNIT'}))
		{
			if($self->{'SIZE_UNIT'} =~ /^(ko|kb)$/i)
			{
				$f_size = $toKo->($f_size);
			}
			elsif($self->{'SIZE_UNIT'} =~ /^(mo|mb)$/i)
			{
				$f_size = $toMo->($f_size);
			}
		}
		if($f_size >= $self->{'CRITICAL_SIZE'})
		{
			my @time = localtime(time);
			$time[2]--;
			$time[4]++;
			$time[4]="0$time[4]" if (length($time[4] < 2));
			$time[5] += 1900 ;
			if(defined($self->{'LR_COPY_TO'}))
			{
				
				my $dest = $self->{'LR_COPY_TO'}.'/'.$time[3].$time[4].$time[5].$time[2].$time[1].$time[0].'_'.$self->{'LOG_FILE'};
				copy($self->{'LOG_FILE'},$dest);
			}
			if(defined($self->{'LR_SEND_BY_MAIL'}))
			{
				eval "use Mail::Sendmail;";
				if($@)
				{
					die "[ slackget::Log::logRotate ] can't find module Mail::Sendmail, so you can't use the rotation in MAIL mode. Please install Mail::Sendmail (try perl -MCPAN -e 'install Mail::Sendmail') or modify your configuration file.";
				}
				eval "use MIME::QuotedPrint;";
				if($@)
				{
					die "[ slackget::Log::logRotate ] can't find module MIME::QuotedPrint, so you can't use the rotation in MAIL mode. Please install MIME::QuotedPrint (try perl -MCPAN -e 'install MIME::QuotedPrint') or modify your configuration file.";
				}
				eval "use MIME::Base64;";
				if($@)
				{
					die "[ slackget::Log::logRotate ] can't find module MIME::Base64, so you can't use the rotation in MAIL mode. Please install MIME::Base64 (try perl -MCPAN -e 'install MIME::Base64') or modify your configuration file.";
				}
				my %mail = ( 
					To      => $self->{'LR_MAIL_OPTIONS'}{mailto},
					From    => $self->{'LR_MAIL_OPTIONS'}{mail_from},
					Subject => $self->{'LR_MAIL_OPTIONS'}{mail_subject},
					smtp => $self->{'LR_MAIL_OPTIONS'}{smtp},
					'X-Mailer' => "[ slack-get ] slackget::Log::logRotate ver. $VERSION"
					);
				my $boundary = "====" . time() . "====";
				$mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";
				$self->{'LR_MAIL_OPTIONS'}{mailto}=~ /^(.*)@.*$/;
				my $message = Mail::Sendmail::encode_qp( "Hi $1,\n\nThis is slackget::Log module. I have operate a log rotation at $time[2] H $time[1] min on $time[3]/$time[4]/$time[5].\nSee logs in attachement.\n\nAttachement :" );
				open (F, $self->{'LOG_FILE'}) or die "Cannot read $self->{'LOG_FILE'}: $!";
				binmode F; undef $/;
				$mail{body} = MIME::Base64::encode_base64(<F>);
				close F;
				$boundary = '--'.$boundary;
$mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$message
$boundary
Content-Type: application/octet-stream; name="$self->{'LOG_FILE'}"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$self->{'LOG_FILE'}"

$mail{body}
$boundary--
END_OF_BODY
				Mail::Sendmail::sendmail(%mail) or die $Mail::Sendmail::error;
			}
			if(defined($self->{'LR_SEND_BY_FTP'}))
			{
				eval "use Net::FTP;";
				if($@)
				{
					die "[ slackget::Log::logRotate ] can't find module Net::FTP, so you can't use the rotation in FTP mode. Please install Net::FTP (try perl -MCPAN -e 'install Net::FTP') or modify your configuration file.";
				}
				my $ftp = Net::FTP->new( $self->{'LR_FTP_OPTIONS'}{server} , Passive => $self->{'LR_FTP_OPTIONS'}{passive_mode});
				$ftp->login($self->{'LR_FTP_OPTIONS'}{login},$self->{'LR_FTP_OPTIONS'}{password});
				if(defined($self->{'LR_FTP_OPTIONS'}{upload_dir}) && $self->{'LR_FTP_OPTIONS'}{upload_dir} !~ /^$/)
				{
					$ftp->cwd($self->{'LR_FTP_OPTIONS'}{upload_dir})or die "Cannot change working directory ", $ftp->message;
				}
				$ftp->put($self->{LOG_FILE});
				my $dest = $time[3].$time[4].$time[5].$time[2].$time[1].$time[0].'_'.$self->{'LOG_FILE'};
				$ftp->rename($self->{LOG_FILE},$dest);
				$ftp->quit;
			}
			unlink $self->{'LOG_FILE'} if(defined($self->{'AUTO_REMOVE'}));
		}
	}
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

slackget::Log::logRotate - Perl extension for slack-get's log system

=head1 DESCRIPTION

This module is use by slack-get for the log system

=head1 EXPORT

None, it's an Object Oriented module.

This module is really easy to use, it provide an OO interface to contain and process logs data.

There is only 2 methods : new and logRotate.

	my $lo_lr = slackget::Log::logRotate->new(
		SIZE_UNIT => 'mb',
		CRITICAL_SIZE => 5,
		AUTO_REMOVE => 1,
		LR_SEND_BY_FTP => 1,
		LR_SEND_BY_MAIL => 1,
		LR_MAIL_OPTIONS => {
			mailto => $ENV{USER},
			smtp => '127.0.0.1',
			mail_subject => "[slackget::Log] Log rotation",
			mail_from => "slackget-Log\@$ENV{HOSTNAME}"
			},
		LR_FTP_OPTIONS => {
			login => 'anonymous',
			password => "$ENV{USER}\@$ENV{HOSTNAME}",
			server => '127.0.0.1',
			passive_mode => 0,
			upload_dir => './'
			};
		LR_COPY_TO => '/home/backup/logs/slackget/',
		LOG_FILE => $CONF{'log-file'}
	);

	$lo_lr->logRotate;
	
This object is automaticaly instancied by slackget::Log if the use-log-rotation directive is enable.

Options LR_SEND_BY_*, AUTO_REMOVE and LR_COPY_TO can take undef or 1 as values. (undef -> option is disable). You might choose one or more rotation way.

If you choose to modify LR_MAIL_OPTIONS or LR_FTP_OPTIONS you might set all parameters !

=head1 SEE ALSO

slack-get(8), slack-get.conf(5), slack-plugins.conf(5)

http://slackget.infinityperl.org/

=head1 AUTHOR

Arnaud DUPUIS, E<lt>a.dupuis@infinityperl.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Arnaud DUPUIS

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
