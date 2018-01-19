package Diamond::Target::CGI::Demo;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config / ];

sub init {
  my ($self,%args) = @_;
}

sub Execute {
  my ($self,%args) = @_;
}

1;
