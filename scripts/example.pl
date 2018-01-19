#!/usr/bin/perl -w

# example script to use drop in Manager::Dialog replacement

use Diamond::Dialog qw(QueryUser Message);

my $username = QueryUser("Who are you?");
Message(Message => "You are $username.");
