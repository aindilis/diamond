#!/usr/bin/perl -w

use Diamond::Lib::Tk::Text::SpellAndGrammarCheck;

use Tk;

my $mw = MainWindow->new
  (
   -title => "test",
  );

my $frame = $mw->Frame();

my $text;
if (1) {
  $text = Diamond::Lib::Tk::Text::SpellAndGrammarCheck->Classinit($frame);
} else {
  $text = $frame->Text
    (
     -width => 80,
     -height => 25,
    );
}

$text->pack();
$frame->pack();

MainLoop();
