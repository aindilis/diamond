package Diamond;

# The user goes to the diamond website with a special authorization or
# whatever to initiate the program.

use BOSS::Config;
use Diamond::Session;
use Diamond::User;
use MyFRDCSA;
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config MySessions MyUsers / ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-t			Test

	-w			Require user input before exiting

	-u [<host> <port>]	Run as a UniLang agent
";

  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"diamond");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MySessions
    ($args{Sessions} ||
     PerlLib::Collection->new
     (Type => "Diamond::Session",
      StorageFile => "$UNIVERSAL::systemdir/data/.sessions"));
  # $self->MySessions->Load;  #   shouldn't  do  this   because,  well
  # sessions are terminated when server stops, right?
  $self->MySessions->Contents({});
  $self->MyUsers
    ($args{Users} ||
     PerlLib::Collection->new
     (Type => "Diamond::User",
      StorageFile => "$UNIVERSAL::systemdir/data/.users"));
  $self->MyUsers->Contents({});
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-t'}) {

  }
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub Process {
  my ($self,%args) = @_;
  my $c = $args{Command} || $args{Message}->Contents;
  print "$c\n";
  if ($c =~ /^(quit|exit)$/i) {
    $self->DESTROY;
    exit(0);
  } elsif ($c =~ /^session (.+)$/s) {
    # create a new session for a new program
    my $e = $1;
    my $nargs = eval $e;
    my $session = Diamond::Session->new
      (ID => $nargs->{Name},
       %$nargs);
    print Dumper($session);
    $self->MySessions->Add
      ($session->ID => $session);
  } elsif ($c =~ /^user (.+)$/s) {
    # create a new session for a new program
    my $e = $1;
    my $nargs = eval $e;
    my $user = Diamond::User->new
      (ID => $self->MyUsers->Count,
       %$nargs);
    print Dumper($user);
    $self->MyUsers->Add
      ($user->ID => $user);
    # Just assume it is authenticated here. Also, in the future, check
    # for any other user with the same credentials
    $UNIVERSAL::agent->Reply
      (Message => $args{Message},
       Contents => 1);
    $UNIVERSAL::agent->Restart;
  } elsif ($c =~ /^list-sessions(.*)$/) {
    sleep 3;
    my $dumper;
    my $extra = $1;
    if ($extra =~ /^ (.+)$/) {
      # now we have a username, so list the sessions belonging to that user
      $username = $1;
      my @ret;
      my @values = $self->MyUsers->Contents->{$username}->MySessions->Values;
    }
    my @values2 = @values;
    if (! @values) {
      @values2 = $self->MySessions->Values;
    }
    my @ret;
    foreach my $value (@values2) {
      push @ret, $value->SPrintOneLiner;
    }
    $dumper = Dumper(\@ret);
    # list sessions
    print $dumper;
    $UNIVERSAL::agent->Reply
      (Message => $args{Message},
       Contents => $dumper);
    $UNIVERSAL::agent->Restart;
  } elsif ($c =~ /^list-users$/) {
    sleep 3;
    # list sessions
    my @ret;
    foreach my $value ($self->MyUsers->Values) {
      push @ret, $value->SPrintOneLiner;
    }
    my $dumper = Dumper(\@ret);
    print $dumper;
    $UNIVERSAL::agent->Reply
      (Message => $args{Message},
       Contents => $dumper);
    $UNIVERSAL::agent->Restart;
  } elsif ($c =~ /^remove(.*)$/) {
    # list sessions
    my $sessions = $1;
    foreach my $session (split /\s/,$sessions) {
      if (exists $self->MySessions->Contents->{$session}) {
	my $toremove = $self->MySessions->Contents->{$session};
	$self->MySessions->Subtract
	  ($toremove->ID => $toremove);
      }
    }
  } elsif ($c =~ /^call (.+)$/s) {
    # call this function, most likely
    my $e = $1;
    my $nargs = eval($e);
    if (exists $self->MySessions->Contents->{$nargs->{Name}}) {
      print "Pushing Command for Agent ".$nargs->{Name}."\n";
      my $tocall = $self->MySessions->Contents->{$nargs->{Name}};
      push @{$tocall->Stack}, \%nargs;
      # there is  nothing we  can at this  point now until  the client
      # connects  to view  this,  at which  point  we send  it to  the
      # client, who then initiates a call back after a submit
    }
  }
}

sub DESTROY {
  my ($self,%args) = @_;
  $UNIVERSAL::agent->Deregister;
}

1;
