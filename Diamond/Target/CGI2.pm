package Diamond::Target::CGI2;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(QueryUser ApproveCommand ApproveCommands Approve
	     Choose AChoose Message SubsetSelect);

use CGI qw/:standard/;

# A disciplined approach to dialog management with the user.

sub HTMLEncode {
  my $text = shift;
  $text =~ s/</&lt;/g;
  $text =~ s/&/&amp;/g;
  $text =~ s/\n/<br>/g;
  return $text;
}

sub GetInput {
  my $retval;
  $retval .= "<textarea rows=\"6\" wrap=virtual cols=\"42\"
         style=\"width:400\" name=\"trtext\"\"></textarea><p>\n";
  # now obtain the result
  $retval .= "<input type=submit name=\"Submit\">\n";
  return $retval;
}

sub Execute {
  my $retval;
  my $command = shift;
  # system $command;
  print `$command`;
  return $retval;
}

sub QueryUser {
  my $retval;
  # a message with a text input
  my ($contents) = (shift || "");
  # FIXME have to format contents for html here
  $retval .= Message(Message => "$contents>");
  $retval .= GetInput();
  return $retval;
}

sub ApproveCommand {
  my $retval;
  my $command = shift;
  $retval .= Message(Message => "$command\n");
  if (Approve("Execute this command? ")) {
    Execute($command);
    return 1;
  }
  return;
  return $retval;
}

sub ApproveCommands {
  my $retval;
  my %args = @_;
  if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
    foreach $command (@{$args{Commands}}) {
      $retval .= Message(Message => $command);
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
  return $retval;
}

sub Approve {
  my $retval;
  # a message with a choose
  my $message = shift || "Is this correct?";
  $message =~ s/((\?)?)[\s]*$/$1: /;
  $retval .= Message(Message => $message);
  # Choose("Yes","No");
  $retval .= "<input type=\"submit\" value=\"Yes\"> &nbsp; <input type=\"submit\" value=\"No\"><p>\n";
  return $retval;
}

sub AChoose {
  my $retval;
  my %args = @_;
  my @list = @{$args{Choices}};
  if ($args{Message}) {
    $retval .= Message(Message => $args{Message});
  }
  # going to be a radio
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    $retval .= Message(Message => "<Chose:".$list[0].">");
    return $list[0];
  } else {
    foreach my $item (@list) {
      if ($args{AllowHTML}) {
	$iitem = $item;
      } else {
	$iitem = HTMLEncode($item);
      }
      $retval .= "$i) <input type=\"radio\" name=\"choice\" value=\"$i\">".
	$iitem."<br>";
      ++$i;
    }
    $retval .= "<br>\n";
    $retval .= "<input type=\"submit\" value=\"Submit\">";
  }
  return $retval;
}

sub Choose {
  my $retval;
  # going to be a radio
  my @list = @_;
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    $retval .= Message(Message => "<Chose:".$list[0].">");
    return $list[0];
  } else {
    foreach my $item (@list) {
      $retval .= "$i) <input type=\"radio\" name=\"choice\" value=\"$i\">".
	HTMLEncode($item)."<br>";
      ++$i;
    }
    $retval .= "<br>\n";
    $retval .= "<input type=\"submit\" value=\"Submit\">";
  }
  return $retval;
}

sub Message {
  my $retval;
  # just a print
  my %args = @_;
  chomp $args{Message};
  $args{Message} = HTMLEncode($args{Message});
  if (defined $args{Terminated} and $args{Terminated} == 0) {
    $retval .= "<pre>$args{Message}</pre>\n";
  } else {
    $retval .= "<pre>$args{Message}</pre>\n";
  }
  return $retval;
}

sub SubsetSelect {
  my $retval;
  # going to be a series of checkboxes
  my (%args) = (@_);
  if ($args{Message}) {
    $retval .= Message(Message => $args{Message});
  }
  my @options = @{$args{Set}};
  my %selection = ();
  if ($args{Selection}) {
    %selection = %{$args{Selection}};
  }
  if (scalar @options > 0) {
    my $i = $args{MenuOffset} || 0;
    my $size = scalar(@options);
    if ($size > 20) {
      $size = 20;
    }
    $retval .= "<select multiple size=\"$size\" name=\"selection\">";
    foreach my $option (@options) {
      my $ioption = $option;
      if (! $args{AllowHTML}) {
	$ioption = HTMLEncode($option);
      }
      if ($selection{$option}) {
	$retval .= "$i) <option selected value=\"$i\">$ioption</option>\n";
      } else {
	$retval .= "$i) <option value=\"$i\">$ioption</option>\n";
      }
      chomp $option;
      $i = $i + 1;
    }
    $retval .= "</select>\n";
    $retval .= "<p>\n";
    $retval .= "<input type=\"submit\" value=\"Submit\">\n";
  }
  return $retval;
}

1;
