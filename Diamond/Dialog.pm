package Diamond::Dialog;

# this is to provide the drop in replacement for certain programs, not
# quite sure yet how this is supposed to work

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(QueryUser ApproveCommand ApproveCommands Approve
	     Choose AChoose Message SubsetSelect);

use UniLang::Agent::Agent;
use UniLang::Util::Message;

use CGI qw/:standard/;
use Data::Dumper;

# A disciplined approach to dialog management with the user.

sub EnsureAgentExists {
  if (! defined $Diamond::Dialog::agent) {
    $Diamond::Dialog::name = "Diamond-Agent-".int(rand(1000000));
    $Diamond::Dialog::agent = UniLang::Agent::Agent->new
      (Name => $Diamond::Dialog::name,
       IdleTimeOut => 10);
    $Diamond::Dialog::agent->Register
      (Host => "localhost",
       Port => "9000");
    # now connect to diamond and create a new session
    my $hash =
      {
       Name => $Diamond::Dialog::name,
       Command => $0,
      };
    my $dump = Dumper($hash);
    # should switch this to a query agent
    $Diamond::Dialog::agent->SendContents
      (Receiver => "Diamond",
       Contents => "session $dump");
    sleep 3; # to prevent it from signing off too quickly
  }
}

sub GenericFunction {
  my %args = @_;
  EnsureAgentExists();
  # my $m = Diamond::Dialog::Message->new
  #   (Function => $args{Function},
  #    Args => $args{Args});
  # $m->SPrint;
  $args{Name} = $Diamond::Dialog::name;
  my $dumper = Dumper(\%args);
  return $Diamond::Dialog::agent->
    QueryAgent
      (Agent => "Diamond",
       Contents => "call $dumper");
}

sub GetInput {
  return GenericFunction(Function => "GetInput", Args => \@_);
}

sub Execute {
  return GenericFunction(Function => "Execute", Args => \@_);
}

sub QueryUser {
  return GenericFunction(Function => "QueryUser", Args => \@_);
}

sub ApproveCommand {
  return GenericFunction(Function => "ApproveCommand", Args => \@_);
}

sub ApproveCommands {
  return GenericFunction(Function => "ApproveCommands", Args => \@_);
}

sub Approve {
  return GenericFunction(Function => "Approve", Args => \@_);
}

sub AChoose {
  return GenericFunction(Function => "AChoose", Args => \@_);
}

sub Choose {
  return GenericFunction(Function => "Choose", Args => \@_);
}

sub Message {
  return GenericFunction(Function => "Message", Args => \@_);
}

sub SubsetSelect {
  return GenericFunction(Function => "SubsetSelect", Args => \@_);
}

1;
