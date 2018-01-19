package Diamond::Target::CGI::Diamond;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(QueryUser ApproveCommand ApproveCommands Approve
	     Choose Message SubsetSelect);

# A disciplined approach to dialog management with the user.

sub GetInput {
  my $result = <STDIN>;
  if ($args{Regex}) {
    while ($result =~ $args{Regex}) {
      $result = <STDIN>;
    }
  } else {
    while ($result =~ /^$/) {
      $result = <STDIN>;
    }
  }
  if (! defined $args{Chomped} or $args{Chomped} == 0) {
    chomp $result;
  }
  return $result;
}

sub Execute {
  my $command = shift;
  system $command;
}

sub QueryUser {
  # a message with a text input
  my ($contents) = (shift || "");
  Message(Message => "$contents>");
  return GetInput();
}

sub ApproveCommand {
  my $command = shift;
  Message(Message => "$command\n");
  if (Approve("Execute this command? ")) {
    Execute($command);
    return 1;
  }
  return;
}

sub ApproveCommands {
  my %args = @_;
  if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
    foreach $command (@{$args{Commands}}) {
      Message(Message => $command);
    }
    # bug: use proof theoretic fail conditions here instead
    if (Approve("Execute these commands? ")) {
      foreach my $command (@{$args{Commands}}) {
	Execute($command);
      }
      return 1;
    } else {
      return 0;
    }
  } else {
    my $outcome = 0;
    foreach $command (@{$args{Commands}}) {
      if (ApproveCommand($command)) {
	++$outcome;
      }
    }
    return $outcome;
  }
}

sub Approve {
  # a message with a choose
  my $message = shift || "Is this correct? ([yY]|[nN])\n";
  $message =~ s/((\?)?)[\s]*$/$1: /;
  Message(Message => $message);
  my $antwort = GetInput();
  chomp $antwort;
  if ($antwort =~ /^[yY]([eE][sS])?$/) {
    return 1;
  }
  return 0;
}

sub Choose {
  # going to be a radio
  my @list = @_;
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    Message(Message => "<Chose:".$list[0].">");
    return $list[0];
  } else {
    foreach my $item (@list) {
      Message(Message => "$i) $item");
      ++$i;
    }
    my $response = GetInput
      (Regex => qr/^\d+$/,
       Chomped => 1);
    return $list[$response];
  }
}

sub Message {
  # just a print
  my %args = @_;
  chomp $args{Message};
  if (defined $args{Terminated} and $args{Terminated} == 0) {
    print $args{Message}."\n";
  } else {
    print $args{Message}."\n";
  }
}

sub SubsetSelect {
  # going to be a series of checkboxes
  my (%args) = (@_);
  my @options = @{$args{Set}};
  my %selection = ();
  if ($args{Selection}) {
    %selection = %{$args{Selection}};
  }
  my $type = $args{Type};
  my $prompt = $args{Prompt} || "> ";
  unshift @options, "Finished";
  if (scalar @options > 0) {
    while (1) {
      my $i = $args{MenuOffset} || 0;
      foreach my $option (@options) {
	chomp $option;
	if (defined $selection{$options[$i]}) {
	  Message
	    (Message => "* ",
	     Terminated => 0);
	} else {
	  Message
	    (Message => "  ",
	     Terminated => 0);
	}
	Message(Message => "$i) ".$option);
	$i = $i + 1;
      }
      print $prompt;
      my $ans = GetInput();
      if ($ans ne "") {
	if ($ans) {
	  # go ahead and parse the language
	  foreach my $a (split /\s*,\s*/, $ans) {
	    my $method = "toggle";
	    if ($a =~ /^s(.*)/) {
	      $a = $1;
	      $method = "select";
	    } elsif ($a =~ /^d(.*)/) {
	      $a = $1;
	      $method = "deselect";
	    }
	    my $start = $a;
	    my $end = $a;
	    if ($a =~ /^\s*(\d+)\s*-\s*(\d+)\s*$/) {
	      $start = $1;
	      $end = $2;
	    }
	    for (my $i = $start; $i <= $end; ++$i) {
	      Message(Message => "($i)");
	      if ($method eq "toggle") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		} else {
		  $selection{$options[$i]} = 1;
		}
	      } elsif ($method eq "deselect") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		}
	      } elsif ($method eq "select") {
		$selection{$options[$i]} = 1;
	      }
	    }
	  }
	} else {
	  if (defined $type and $type eq "int") {
	    my @retvals;
	    my $i = $args{MenuOffset} || 0;
	    foreach my $option (@options) {
	      if ($selection{$option}) {
		push @retvals, $i - 1;
	      }
	      ++$i;
	    }
	    return @retvals;
	  } else {
	    return keys %selection;
	  }
	}
      }
    }
  } else {
    return;
  }
}

1;
