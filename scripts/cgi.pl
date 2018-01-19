#!/usr/bin/perl -w

# this is a diamond cgi script, it starts a diamond agent and then
# prints whatever is sent to it

use UniLang::Agent::Agent;
use UniLang::Util::Message;

use CGI;

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Diamond",
   ReceiveHandler => \&Receive);

$UNIVERSAL::agent->Register;

sub Receive {
  my %args = @_;
  $command = $args{Message}->Contents;
  print $command;
}

my $cgi = CGI->new;
print $cgi->header;

print "Diamond, running\n";

while (1) {
  $UNIVERSAL::agent->Listen;
}



#!/usr/bin/perl -w

push @INC, "/usr/local/share/perl/5.8.3/";

use BOSS::ICodebase qw(GetDescriptions);
use Diamond::Target::CGI;
use Diamond::User;
use UniLang::Agent::Agent;
use UniLang::Util::Message;

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Diamond-CGI",
   ReceiveHandler => \&Receive);

sub Receive {
  my %args = @_;
  $message = $args{Message};
}

use CGI qw/:standard/;
use Data::Dumper;

$query = new CGI;
print DiamondHeader;

# DEAL WITH FORMS

foreach my $parameter (qw(USERNAME PASSWORD)) {
  if ($query->{$parameter}) {
    print "<input type='hidden' name='$parameter' value='".$query->{parameter}."'><br>\n";
    $$parameter = $query->{$parameter}->[0];
    print "Adding $parameter<br>\n";
  }
}

if (! scalar @{$query->{".parameters"}}) {
  QueryUser("Username");
} elsif (! $USERNAME) {
  $USERNAME = $query->{trtext}->[0];
  QueryUser("Password");
  print "<input type='hidden' name='USERNAME' value='$USERNAME'><br>\n";
} elsif ($USERNAME and ! $PASSWORD) {			# select a function
  $PASSWORD = $query->{trtext}->[0];
  print "<input type='hidden' name='PASSWORD' value='$PASSWORD'><br>\n";
  # check authentication

  # register the agent
  $UNIVERSAL::agent->Register
    (Host => "localhost",
     Port => "9000");
  sleep 3;
  my $credentials = {
		     USERNAME => $USERNAME,
		     PASSWORD => $PASSWORD,
		    };
  my $dumper = Dumper($credentials);
  print $dumper;
  my $res = $UNIVERSAL::agent->QueryAgent
    (Agent => "Diamond",
     Contents => "user $dumper");
  if ($res) {
    print "Welcome $USERNAME<br>\n";
    # now we give them the choice of their open sessions
    # shouldn't we create a new user here?
    my $retval = $UNIVERSAL::agent->QueryAgent
      (Agent => "Diamond",
       Contents => "list-sessions $USERNAME");
    my $list = eval $retval;
    SubsetSelect
      (Message => "Please select an active session",
       AllowHTML => 1,
       Set => $list);
  }
  $UNIVERSAL::agent->Deregister;
} else {
  # elsif ($query->{""}) {
  print Dumper($query);
  if ($query->{selection}) {
    my @applications = split /\n/,`ls /var/lib/myfrdcsa/codebases/internal/`;
    foreach my $i (@{$query->{selection}}) {
      print $applications[$i]."<br>\n";
    }
  }
}
