package Diamond::SessionManager;

use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Sessions /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Sessions
    ($args{Sessions} ||
     PerlLib::Collection->new
     ());
}

sub ProcessCGI {
  my ($self,%args) = @_;
}

1;
