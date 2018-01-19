package Diamond::Target::CGI;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(QueryUser ApproveCommand ApproveCommands Approve
	     Choose AChoose Message SubsetSelect DiamondHeader);

use CGI qw/:standard/;

# A disciplined approach to dialog management with the user.

sub DiamondHeader {
  my $retval = header;
  $retval .= start_html('Diamond: CGI Interface');
  $retval .= "<form action=\"diamond.cgi\" method=\"post\">\n";
  $retval .= table
    (Tr
     ([
       td([
	   "<img src=\"dia.jpg\"><br>",
	   join("\n",
		(
		 "<big><big><a href=\"http://localhost/frdcsa/internal/diamond/\">Diamond</a>: CGI Interface</big></big><br>",
		 "Dynamically Generated User Interface<br>",
		 "<a href=\"http://localhost\">Become affiliated</a> with <a href=\"http://localhost/POSI\">POSI</a><br>",
		 "<input type=\"submit\" value=\"Stop Demo\">",
		)
	       ),
	  ]),
      ]));
  $retval .= hr;
  return $retval;
}

sub HTMLEncode {
  my $text = shift;
  $text =~ s/</&lt;/g;
  $text =~ s/&/&amp;/g;
  $text =~ s/\n/<br>/g;
  return $text;
}

sub GetInput {
  print "<textarea rows=\"6\" wrap=virtual cols=\"42\"
         style=\"width:400\" name=\"trtext\"\"></textarea><p>\n";
  # now obtain the result
  print "<input type=submit name=\"Submit\">\n";
}

sub Execute {
  my $command = shift;
  # system $command;
  print `$command`;
}

sub QueryUser {
  # a message with a text input
  my ($contents) = (shift || "");
  # FIXME have to format contents for html here
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
  my $message = shift || "Is this correct?";
  $message =~ s/((\?)?)[\s]*$/$1: /;
  Message(Message => $message);
  # Choose("Yes","No");
  print "<input type=\"submit\" value=\"Yes\"> &nbsp; <input type=\"submit\" value=\"No\"><p>\n";
}

sub AChoose {
  my %args = @_;
  my @list = @{$args{Choices}};
  if ($args{Message}) {
    Message(Message => $args{Message});
  }
  # going to be a radio
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    Message(Message => "<Chose:".$list[0].">");
    return $list[0];
  } else {
    foreach my $item (@list) {
      if ($args{AllowHTML}) {
	$iitem = $item;
      } else {
	$iitem = HTMLEncode($item);
      }
      print "$i) <input type=\"radio\" name=\"choice\" value=\"$i\">".
	$iitem."<br>";
      ++$i;
    }
    print "<br>\n";
    print "<input type=\"submit\" value=\"Submit\">";
  }
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
      print "$i) <input type=\"radio\" name=\"choice\" value=\"$i\">".
	HTMLEncode($item)."<br>";
      ++$i;
    }
    print "<br>\n";
    print "<input type=\"submit\" value=\"Submit\">";
  }
}

sub Message {
  # just a print
  my %args = @_;
  chomp $args{Message};
  $args{Message} = HTMLEncode($args{Message});
  if (defined $args{Terminated} and $args{Terminated} == 0) {
    print "<pre>$args{Message}</pre>\n";
  } else {
    print "<pre>$args{Message}</pre>\n";
  }
}

sub SubsetSelect {
  # going to be a series of checkboxes
  my (%args) = (@_);
  if ($args{Message}) {
    Message(Message => $args{Message});
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
    print "<select multiple size=\"$size\" name=\"selection\">";
    foreach my $option (@options) {
      my $ioption = $option;
      if (! $args{AllowHTML}) {
	$ioption = HTMLEncode($option);
      }
      if ($selection{$option}) {
	print "$i) <option selected value=\"$i\">$ioption</option>\n";
      } else {
	print "$i) <option value=\"$i\">$ioption</option>\n";
      }
      chomp $option;
      $i = $i + 1;
    }
    print "</select>\n";
    print "<p>\n";
    print "<input type=\"submit\" value=\"Submit\">\n";
  }
}

1;
