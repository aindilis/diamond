package Diamond::Admin;

# this is an example program that uses diamond

use Diamond::Dialog qw(Message QueryUser SubsetSelect);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySessions Username Password /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Login;
}

sub Login {
  my ($self,%args) = @_;
  my $username = QueryUser("Username?");
  my $password = QueryUser("Password?");
}

sub LogOut {
  my ($self,%args) = @_;
}

sub List {
  my ($self,%args) = @_;
  $self->Process
    (Command => "list");
}

sub Add {
  my ($self,%args) = @_;
  my $name = QueryUser("Session Name?");
  my $command = QueryUser("Command?");
  $self->Process
    (Command => "add $name $command");
}

sub Remove {
  my ($self,%args) = @_;
  Message(Message => "Session Names?");
  my @sessions = SubsetSelect();
  $self->Process
    (Command => "remove $name");
}

1;
