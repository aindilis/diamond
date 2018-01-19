package Diamond::Lib::Tk::TextSGC;

use Tk::Text;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyText /

  ];

sub init {
  my ($self,%args) = @_;
  return $self->MyText($args{MyMainWindow}->Text(%args));
}

sub Contents {
  my ($self,%args) = @_;
  return $self->MyText->Contents(%args)." howdy";
}

# sub SpellCheck {
#   my ($self,%args) = @_;
#   my $text = $self->MyText->Contents();
#   # open up a new window for this
#   $self->MyText->Toplevel
#     (
#      -title => "Spelling and Grammar Check",
#     );
# }

1;
