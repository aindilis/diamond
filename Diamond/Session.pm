package Diamond::Session;

use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID Name Command Status Stack ClientAgent /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID});
  $self->Name($args{Name});
  $self->Command($args{Command});
  $self->Status({});
  $self->Stack([]);
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper($self);
}

sub SPrintOneLiner {
  my ($self,%args) = @_;
  return $self->ID.": ".$self->Command;
}

sub Start {
  my ($self,%args) = @_;
  $self->Status->{Started} = 1;
}

sub QueryAgent {
  my ($self,%args) = @_;
  # this involves checking to see whether there is an active session
  # containing  this, what  it is,  and  sending a  message to  that
  # active session, awaiting a response,  and feeding it back to the
  # application
  if (defined $self->ClientAgent) {
    $UNIVERSAL::agent->QueryAgent
      (Agent => $self->ClientAgent,
       Contents => $args{Data});
  }
}

1;
