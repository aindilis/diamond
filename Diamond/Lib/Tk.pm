package Diamond::Lib::Tk;

use Diamond::Lib::Tk::TextSGC;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (DiamondMainLoop);

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow
    (MainWindow->new(%args));
  if (1) {
    foreach my $item (split /\n/, `ls -1 /usr/lib/perl5/Tk/*.pm`) {
      $item =~ s/^\/usr\/lib\/perl5\/Tk\///;
      $item =~ s/\.pm$//;
      my $subroutinetext = "sub $item {
  my (\$self,\%args) = \@_;
  return \$self->MyMainWindow->$item
    (
     \%args,
    );
}";
      eval $subroutinetext;
    }
  }
}

sub DiamondMainLoop {
  my (%args) = @_;
  return MainLoop(%args);
}

sub TextSGC {
  my ($self,%args) = @_;
  return Diamond::Lib::Tk::TextSGC->new
    (
     MyMainWindow => $self->MyMainWindow,
    );
}

1;

