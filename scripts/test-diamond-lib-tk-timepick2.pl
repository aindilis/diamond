#!/usr/bin/perl -w

use Diamond::Lib::Tk::TimePick2;

use Tk;

my $mainwindow = MainWindow->new
  (
   -title => "TimePick2 test",
   -width => 1024,
   -height => 768,
  );

my $frame = $mainwindow->Frame()->pack();
my $tp1 = Diamond::Lib::Tk::TimePick2->new($frame)->pack();

MainLoop();
