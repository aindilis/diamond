#!/usr/bin/perl -w

use Diamond::Lib::Tk;

my $mw = Diamond::Lib::Tk->new();

my $frame = $mw->Frame;
my $text = $frame->TextSGC
  (
   -width => 80,
   -height => 25,
  );
$text->Contents
  (
   "hi there",
  );
$text->pack();

$frame->pack();

DiamondMainLoop();
