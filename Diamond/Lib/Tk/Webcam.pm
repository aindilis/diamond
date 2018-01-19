package Diamond::Lib::Tk::WebcamFrame;

use Tk;
use Tk::JPEG;
use MIME::Base64 "encode_base64";

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
  # return $self->MyText($args{MyMainWindow}->Text(%args));
  # Some things that might need to be configured.
  my $device = $args{Device} || "/dev/video0";
  if ($device =~ /^\// && !-e $device) {
    die "Can't see video device: $device";
  }

  my $mw = $args{MainWindow}
    || MainWindow->new
      (
       -title => 'Tk Stream',
      );

  $mw->protocol(WM_DELETE_WINDOW => \&onExit);

  # A label to display the photos.
  my $photo = $mw->Label ()->pack();

  # A button to capture a photo
  my $capture = $mw->Button (
			     -text => "Take Picture",
			     -command => \&snapshot,
			    )->pack();

  $mw->update();

  my $cmd = "ffmpeg -b 100K -an -f video4linux2 -s 800x600 -r 10 -i $device -b 100K -f image2pipe -vcodec mjpeg - "
    . "| perl -pi -e 's/\\xFF\\xD8/KIRSLESEP\\xFF\\xD8/ig'";
  open (PIPE, "$cmd |");

  my ($image,$lastimage);

  my $i = 0;
  my $jpgBuffer = "";		# last complete jpg image
  my $buffer = "";		# bytes read
  my $lastFrame = ""; # last complete jpg (kept until another full frame was read; for capturing to disk)
  while (read(PIPE, $buffer, 2048)) {
    my (@images) = split(/KIRSLESEP/, $buffer);
    shift(@images) if length $images[0] == 0;
    if (scalar(@images) == 1) {
      # Still the old image.
      my $len = length $images[0];
      $jpgBuffer .= $images[0];
    } elsif (scalar(@images) == 2) {
      # We've completed the old image.
      $jpgBuffer .= shift(@images);
      my $len = length $images[0];
      next if length $jpgBuffer == 0;

      # Put this into the last frame received, in case the user
      # wants to save this snapshot to disk.
      $lastFrame = $jpgBuffer;

      # Create a new Photo object to hold the jpeg
      eval {
	$image = $mw->Photo (
			     -data => encode_base64($jpgBuffer),
			     -format => 'JPEG',
			    );
      };
      # Update the label to display the snapshot
      eval {
	$photo->configure (-image => $image);
      };
      # Delete the last image to free up memory leaks,
      # then copy the new image to it.
      $lastimage->delete if ($lastimage);
      $lastimage = $image;

      # Refresh the GUI
      $mw->update();

      # Start reading the next image.
      $jpgBuffer = shift(@images);
    } else {
      print "Weird error: 3 items in array!\n";
      exit(1);
    }
  }
}

sub snapshot {
  # Make up a capture filename.
  my $i = 0;
  my $fname = "capture" . (sprintf("%04d",$i)) . ".jpg";
  while (-f $fname) {
    $fname = "capture" . (sprintf("%04d",++$i)) . ".jpg";
  }

  # Save it.
  open (WRITE, ">$fname");
  binmode WRITE;
  print WRITE $lastFrame;
  close (WRITE);
  print "Frame capture saved as $fname\n";
}

sub onExit {
  # Close ffmpeg.
  print "Exiting!\n";
  close (PIPE);
}

1;
