#!/usr/bin/perl -w

# This is a  sample program that uses Diamond to  query the user.

use BOSS::ICodebase qw(GetDescriptions);
use Diamond;

use Data::Dumper;

$UNIVERSAL::diamond = Diamond->new
  ();

my @applications = split /\n/,`ls /var/lib/myfrdcsa/codebases/internal/`;
my @choices;

my $descriptions = GetDescriptions();

foreach my $application (@applications) {
  printf("%s - %s\n",$application, $descriptions->{$application});
}
