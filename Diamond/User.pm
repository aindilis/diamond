package Diamond::User;

use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID Username Password MySessions Status Stack ClientAgent /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID});
  $self->Username($args{Username});
  $self->Password($args{Password});
  $self->MySessions
    ($args{Sessions} ||
     PerlLib::Collection->new
     (Type => "Diamond::Session"));
  $self->Status({});
  $self->Stack([]);
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper($self);
}

sub SPrintOneLiner {
  my ($self,%args) = @_;
  return $self->ID.": ".$self->Username;
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
