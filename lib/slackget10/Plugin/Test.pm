package slackget10::Plugin::Test ;

sub new
{
	my $ref = shift;
	my $self = {};
	bless($self,$ref);
	return $self;
}

# my $HOOKS = ['HOOK_COMMAND_LINE_OPTIONS','HOOK_COMMAND_LINE_HELP','HOOK_START_DAEMON','HOOK_RESTART_DAEMON','HOOK_STOP_DAEMON']

sub hook_command_line_options
{
	my $self = shift;
	return ("test=s"=>\$self->{var}->{test}) ;
}

sub hook_command_line_help
{
	return ('test=s'=>'test for passing one string to var');
}

1;