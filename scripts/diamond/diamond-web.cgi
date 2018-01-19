#!/usr/bin/perl -w

# this is a diamond cgi script, it starts a diamond agent and then
# prints whatever is sent to it

use Diamond::Target::CGI;
use UniLang::Agent::Agent;
use UniLang::Util::Message;

use CGI;

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Diamond",
   ReceiveHandler => \&Receive);

$UNIVERSAL::agent->DoNotDaemonize(1);
$UNIVERSAL::agent->Register(Host => "localhost",
			    Port => "9000");

my $cgi = CGI->new;

print $cgi->header; # DiamondHeader;

while (1) {
  $UNIVERSAL::agent->Listen(TimeOut => 20);
}

sub Receive {
  my %args = @_;
  $command = $args{Message}->Contents;
  print $command;
}
